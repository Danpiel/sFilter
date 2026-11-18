-- In-combat display through Blizzard's CustomAuraContainer.
--
-- While aura data is secret (combat, encounters, M+, PvP) an addon cannot tell which aura is
-- which, but Blizzard's own aura container can: it matches auras against a list of spell IDs in
-- trusted code. Spell ID matching is allowed for buffs on friendly units (you, your pet) and for
-- debuffs on hostile units (target, focus) - exactly what sFilter tracks. Every such sFilter
-- icon gets an aura slot in a container for its unit. The slot's button holds sFilter's own
-- icon, cooldown swipe and texts, so it looks like the other icons (and like ElvUI with ElvUI),
-- and Blizzard fills them with the live aura in and out of combat.
--
-- Rules from the container: slot buttons can only be configured, moved and resized while aura
-- data is not secret, so changes made in combat are applied when it ends. Slots cannot be
-- removed, so they are reused by key and disabled when not needed.
--
-- A slot either accepts auras from anyone or only yours, so an icon whose spells mix both gets two
-- slots over the same place: one for its spells that count only when yours, one for the rest.

local _, ns = ...

local Native = {}
ns.Native = Native

local RT = ns.RT

-- Unit -> the aura type the container may match by spell ID on it.
local ELIGIBLE = { player = "HELPFUL", pet = "HELPFUL", target = "HARMFUL", focus = "HARMFUL" }

-- Visual parts sFilter created inside each Blizzard aura button, keyed by the button.
local parts = setmetatable({}, { __mode = "k" })
local lastParts

local function CanTouch()
	return not InCombatLockdown() and not ns.AreAurasSecret()
end

-- Runs inside the container (via securecallfunction) for every new slot button.
local function InitializeButton(button)
	local p = {}
	p.border = button:CreateTexture(nil, "BACKGROUND")
	p.border:SetPoint("TOPLEFT", -1, 1)
	p.border:SetPoint("BOTTOMRIGHT", 1, -1)
	p.border:SetColorTexture(0, 0, 0, 1)

	p.icon = button:CreateTexture(nil, "ARTWORK")
	p.icon:SetAllPoints(button)

	p.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	p.cooldown:SetAllPoints(p.icon)
	p.cooldown:SetReverse(true)
	p.cooldown:SetDrawEdge(false)
	p.cooldown:SetHideCountdownNumbers(true)
	p.cooldown:SetDrawBling(false)

	p.overlay = CreateFrame("Frame", nil, button)
	p.overlay:SetAllPoints(button)
	p.overlay:SetFrameLevel(p.cooldown:GetFrameLevel() + 2)

	p.gloss = p.overlay:CreateTexture(nil, "OVERLAY")
	p.gloss:SetTexture(ns.mediaPath .. "gloss")
	p.gloss:SetAllPoints(button)

	p.count = p.overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	p.count:SetPoint("BOTTOMRIGHT", -1, 1)
	p.count:SetJustifyH("RIGHT")

	p.timeText = p.overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	p.timeText:SetPoint("CENTER", 0, 0)

	ns.Skin:StyleIcon(p, button, true)
	ns.Skin:UpdateIconFonts(p, 32)

	button:SetIcon(p.icon)
	button:SetDurationCooldown(p.cooldown)
	button:SetApplicationCount(p.count)
	local formatter = ns.GetTimerFormatter()
	button:SetDurationText(p.timeText, formatter and { textFormatter = formatter } or nil)
	if button.EnableMouse then
		button:EnableMouse(false)
	end

	lastParts = p
end

local function SafeInitializeButton(button)
	local ok, err = pcall(InitializeButton, button)
	if not ok then
		Native.lastError = err
	end
end

function Native:Init()
	self.containers = {}
	self.pools = {}
	-- Icon -> its Blizzard aura buttons (two when its spells mix "yours" and "anyone's").
	self.assigned = {}
	self.pending = false

	local ok, container = pcall(CreateFrame, "AuraContainer", nil, UIParent, "CustomAuraContainerTemplate")
	self.available = ok and container ~= nil and type(container.AddAuraSlot) == "function"
	if self.available then
		self.spare = container
	end

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterUnitEvent("UNIT_PET", "player")
	frame:SetScript("OnEvent", function(_, event)
		if event == "PLAYER_TARGET_CHANGED" then
			Native:RefreshUnit("target")
		elseif event == "PLAYER_FOCUS_CHANGED" then
			Native:RefreshUnit("focus")
		elseif event == "UNIT_PET" then
			Native:RefreshUnit("pet")
		elseif event == "PLAYER_REGEN_ENABLED" then
			Native:FlushPending()
		else
			for unit in pairs(Native.containers) do
				Native:RefreshUnit(unit)
			end
		end
	end)
end

function Native:IsEligible(icon)
	return self.available and icon.track ~= "cooldown" and ELIGIBLE[icon.unit] == icon.filter
end

function Native:GetContainer(unit)
	local container = self.containers[unit]
	if container then
		return container
	end
	if self.spare then
		container, self.spare = self.spare, nil
	else
		container = CreateFrame("AuraContainer", nil, UIParent, "CustomAuraContainerTemplate")
	end
	container:SetSize(1, 1)
	container:SetPoint("CENTER", UIParent, "CENTER")
	container:SetFrameStrata("MEDIUM")
	container:SetUnit(unit)
	container:SetEnabled(true)
	container:Show()
	self.containers[unit] = container
	self.pools[unit] = { buttons = {}, count = 0 }
	return container
end

function Native:RefreshUnit(unit)
	local container = self.containers[unit]
	if container then
		pcall(container.UpdateAllAuras, container)
	end
end

-- Spell IDs for the container, split by whose auras count: maps.mine and maps.any. The container
-- matches IDs only, so in Forever, where every rank of a spell has its own ID, the rank you know
-- and ranks seen on auras before are added as well.
local SOURCES = { "mine", "any" }

function Native:BuildSpellMaps(icon, rt)
	local maps = { mine = {}, any = {} }
	for _, spellID in ipairs(icon.spells) do
		maps[rt.anyIds[spellID] and "any" or "mine"][spellID] = true
	end
	local learned = ns.db.learned or {}
	for name in pairs(rt.names) do
		local map = maps[rt.anyNames[name] and "any" or "mine"]
		if C_Spell and C_Spell.GetSpellInfo then
			local info = C_Spell.GetSpellInfo(name)
			if info and info.spellID then
				map[info.spellID] = true
			end
		end
		for spellID in pairs(learned[name] or {}) do
			map[spellID] = true
		end
	end
	return maps
end

function Native:EnsureSlot(container, unit, key, filterString, candidateFilters)
	local pool = self.pools[unit]
	local button = pool.buttons[key]
	if button then
		container:SetAuraSlotFilterString(key, filterString)
		container:SetAuraSlotCandidateFilters(key, candidateFilters)
		container:SetAuraSlotEnabled(key, true)
		return button
	end

	lastParts = nil
	button = container:AddAuraSlot(key, filterString, {
		candidateFilters = candidateFilters,
		initializeFrame = SafeInitializeButton,
	})
	if button then
		pool.buttons[key] = button
		pool.count = pool.count + 1
		parts[button] = lastParts
	end
	return button
end

function Native:Rebuild()
	if not self.available or not ns.profile then
		return
	end
	if not CanTouch() then
		self.pending = true
		return
	end
	self.pending = false

	for _, icon in ipairs(ns.profile.icons) do
		local rt = RT[icon]
		if rt and rt.source == "native" then
			rt.source = "own"
		end
	end
	wipe(self.assigned)

	local used = {}
	for _, icon in ipairs(ns.profile.icons) do
		local rt = RT[icon]
		local slot = rt and rt.slot
		if slot and not icon.disabled and #rt.order > 0 and self:IsEligible(icon) and not slot.groupFrame.group.hidden then
			local unit = icon.unit
			local maps = self:BuildSpellMaps(icon, rt)
			local buttons = {}
			for _, source in ipairs(SOURCES) do
				if next(maps[source]) then
					local candidateFilters = { includeSpellIDs = maps[source] }
					if source == "mine" then
						candidateFilters.isFromPlayerOrPlayerPet = true
					end
					local key = "dsf" .. ((used[unit] or 0) + #buttons + 1)
					local ok, button = pcall(function()
						return self:EnsureSlot(self:GetContainer(unit), unit, key, icon.filter, candidateFilters)
					end)
					if not (ok and button) then
						if not ok then
							self.lastError = button
						end
						-- Slots made for this icon so far are reused by the next one or switched off.
						buttons = nil
						break
					end
					buttons[#buttons + 1] = button
				end
			end
			if buttons and #buttons > 0 then
				used[unit] = (used[unit] or 0) + #buttons
				rt.source = "native"
				self.assigned[icon] = buttons
			end
		end
	end

	-- Slots cannot be removed, only switched off.
	for unit, pool in pairs(self.pools) do
		local container = self.containers[unit]
		for index = (used[unit] or 0) + 1, pool.count do
			pcall(container.SetAuraSlotEnabled, container, "dsf" .. index, false)
		end
	end

	self:Reanchor()
end

-- Places every Blizzard aura button over its sFilter slot. Buttons stay anchored to the slots,
-- so dragging a group in combat still moves them.
function Native:Reanchor()
	if not self.available then
		return
	end
	if not CanTouch() then
		self.pending = true
		return
	end
	for icon, buttons in pairs(self.assigned) do
		local slot = RT[icon] and RT[icon].slot
		if slot then
			local group = slot.groupFrame.group
			for _, button in ipairs(buttons) do
				pcall(function()
					button:ClearAllPoints()
					button:SetPoint("CENTER", slot, "CENTER")
					button:SetSize(group.size, group.size)
					button:SetAlpha(group.alpha)
					if parts[button] then
						ns.Skin:UpdateIconFonts(parts[button], group.size)
					end
				end)
			end
		end
	end
end

function Native:FlushPending()
	if self.pending and CanTouch() then
		self:Rebuild()
		ns.CDM:Rebuild()
		ns.Tracker:MarkAll()
	end
end

-- Remembers the actual spell ID of an aura that matched an icon by name (another rank), so the
-- container can match it in combat. Returns true if it was new.
function Native:Learn(name, spellID)
	ns.db.learned = ns.db.learned or {}
	local known = ns.db.learned[name]
	if not known then
		known = {}
		ns.db.learned[name] = known
	end
	if known[spellID] then
		return false
	end
	known[spellID] = true
	self.pending = true
	return true
end
