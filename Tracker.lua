-- Aura engine.
--
-- When aura data is readable (out of combat, outside encounters, M+ and PvP matches) all auras of a
-- unit are collected once and every icon looks its spells up by ID and by name, like sFilter did.
-- While aura data is secret an addon cannot tell which aura is which, so an icon can only be shown
-- if Blizzard flagged one of its spells as non-secret, or if the Cooldown Manager tracks it (the
-- CDMBridge then takes over the icon, see CDMBridge.lua).

local _, ns = ...

local Tracker = {}
ns.Tracker = Tracker

-- Runtime data per profile icon, kept out of the profile so it never ends up in SavedVariables or
-- in export strings.
local RT = setmetatable({}, { __mode = "k" })
ns.RT = RT

local MY_UNITS = { player = true, pet = true, vehicle = true }
local QUESTION_MARK = 134400
local POLL_INTERVAL = 0.2

local GLOBAL_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_TARGET_CHANGED",
	"PLAYER_FOCUS_CHANGED",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
	"ENCOUNTER_START",
	"ENCOUNTER_END",
	"CHALLENGE_MODE_START",
	"CHALLENGE_MODE_COMPLETED",
	"CHALLENGE_MODE_RESET",
	"SPELL_DATA_LOAD_RESULT",
	"SPELLS_CHANGED",
	"SPELL_UPDATE_COOLDOWN",
}

-- Icons that track a spell cooldown instead of an aura are scanned under this pseudo unit.
local COOLDOWN = "cooldown"

function Tracker:GetRuntime(icon)
	local rt = RT[icon]
	if not rt then
		rt = { state = {}, source = "own" }
		RT[icon] = rt
	end
	return rt
end

------------------------------------------------------------------------
-- Spell resolution
------------------------------------------------------------------------

local function IsSpellAuraSecret(spellID)
	if not (C_Secrets and C_Secrets.ShouldSpellAuraBeSecret) then
		return false
	end
	local ok, secret = pcall(C_Secrets.ShouldSpellAuraBeSecret, spellID)
	return not ok or secret ~= false
end

function Tracker:Resolve(icon)
	local rt = self:GetRuntime(icon)
	rt.ids, rt.names, rt.order, rt.invalid, rt.whitelist = {}, {}, {}, {}, {}
	rt.texture, rt.pending, rt.label = nil, false, nil

	for _, spellID in ipairs(icon.spells) do
		if not ns.DoesSpellExist(spellID) then
			rt.invalid[#rt.invalid + 1] = spellID
		else
			local name, texture = ns.GetSpellNameAndIcon(spellID)
			if not name then
				rt.pending = true
				if C_Spell and C_Spell.RequestLoadSpellData then
					C_Spell.RequestLoadSpellData(spellID)
				end
			end
			rt.ids[spellID] = true
			if name and not rt.names[name] then
				rt.names[name] = true
				rt.label = rt.label and (rt.label .. ", " .. name) or name
			end
			rt.order[#rt.order + 1] = { id = spellID, name = name }
			rt.texture = rt.texture or texture
			if not IsSpellAuraSecret(spellID) then
				rt.whitelist[#rt.whitelist + 1] = spellID
			end
		end
	end

	rt.texture = rt.texture or QUESTION_MARK
	rt.label = rt.label or table.concat(icon.spells, ", ")
	return rt
end

------------------------------------------------------------------------
-- Setup
------------------------------------------------------------------------

function Tracker:Init()
	self.byUnit = {}
	self.dirty = {}
	self.anyDirty = false
	self.restricted = ns.AreAurasSecret()
	self.elapsed = 0

	self.unitFrames = {}
	for _, unit in ipairs(ns.UNITS) do
		self.byUnit[unit] = {}
		local frame = CreateFrame("Frame")
		frame.unit = unit
		frame:SetScript("OnEvent", function(watcher)
			Tracker:MarkDirty(watcher.unit)
		end)
		self.unitFrames[unit] = frame
	end
	-- UNIT_PET fires for the owner, so it lives on the pet watcher with the player as the unit.
	self.unitFrames.pet:RegisterUnitEvent("UNIT_PET", "player")

	local frame = CreateFrame("Frame")
	for _, event in ipairs(GLOBAL_EVENTS) do
		pcall(frame.RegisterEvent, frame, event)
	end
	frame:SetScript("OnEvent", function(_, event, ...)
		Tracker:OnEvent(event, ...)
	end)
	frame:SetScript("OnUpdate", function(_, elapsed)
		Tracker:OnUpdate(elapsed)
	end)
	self.eventFrame = frame
end

function Tracker:Rebuild()
	for _, unit in ipairs(ns.UNITS) do
		wipe(self.byUnit[unit])
	end
	self.byUnit[COOLDOWN] = self.byUnit[COOLDOWN] or {}
	wipe(self.byUnit[COOLDOWN])
	for _, icon in ipairs(ns.profile.icons) do
		self:Resolve(icon)
		if not icon.disabled then
			local list = self.byUnit[icon.track == "cooldown" and COOLDOWN or icon.unit]
			list[#list + 1] = icon
		end
	end
	for _, unit in ipairs(ns.UNITS) do
		local watcher = self.unitFrames[unit]
		if #self.byUnit[unit] > 0 then
			watcher:RegisterUnitEvent("UNIT_AURA", unit)
		else
			watcher:UnregisterEvent("UNIT_AURA")
		end
	end
end

------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------

function Tracker:MarkDirty(unit)
	self.dirty[unit] = true
	self.anyDirty = true
end

function Tracker:MarkAll()
	for _, unit in ipairs(ns.UNITS) do
		self.dirty[unit] = true
	end
	self.dirty[COOLDOWN] = true
	self.anyDirty = true
end

function Tracker:OnEvent(event, ...)
	if event == "SPELL_UPDATE_COOLDOWN" then
		self:MarkDirty(COOLDOWN)
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:MarkDirty("target")
	elseif event == "PLAYER_FOCUS_CHANGED" then
		self:MarkDirty("focus")
	elseif event == "SPELL_DATA_LOAD_RESULT" or event == "SPELLS_CHANGED" then
		if event == "SPELLS_CHANGED" then
			-- A new rank may have been learned; the aura container needs its ID.
			ns.Native.pending = true
		end
		local resolved = false
		for icon, rt in pairs(RT) do
			if rt.pending then
				self:Resolve(icon)
				resolved = true
			end
		end
		if resolved then
			ns.CDM:Rebuild()
			self:MarkAll()
			if ns.Options then
				ns.Options:Refresh()
			end
		end
	else
		self:MarkAll()
	end
end

function Tracker:OnUpdate(elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed >= POLL_INTERVAL then
		self.elapsed = 0
		-- Restrictions can start without a dedicated event (e.g. a PvP match), so poll the flag.
		local restricted = ns.AreAurasSecret()
		if restricted ~= self.restricted then
			self.restricted = restricted
			self:MarkAll()
		end
		-- Aura container changes made while auras were secret wait until it is allowed again.
		if ns.Native.pending then
			ns.Native:FlushPending()
		end
		-- Keeps the preview timers running while the groups are unlocked.
		if ns.unlocked then
			self.anyDirty = true
		end
	end

	if self.anyDirty then
		self.anyDirty = false
		for unit in pairs(self.dirty) do
			self.dirty[unit] = nil
			self:ScanUnit(unit)
		end
		ns.Display:Render()
	end
end

function Tracker:ScanAll()
	for _, unit in ipairs(ns.UNITS) do
		self.dirty[unit] = nil
		self:ScanUnit(unit)
	end
	self.dirty[COOLDOWN] = nil
	self:ScanUnit(COOLDOWN)
	self.anyDirty = false
	ns.Display:Render()
end

------------------------------------------------------------------------
-- Scanning
------------------------------------------------------------------------

local function IsMine(aura)
	return aura.isFromPlayerOrPlayerPet or MY_UNITS[aura.sourceUnit] or false
end

local function NewLookup()
	return { byId = {}, byName = {}, mineById = {}, mineByName = {} }
end

local function AddAura(lookup, aura)
	local spellID, name = aura.spellId, aura.name
	if ns.IsSecret(spellID) or ns.IsSecret(name) then
		return false
	end
	if spellID and not lookup.byId[spellID] then
		lookup.byId[spellID] = aura
	end
	if name and not lookup.byName[name] then
		lookup.byName[name] = aura
	end
	if IsMine(aura) then
		if spellID and not lookup.mineById[spellID] then
			lookup.mineById[spellID] = aura
		end
		if name and not lookup.mineByName[name] then
			lookup.mineByName[name] = aura
		end
	end
	return true
end

-- Collects every aura of a unit for one filter. Returns nil if the data turned out to be secret.
local function Collect(unit, filter)
	local lookup = NewLookup()
	if C_UnitAuras.GetUnitAuras then
		local ok, auras = pcall(C_UnitAuras.GetUnitAuras, unit, filter)
		if not ok then
			return nil
		end
		for i = 1, #(auras or {}) do
			if not AddAura(lookup, auras[i]) then
				return nil
			end
		end
		return lookup
	end

	for index = 1, 255 do
		local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, unit, index, filter)
		if not ok then
			return nil
		end
		if not aura then
			break
		end
		if not AddAura(lookup, aura) then
			return nil
		end
	end
	return lookup
end

local function SetActive(state, aura)
	state.active = true
	state.texture = aura.icon
	state.count = aura.applications or 0
	state.duration = aura.duration or 0
	state.expiration = aura.expirationTime or 0
	state.timeMod = aura.timeMod or 1
end

local function MatchLookup(icon, rt, lookup)
	local byId = icon.mine and lookup.mineById or lookup.byId
	local byName = icon.mine and lookup.mineByName or lookup.byName
	for _, entry in ipairs(rt.order) do
		local aura = byId[entry.id] or (entry.name and byName[entry.name])
		if aura then
			-- Matched another rank by name: remember its ID for the in-combat aura container.
			if entry.name and aura.spellId and not rt.ids[aura.spellId] then
				ns.Native:Learn(entry.name, aura.spellId)
			end
			SetActive(rt.state, aura)
			return
		end
	end
end

-- Only spells Blizzard flagged as non-secret can be queried while auras are restricted.
local function MatchWhitelisted(unit, icon, rt)
	for _, spellID in ipairs(rt.whitelist) do
		local ok, aura = pcall(C_UnitAuras.GetUnitAuraBySpellID, unit, spellID)
		if ok and aura and not ns.IsSecret(aura.expirationTime) and not ns.IsSecret(aura.icon) then
			local wantsHelpful = icon.filter == "HELPFUL"
			local typeKnown = aura.isHelpful ~= nil and not ns.IsSecret(aura.isHelpful)
			local typeMatches = not typeKnown or (aura.isHelpful == wantsHelpful)
			local sourceKnown = not ns.IsSecret(aura.sourceUnit) and not ns.IsSecret(aura.isFromPlayerOrPlayerPet)
			local sourceMatches = not icon.mine or not sourceKnown or IsMine(aura)
			if typeMatches and sourceMatches then
				SetActive(rt.state, aura)
				return
			end
		end
	end
end

------------------------------------------------------------------------
-- Cooldown icons
------------------------------------------------------------------------

-- The rank the player knows (ranks share one cooldown); falls back to the first listed ID.
local function KnownSpellID(icon, rt)
	for _, spellID in ipairs(icon.spells) do
		if IsPlayerSpell and IsPlayerSpell(spellID) then
			return spellID
		end
	end
	for name in pairs(rt.names) do
		local info = C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(name)
		if info and info.spellID then
			return info.spellID
		end
	end
	return icon.spells[1]
end

-- Fills the state of a cooldown icon. isActive and isOnGCD are never secret, so the icon shows
-- and hides correctly even in combat; when the times themselves are secret a duration object
-- drives the timer text and fade instead (see Display).
local function ScanCooldown(icon, rt)
	local state = rt.state
	state.durationObject = nil
	local spellID = KnownSpellID(icon, rt)
	local ok, info = pcall(C_Spell.GetSpellCooldown, spellID)
	if not ok or not info or not info.isActive or info.isOnGCD then
		return
	end
	if ns.IsSecret(info.startTime) or ns.IsSecret(info.duration) then
		local okDuration, durationObject = pcall(C_Spell.GetSpellCooldownDuration, spellID, true)
		if okDuration and durationObject then
			state.active = true
			state.texture = rt.texture
			state.count = 0
			state.durationObject = durationObject
		end
		return
	end
	-- Readable times: a short cooldown is the global cooldown, not the spell's own.
	if info.duration > 1.5 then
		SetActive(state, {
			icon = rt.texture, applications = 0, duration = info.duration,
			expirationTime = info.startTime + info.duration, timeMod = info.modRate,
		})
	end
end

function Tracker:ScanUnit(unit)
	local icons = self.byUnit[unit]
	if not icons or #icons == 0 then
		return
	end

	if unit == COOLDOWN then
		for _, icon in ipairs(icons) do
			local rt = RT[icon] or self:Resolve(icon)
			rt.state.active = false
			rt.state.blocked = false
			ScanCooldown(icon, rt)
		end
		return
	end

	local exists = UnitExists(unit)
	local lookups
	if exists and not self.restricted then
		lookups = {}
		for _, filter in ipairs(ns.FILTERS) do
			lookups[filter] = false
		end
	end

	for _, icon in ipairs(icons) do
		local rt = RT[icon] or self:Resolve(icon)
		local state = rt.state
		state.active = false
		state.blocked = false

		if exists and (rt.source == "own" or rt.source == "native") then
			local lookup
			if lookups then
				lookup = lookups[icon.filter]
				if lookup == false then
					lookup = Collect(unit, icon.filter)
					lookups[icon.filter] = lookup or nil
				end
			end

			if rt.source == "native" then
				-- Blizzard's aura container draws this icon; the scan only learns rank IDs for it.
				if lookup then
					MatchLookup(icon, rt, lookup)
					state.active = false
				end
			elseif lookup then
				MatchLookup(icon, rt, lookup)
			elseif #rt.whitelist > 0 then
				local ok = pcall(MatchWhitelisted, unit, icon, rt)
				if not ok then
					state.active = false
				end
			else
				state.blocked = true
			end
		end
	end
end

------------------------------------------------------------------------
-- Status for the settings window
------------------------------------------------------------------------

-- "native": shown in combat by Blizzard's aura container; "cdm": shown in combat through the
-- Cooldown Manager; "open": readable in combat (non-secret); "ooc": only out of combat.
function Tracker:CombatStatus(icon)
	local rt = RT[icon]
	if not rt then
		return "ooc"
	end
	if rt.source == "native" or rt.source == "cdm" then
		return rt.source
	end
	if icon.track == "cooldown" then
		return "cooldown"
	end
	if #rt.whitelist > 0 then
		return "open"
	end
	return "ooc"
end
