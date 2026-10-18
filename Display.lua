-- Icon groups, slots and movers.
--
-- A group is a grid anchored at one corner (picked from its growth directions), so adding icons
-- never shifts the ones already placed. Each icon in the profile sits in a numbered slot of a group;
-- several icons may share a slot, the first active one (in list order) is shown.
--
-- Unlocked mode shows a mover over every group: drag it with the left button, right-click for a
-- menu. Positions are saved in the profile, so they travel with export strings.

local _, ns = ...
local L = ns.L

local Display = {}
ns.Display = Display

local RT = ns.RT

local GRID_SIZE = 32
local PREVIEW_DURATION = 20
local PREVIEW_STACKS = 3

------------------------------------------------------------------------
-- Geometry
------------------------------------------------------------------------

local VECTORS = {
	RIGHT = { 1, 0 },
	LEFT = { -1, 0 },
	UP = { 0, 1 },
	DOWN = { 0, -1 },
}

-- Corner the group grows from, e.g. RIGHT + DOWN grows from TOPLEFT.
function Display.GetOrigin(group)
	local horizontal = ns.IsHorizontal(group.grow) and group.grow or group.wrap
	local vertical = ns.IsHorizontal(group.grow) and group.wrap or group.grow
	return (vertical == "DOWN" and "TOP" or "BOTTOM") .. (horizontal == "RIGHT" and "LEFT" or "RIGHT")
end

-- Offset of a slot's origin corner from the group's origin corner.
function Display.GetSlotOffset(group, slot)
	local index = slot - 1
	local column = index % group.perRow
	local row = math.floor(index / group.perRow)
	local step = group.size + group.spacing
	local grow, wrap = VECTORS[group.grow], VECTORS[group.wrap]
	return (column * grow[1] + row * wrap[1]) * step, (column * grow[2] + row * wrap[2]) * step
end

function Display.GetGroupSize(group, maxSlot)
	maxSlot = math.max(maxSlot or 1, 1)
	local columns = math.min(maxSlot, group.perRow)
	local rows = math.ceil(maxSlot / group.perRow)
	local step = group.size + group.spacing
	local along = columns * step - group.spacing
	local across = rows * step - group.spacing
	if ns.IsHorizontal(group.grow) then
		return along, across
	end
	return across, along
end

------------------------------------------------------------------------
-- Frames
------------------------------------------------------------------------

function Display:Init()
	self.groupFrames = {}
	self.activeGroups = {}

	-- Follow the game's Edit Mode: entering it unlocks the groups and shows the preview.
	if EventRegistry and EventRegistry.RegisterCallback then
		EventRegistry:RegisterCallback("EditMode.Enter", function()
			ns:SetUnlocked(true)
		end, self)
		EventRegistry:RegisterCallback("EditMode.Exit", function()
			ns:SetUnlocked(false)
		end, self)
	end

	-- Follow ElvUI's /moveui so all movers can be arranged together.
	local E = ns.Skin.E
	if E and type(E.ToggleMovers) == "function" then
		hooksecurefunc(E, "ToggleMovers", function(_, show, which)
			if which == nil or which == "all" or which == "ALL" then
				ns:SetUnlocked(show)
			end
		end)
	end
end

local function CreateSlot(groupFrame)
	local slot = CreateFrame("Frame", nil, groupFrame, "BackdropTemplate")
	slot.groupFrame = groupFrame
	slot.icons = {}

	slot.border = slot:CreateTexture(nil, "BACKGROUND")
	slot.border:SetPoint("TOPLEFT", -1, 1)
	slot.border:SetPoint("BOTTOMRIGHT", 1, -1)
	slot.border:SetColorTexture(0, 0, 0, 1)

	slot.icon = slot:CreateTexture(nil, "ARTWORK")
	slot.icon:SetAllPoints(slot)

	slot.cooldown = CreateFrame("Cooldown", nil, slot, "CooldownFrameTemplate")
	slot.cooldown:SetAllPoints(slot.icon)
	slot.cooldown:SetReverse(true)
	slot.cooldown:SetDrawEdge(false)
	-- The timer text is drawn by sFilter (mm:ss), not by Blizzard's or ElvUI's cooldown numbers,
	-- and the end-of-cooldown "bling" is off so an expiring icon fades instead of blinking.
	slot.cooldown:SetHideCountdownNumbers(true)
	slot.cooldown:SetDrawBling(false)

	slot.overlay = CreateFrame("Frame", nil, slot)
	slot.overlay:SetAllPoints(slot)
	slot.overlay:SetFrameLevel(slot.cooldown:GetFrameLevel() + 2)

	slot.gloss = slot.overlay:CreateTexture(nil, "OVERLAY")
	slot.gloss:SetTexture(ns.mediaPath .. "gloss")
	slot.gloss:SetAllPoints(slot)

	slot.count = slot.overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	slot.count:SetPoint("BOTTOMRIGHT", -1, 1)
	slot.count:SetJustifyH("RIGHT")
	slot.count:SetTextColor(0.9, 0.9, 0.9)

	slot.slotText = slot.overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
	slot.slotText:SetPoint("TOPLEFT", 1, -1)
	slot.slotText:SetTextColor(1, 0.55, 0)

	slot.timeText = slot.overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	slot.timeText:SetPoint("CENTER", 0, 0)

	ns.Skin:StyleIcon(slot, nil, true)
	return slot
end

local function CreateGroupFrame()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("LOW")
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame.slots = {}

	local mover = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	mover:SetPoint("TOPLEFT", -3, 3)
	mover:SetPoint("BOTTOMRIGHT", 3, -3)
	mover:SetFrameLevel(frame:GetFrameLevel() + 20)
	mover:EnableMouse(true)
	mover:RegisterForDrag("LeftButton")
	ns.Skin:Mover(mover)
	mover:Hide()
	frame.mover = mover

	mover.label = mover:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ns.Skin:FontString(mover.label, 11, "OUTLINE")
	mover.label:SetPoint("BOTTOM", mover, "TOP", 0, 2)

	mover.lock = mover:CreateTexture(nil, "OVERLAY")
	mover.lock:SetSize(14, 14)
	mover.lock:SetPoint("TOPRIGHT", -1, -1)
	mover.lock:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-LOCK")

	mover:SetScript("OnDragStart", function()
		if frame.group and not frame.group.locked then
			frame.moving = true
			frame:StartMoving()
		end
	end)
	mover:SetScript("OnDragStop", function()
		if frame.moving then
			frame.moving = false
			frame:StopMovingOrSizing()
			Display:SavePosition(frame)
		end
	end)
	mover:SetScript("OnMouseUp", function(_, button)
		if button == "RightButton" then
			Display:OpenGroupMenu(frame)
		end
	end)
	mover:SetScript("OnEnter", function(self)
		ns.Skin:SetMoverHighlight(self, true)
		Display:ShowMoverTooltip(frame)
	end)
	mover:SetScript("OnLeave", function(self)
		ns.Skin:SetMoverHighlight(self, false)
		GameTooltip:Hide()
	end)

	return frame
end

function Display:AcquireGroupFrame(key)
	local frame = self.groupFrames[key]
	if not frame then
		frame = CreateGroupFrame()
		self.groupFrames[key] = frame
	end
	return frame
end

function Display:GetSlotFrame(groupKey, slotIndex)
	local frame = self.activeGroups[groupKey]
	return frame and frame.slots[slotIndex]
end

------------------------------------------------------------------------
-- Build and layout
------------------------------------------------------------------------

function Display:Rebuild()
	for _, frame in pairs(self.groupFrames) do
		frame:Hide()
		frame.group = nil
		for _, slot in pairs(frame.slots) do
			slot:Hide()
			slot.used = false
			wipe(slot.icons)
		end
	end
	wipe(self.activeGroups)

	for _, group in ipairs(ns.profile.groups) do
		local frame = self:AcquireGroupFrame(group.key)
		frame.group = group
		self.activeGroups[group.key] = frame
	end

	for _, icon in ipairs(ns.profile.icons) do
		local rt = RT[icon] or ns.Tracker:Resolve(icon)
		rt.slot = nil
		local frame = self.activeGroups[icon.group]
		if frame and not icon.disabled then
			local slot = frame.slots[icon.slot]
			if not slot then
				slot = CreateSlot(frame)
				frame.slots[icon.slot] = slot
			end
			slot.used = true
			slot.icons[#slot.icons + 1] = icon
			rt.slot = slot
		end
	end

	self:Layout()
	self:UpdateUnlocked()
end

function Display:LayoutGroup(frame)
	local group = frame.group
	local origin = self.GetOrigin(group)

	local maxSlot = 1
	for index, slot in pairs(frame.slots) do
		if slot.used and index > maxSlot then
			maxSlot = index
		end
	end

	local width, height = self.GetGroupSize(group, maxSlot)
	frame:SetSize(width, height)
	frame:ClearAllPoints()
	frame:SetPoint(origin, UIParent, "CENTER", group.x, group.y)
	frame:SetAlpha(group.alpha)
	frame.mover.label:SetText(group.name)
	frame.mover.lock:SetShown(group.locked)

	for index, slot in pairs(frame.slots) do
		if slot.used then
			local x, y = self.GetSlotOffset(group, index)
			slot:ClearAllPoints()
			slot:SetPoint(origin, frame, origin, x, y)
			slot:SetSize(group.size, group.size)
			slot.slotText:SetText(index)
			ns.Skin:UpdateIconFonts(slot, group.size)
		end
	end

	frame:SetShown(not group.hidden or ns.unlocked)
end

function Display:Layout()
	for _, frame in pairs(self.activeGroups) do
		self:LayoutGroup(frame)
	end
end

------------------------------------------------------------------------
-- Rendering
------------------------------------------------------------------------

local TIMER_INTERVAL = 0.05
local FLASH_DURATION = 0.45

------------------------------------------------------------------------
-- Expiry flash: a copy of the icon that grows and fades. It lives on the group frame, so it
-- keeps playing after the slot itself is hidden when the aura goes away.
------------------------------------------------------------------------

local function GetFlash(slot)
	local flash = slot.flash
	if flash then
		return flash
	end
	flash = CreateFrame("Frame", nil, slot.groupFrame)
	flash:SetFrameLevel(slot.overlay:GetFrameLevel() + 5)
	flash:Hide()
	flash.texture = flash:CreateTexture(nil, "OVERLAY")
	flash.texture:SetAllPoints(flash)
	flash.texture:SetBlendMode("ADD")
	local coords = ns.Skin:GetTexCoord()
	flash.texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])

	local animation = flash:CreateAnimationGroup()
	local fade = animation:CreateAnimation("Alpha")
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0)
	fade:SetDuration(FLASH_DURATION)
	local grow = animation:CreateAnimation("Scale")
	grow:SetScaleFrom(1, 1)
	grow:SetScaleTo(1.6, 1.6)
	grow:SetDuration(FLASH_DURATION)
	animation:SetScript("OnFinished", function()
		flash:Hide()
	end)
	flash.animation = animation
	slot.flash = flash
	return flash
end

function Display:Flash(slot, texture)
	local flash = GetFlash(slot)
	flash:ClearAllPoints()
	flash:SetPoint("CENTER", slot, "CENTER")
	flash:SetSize(slot:GetWidth(), slot:GetHeight())
	flash.texture:SetTexture(texture or slot.icon:GetTexture())
	flash:Show()
	flash.animation:Stop()
	flash.animation:Play()
end

------------------------------------------------------------------------
-- Timer: mm:ss text, fade-out before expiry and the optional expiry flash
------------------------------------------------------------------------

local function UpdateTimer(slot, elapsed)
	slot.timerElapsed = (slot.timerElapsed or 0) + elapsed
	if slot.timerElapsed < TIMER_INTERVAL then
		return
	end
	slot.timerElapsed = 0

	local group = slot.groupFrame.group
	local remaining = (slot.timerEnd or 0) - GetTime()
	slot.timeText:SetText(remaining > 0 and ns.FormatTime(remaining) or "")

	-- Fade out smoothly instead of popping away when the aura ends.
	local fadeTime = group and group.fadeTime or 0
	if fadeTime > 0 and remaining < fadeTime then
		slot:SetAlpha(math.max(remaining, 0) / fadeTime)
	else
		slot:SetAlpha(1)
	end

	if remaining <= 0 and not slot.flashed then
		slot.flashed = true
		if group and group.flashOnExpire then
			Display:Flash(slot)
		end
	end
end

-- Remaining seconds -> alpha: 0 at the end, fading up to 1 over fadeTime (a hard step if 0).
local alphaCurves = {}
local function GetAlphaCurve(fadeTime)
	if alphaCurves[fadeTime] == nil then
		alphaCurves[fadeTime] = false
		if C_CurveUtil and C_CurveUtil.CreateCurve then
			local ok, curve = pcall(C_CurveUtil.CreateCurve)
			if ok and curve then
				local types = Enum.LuaCurveType or {}
				if fadeTime > 0 then
					curve:SetType(types.Linear or 0)
					curve:AddPoint(0, 0)
					curve:AddPoint(fadeTime, 1)
				else
					curve:SetType(types.Step or 1)
					curve:AddPoint(0, 0)
					curve:AddPoint(0.05, 1)
				end
				curve:AddPoint(36000, 1)
				alphaCurves[fadeTime] = curve
			end
		end
	end
	return alphaCurves[fadeTime] or nil
end

-- Timer for cooldown icons whose times are secret (in combat): the duration object formats the
-- text and evaluates the fade curve; the addon never sees the numbers.
local function UpdateSecretTimer(slot, elapsed)
	slot.timerElapsed = (slot.timerElapsed or 0) + elapsed
	if slot.timerElapsed < TIMER_INTERVAL then
		return
	end
	slot.timerElapsed = 0
	local durationObject = slot.durationObject
	local group = slot.groupFrame.group
	pcall(function()
		local curve = GetAlphaCurve(group and group.fadeTime or 0)
		if curve then
			slot:SetAlpha(durationObject:EvaluateRemainingDuration(curve))
		end
		local formatter = ns.GetTimerFormatter()
		if formatter then
			slot.timeText:SetText(durationObject:FormatRemainingDuration(formatter))
		end
	end)
end

local function SetSecretTimer(slot, durationObject)
	slot.timerEnd = nil
	slot.flashed = true
	slot.durationObject = durationObject
	slot.cdStart, slot.cdDuration = nil, nil
	slot.cooldown:Clear()
	slot.cooldown:Hide()
	slot:SetScript("OnUpdate", UpdateSecretTimer)
	UpdateSecretTimer(slot, TIMER_INTERVAL)
end

-- Runs the timer until expiration; nil stops it.
local function SetTimer(slot, expiration)
	slot.durationObject = nil
	slot.timerEnd = expiration
	slot.flashed = false
	slot:SetAlpha(1)
	if expiration then
		slot.timerElapsed = TIMER_INTERVAL
		slot:SetScript("OnUpdate", UpdateTimer)
		UpdateTimer(slot, 0)
	else
		slot:SetScript("OnUpdate", nil)
		slot.timeText:SetText("")
	end
end

local function SetCooldown(slot, state)
	local duration, expiration = state.duration or 0, state.expiration or 0
	if duration > 0 and expiration > 0 then
		local start = expiration - duration
		if slot.cdStart ~= start or slot.cdDuration ~= duration then
			slot.cdStart, slot.cdDuration = start, duration
			slot.cooldown:SetCooldown(start, duration, state.timeMod or 1)
			SetTimer(slot, expiration)
		end
		slot.cooldown:Show()
	else
		slot.cdStart, slot.cdDuration = nil, nil
		slot.cooldown:Clear()
		slot.cooldown:Hide()
		SetTimer(slot, nil)
	end
end

local function ShowStatic(slot, texture, alpha, desaturate)
	slot.icon:SetTexture(texture)
	slot.icon:SetDesaturated(desaturate)
	slot.icon:SetAlpha(alpha)
	slot.count:SetText("")
	slot.cdStart, slot.cdDuration = nil, nil
	slot.cooldown:Clear()
	slot.cooldown:Hide()
	SetTimer(slot, nil)
	slot:Show()
end

function Display:RenderSlot(slot)
	local group = slot.groupFrame.group
	slot.slotText:SetShown(ns.unlocked)

	for _, icon in ipairs(slot.icons) do
		local state = RT[icon] and RT[icon].state
		if state and state.active then
			slot.icon:SetTexture(state.texture or RT[icon].texture)
			slot.icon:SetDesaturated(false)
			slot.icon:SetAlpha(1)
			slot.count:SetText((state.count or 0) > 1 and state.count or "")
			if state.durationObject then
				SetSecretTimer(slot, state.durationObject)
			else
				SetCooldown(slot, state)
			end
			slot:Show()
			return
		end
	end

	-- The aura went away at (about) the end of its timer before the timer itself reached zero.
	if slot.timerEnd and not slot.flashed and not ns.unlocked and slot.timerEnd - GetTime() < 0.5 then
		slot.flashed = true
		if group.flashOnExpire then
			self:Flash(slot)
		end
	end

	local first = slot.icons[1]
	local texture = first and RT[first] and RT[first].texture
	if ns.unlocked then
		-- Preview: every icon looks as if it just procced, with a running timer and stacks.
		slot.icon:SetTexture(texture)
		slot.icon:SetDesaturated(false)
		slot.icon:SetAlpha(1)
		slot:Show()
		local start = math.floor(GetTime() / PREVIEW_DURATION) * PREVIEW_DURATION
		SetCooldown(slot, { duration = PREVIEW_DURATION, expiration = start + PREVIEW_DURATION })
		slot.count:SetText(PREVIEW_STACKS)
	elseif group.showInactive and texture then
		ShowStatic(slot, texture, 0.35, true)
	else
		slot:Hide()
	end
end

function Display:Render()
	for _, frame in pairs(self.activeGroups) do
		for _, slot in pairs(frame.slots) do
			if slot.used then
				self:RenderSlot(slot)
			end
		end
	end
end

------------------------------------------------------------------------
-- Unlocked mode
------------------------------------------------------------------------

function Display:UpdateUnlocked()
	local unlocked = ns.unlocked
	for _, frame in pairs(self.activeGroups) do
		frame.mover:SetShown(unlocked)
		frame:SetShown(not frame.group.hidden or unlocked)
	end
	self:UpdateUnlockBar()
	if not unlocked and self.grid then
		self.grid:Hide()
	elseif unlocked and ns.db.settings.grid then
		self:ShowGrid(true)
	end
	self:Render()
end

-- Saves the position of the group's origin corner relative to the screen center.
function Display:SavePosition(frame)
	local group = frame.group
	local origin = self.GetOrigin(group)
	local scale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
	local centerX, centerY = UIParent:GetCenter()
	local x = (origin:find("LEFT") and frame:GetLeft() or frame:GetRight()) * scale - centerX
	local y = (origin:find("TOP") and frame:GetTop() or frame:GetBottom()) * scale - centerY
	group.x, group.y = ns.Round(x), ns.Round(y)
	ns:RefreshLayout()
end

function Display:ShowMoverTooltip(frame)
	local group = frame.group
	GameTooltip:SetOwner(frame.mover, "ANCHOR_TOP")
	GameTooltip:SetText(group.name)
	GameTooltip:AddLine(string.format("X: %d  Y: %d", group.x, group.y), 1, 1, 1)
	if group.locked then
		GameTooltip:AddLine(L["This group is pinned. Right-click to unpin it."], 1, 0.3, 0.3, true)
	else
		GameTooltip:AddLine(L["Drag to move."], 0.8, 0.8, 0.8)
	end
	GameTooltip:AddLine(L["Right-click: menu."], 0.8, 0.8, 0.8)
	GameTooltip:Show()
end

function Display:OpenGroupMenu(frame)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	local group = frame.group
	MenuUtil.CreateContextMenu(frame.mover, function(_, root)
		root:CreateTitle(group.name)
		root:CreateCheckbox(L["Pin this group"], function()
			return group.locked
		end, function()
			group.locked = not group.locked
			ns:RefreshLayout()
		end)
		root:CreateCheckbox(L["Show inactive icons"], function()
			return group.showInactive
		end, function()
			group.showInactive = not group.showInactive
			ns:RefreshLayout()
			Display:Render()
		end)
		root:CreateCheckbox(L["Flash when the timer runs out"], function()
			return group.flashOnExpire
		end, function()
			group.flashOnExpire = not group.flashOnExpire
			ns:RefreshLayout()
		end)
		root:CreateCheckbox(L["Hide group"], function()
			return group.hidden
		end, function()
			group.hidden = not group.hidden
			ns:RefreshLayout()
		end)
		root:CreateButton(L["Reset position"], function()
			ns.Profile.ResetGroupPosition(group)
			ns:RefreshLayout()
		end)
		root:CreateButton(L["Group settings..."], function()
			ns.Options:Show("groups", group.key)
		end)
		root:CreateDivider()
		root:CreateButton(L["Lock all groups"], function()
			ns:SetUnlocked(false)
		end)
	end)
end

function Display:UpdateUnlockBar()
	if not ns.unlocked then
		if self.unlockBar then
			self.unlockBar:Hide()
		end
		return
	end

	local bar = self.unlockBar
	if not bar then
		bar = CreateFrame("Frame", "sFilterUnlockBar", UIParent, "BackdropTemplate")
		bar:SetSize(380, 58)
		bar:SetPoint("TOP", 0, -110)
		bar:SetFrameStrata("DIALOG")
		bar:SetClampedToScreen(true)
		bar:SetMovable(true)
		bar:EnableMouse(true)
		bar:RegisterForDrag("LeftButton")
		bar:SetScript("OnDragStart", bar.StartMoving)
		bar:SetScript("OnDragStop", bar.StopMovingOrSizing)
		ns.Skin:Window(bar)

		bar.title = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		ns.Skin:FontString(bar.title, 13, "OUTLINE")
		bar.title:SetPoint("TOP", 0, -8)
		bar.title:SetTextColor(ns.Skin:AccentColor())
		bar.title:SetText(L["sFilter: moving icon groups"])

		local function MakeButton(text, x, onClick)
			local button = CreateFrame("Button", nil, bar, "UIPanelButtonTemplate")
			button:SetSize(116, 22)
			button:SetPoint("BOTTOM", x, 8)
			button:SetText(text)
			button:SetScript("OnClick", onClick)
			ns.Skin:Button(button)
			return button
		end
		MakeButton(L["Grid"], -122, function()
			ns.db.settings.grid = not ns.db.settings.grid
			Display:ShowGrid(ns.db.settings.grid)
		end)
		MakeButton(L["Settings"], 0, function()
			ns.Options:Show("groups")
		end)
		MakeButton(L["Lock"], 122, function()
			ns:SetUnlocked(false)
		end)
		self.unlockBar = bar
	end
	bar:Show()
end

function Display:ShowGrid(show)
	if not show then
		if self.grid then
			self.grid:Hide()
		end
		return
	end

	local grid = self.grid
	if not grid then
		grid = CreateFrame("Frame", nil, UIParent)
		grid:SetAllPoints(UIParent)
		grid:SetFrameStrata("BACKGROUND")
		local width, height = UIParent:GetSize()
		local function Line(horizontal, offset, center)
			local line = grid:CreateTexture(nil, "BACKGROUND")
			if center then
				line:SetColorTexture(1, 0.2, 0.2, 0.6)
			else
				line:SetColorTexture(0, 0, 0, 0.45)
			end
			if horizontal then
				line:SetSize(width, 1)
				line:SetPoint("CENTER", grid, "CENTER", 0, offset)
			else
				line:SetSize(1, height)
				line:SetPoint("CENTER", grid, "CENTER", offset, 0)
			end
		end
		for offset = 0, width / 2, GRID_SIZE do
			Line(false, offset, offset == 0)
			if offset > 0 then
				Line(false, -offset)
			end
		end
		for offset = 0, height / 2, GRID_SIZE do
			Line(true, offset, offset == 0)
			if offset > 0 then
				Line(true, -offset)
			end
		end
		self.grid = grid
	end
	grid:Show()
end
