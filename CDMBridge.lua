-- Cooldown Manager bridge.
--
-- In combat (and in encounters, M+ and PvP) aura data is secret for addons, but Blizzard's
-- Cooldown Manager still knows which buff or debuff is which. For every sFilter icon whose spell
-- is shown in the Cooldown Manager's "Tracked Buffs" bar, the Blizzard icon frame is anchored into
-- the sFilter slot and sized to it, so it keeps working in combat at the position you chose.
--
-- Only hooksecurefunc and frame setters (SetPoint/SetScale) are used on Blizzard frames; no fields
-- are written to them, so no taint spreads into Blizzard code. With ElvUI those icons are already
-- skinned by ElvUI's own Cooldown Manager skin.

local _, ns = ...
local L = ns.L

local CDM = {}
ns.CDM = CDM

local RT = ns.RT
local HOOKED_METHODS = { "RefreshLayout", "Layout", "OnCooldownDataChanged" }

function CDM:Init()
	self.claims = {}
	self.hooked = {}
	self.availableIds = {}
	self.availableNames = {}
	self:TryHook()
end

function CDM:OnAddonLoaded(name)
	if name == "Blizzard_CooldownViewer" and self.claims then
		self:TryHook()
		self:Rebuild()
	end
end

function CDM:GetViewer()
	return _G.BuffIconCooldownViewer
end

function CDM:IsEnabled()
	if C_CVar and C_CVar.GetCVarBool then
		return C_CVar.GetCVarBool("cooldownViewerEnabled") and true or false
	end
	return false
end

function CDM:IsAvailable()
	if not (C_CooldownViewer and C_CooldownViewer.IsCooldownViewerAvailable) then
		return false, L["This client has no Cooldown Manager."]
	end
	local ok, available, reason = pcall(C_CooldownViewer.IsCooldownViewerAvailable)
	if not ok then
		return false, nil
	end
	return available, reason
end

function CDM:TryHook()
	local viewer = self:GetViewer()
	if not viewer or self.hooked[viewer] then
		return
	end
	self.hooked[viewer] = true
	local function OnViewerChanged()
		CDM:Rebuild()
	end
	for _, method in ipairs(HOOKED_METHODS) do
		if type(viewer[method]) == "function" then
			hooksecurefunc(viewer, method, OnViewerChanged)
		end
	end
end

------------------------------------------------------------------------
-- Cooldown Manager data
------------------------------------------------------------------------

local function EnumerateItems(viewer)
	local items = {}
	local pool = viewer.itemFramePool
	if pool and pool.EnumerateActive then
		for item in pool:EnumerateActive() do
			items[#items + 1] = item
		end
	elseif viewer.GetItemFrames then
		local ok, frames = pcall(viewer.GetItemFrames, viewer)
		if ok and type(frames) == "table" then
			for _, item in ipairs(frames) do
				items[#items + 1] = item
			end
		end
	end
	return items
end

local function GetCooldownInfo(cooldownID)
	if not cooldownID or ns.IsSecret(cooldownID) then
		return nil
	end
	local ok, info = pcall(C_CooldownViewer.GetCooldownViewerCooldownInfo, cooldownID)
	if ok and type(info) == "table" then
		return info
	end
end

local function GetItemInfo(item)
	if type(item.GetCooldownID) ~= "function" then
		return nil
	end
	local ok, cooldownID = pcall(item.GetCooldownID, item)
	return ok and GetCooldownInfo(cooldownID) or nil
end

-- All spell IDs (base, override and linked) a Cooldown Manager entry stands for.
local function InfoSpellIDs(info)
	local ids = {}
	if info.spellID then
		ids[#ids + 1] = info.spellID
	end
	if info.overrideSpellID then
		ids[#ids + 1] = info.overrideSpellID
	end
	if type(info.linkedSpellIDs) == "table" then
		for _, spellID in ipairs(info.linkedSpellIDs) do
			ids[#ids + 1] = spellID
		end
	end
	return ids
end

local function IconMatches(rt, ids)
	for _, spellID in ipairs(ids) do
		if rt.ids[spellID] then
			return true
		end
		local name = ns.GetSpellNameAndIcon(spellID)
		if name and rt.names[name] then
			return true
		end
	end
	return false
end

-- Remembers every spell the Cooldown Manager can show for this character, for the status column.
function CDM:CollectAvailable()
	wipe(self.availableIds)
	wipe(self.availableNames)
	if not (C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCategorySet and Enum.CooldownViewerCategory) then
		return
	end
	for _, category in pairs(Enum.CooldownViewerCategory) do
		local ok, cooldownIDs = pcall(C_CooldownViewer.GetCooldownViewerCategorySet, category, true)
		if ok and type(cooldownIDs) == "table" then
			for _, cooldownID in ipairs(cooldownIDs) do
				local info = GetCooldownInfo(cooldownID)
				if info and (info.hasAura or info.selfAura) then
					for _, spellID in ipairs(InfoSpellIDs(info)) do
						self.availableIds[spellID] = true
						local name = ns.GetSpellNameAndIcon(spellID)
						if name then
							self.availableNames[name] = true
						end
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------
-- Claiming Blizzard icons
------------------------------------------------------------------------

function CDM:FindIcon(ids)
	for _, icon in ipairs(ns.profile.icons) do
		local rt = RT[icon]
		if rt and rt.slot and rt.source == "own" and not icon.disabled and icon.track ~= "cooldown" then
			local group = rt.slot.groupFrame.group
			if group and not group.hidden and IconMatches(rt, ids) then
				return icon
			end
		end
	end
end

function CDM:Rebuild()
	if not ns.profile or self.rebuilding then
		return
	end
	self.rebuilding = true

	local previous = self.claims
	self.claims = {}
	-- Icons shown by Blizzard's aura container (NativeAuras.lua) are left alone.
	for _, icon in ipairs(ns.profile.icons) do
		local rt = RT[icon]
		if rt and rt.source == "cdm" then
			rt.source = "own"
		end
	end

	self:CollectAvailable()

	local viewer = self:GetViewer()
	if viewer and self:IsEnabled() then
		for _, item in ipairs(EnumerateItems(viewer)) do
			local info = GetItemInfo(item)
			if info then
				local icon = self:FindIcon(InfoSpellIDs(info))
				if icon then
					self.claims[item] = icon
					RT[icon].source = "cdm"
				end
			end
		end
	end

	self:Reanchor()

	-- Hand icons sFilter no longer uses back to Blizzard's own layout.
	local released = false
	for item in pairs(previous) do
		if not self.claims[item] then
			released = true
			break
		end
	end
	if released and viewer and not InCombatLockdown() and type(viewer.Layout) == "function" then
		pcall(viewer.Layout, viewer)
	end

	self.rebuilding = false
	ns.Tracker:MarkAll()
end

function CDM:Reanchor()
	for item, icon in pairs(self.claims) do
		local rt = RT[icon]
		local slot = rt and rt.slot
		if slot then
			item:ClearAllPoints()
			item:SetPoint("CENTER", slot, "CENTER")
			local ok, width = pcall(item.GetWidth, item)
			local parent = item:GetParent()
			if ok and width and not ns.IsSecret(width) and width > 0 and parent then
				local target = slot:GetWidth() * slot:GetEffectiveScale()
				item:SetScale(target / (width * parent:GetEffectiveScale()))
			end
		end
	end
end

------------------------------------------------------------------------
-- Settings helpers
------------------------------------------------------------------------

-- True when the Cooldown Manager knows one of the icon's spells (so it can be added to Tracked Buffs).
function CDM:CanTrack(icon)
	local rt = RT[icon]
	if not rt then
		return false
	end
	for spellID in pairs(rt.ids) do
		if self.availableIds[spellID] then
			return true
		end
	end
	for name in pairs(rt.names) do
		if self.availableNames[name] then
			return true
		end
	end
	return false
end

function CDM:GetStatus()
	local viewer = self:GetViewer()
	local available, reason = self:IsAvailable()
	local hideWhenInactive
	if viewer and type(viewer.GetHideWhenInactive) == "function" then
		local ok, value = pcall(viewer.GetHideWhenInactive, viewer)
		hideWhenInactive = ok and value or false
	end
	local claimed = 0
	for _ in pairs(self.claims) do
		claimed = claimed + 1
	end
	return {
		available = available,
		reason = reason,
		enabled = self:IsEnabled(),
		viewer = viewer ~= nil,
		viewerShown = viewer ~= nil and viewer:IsShown(),
		hideWhenInactive = hideWhenInactive,
		claimed = claimed,
	}
end

function CDM:Enable()
	if C_CVar and C_CVar.SetCVar then
		C_CVar.SetCVar("cooldownViewerEnabled", "1")
	end
	C_Timer.After(0.5, function()
		CDM:TryHook()
		CDM:Rebuild()
	end)
end

function CDM:OpenSettings()
	if not _G.CooldownViewerSettings and C_AddOns and C_AddOns.LoadAddOn then
		pcall(C_AddOns.LoadAddOn, "Blizzard_CooldownViewer")
	end
	local settings = _G.CooldownViewerSettings
	if settings and type(settings.TogglePanel) == "function" then
		settings:TogglePanel()
	elseif settings then
		settings:SetShown(not settings:IsShown())
	end
end

-- Adds an icon for every Tracked Buff of the Cooldown Manager that no sFilter icon covers yet.
-- Returns the number of icons added.
function CDM:ImportTrackedBuffs(profile)
	local infos = {}
	local viewer = self:GetViewer()
	if viewer and self:IsEnabled() then
		for _, item in ipairs(EnumerateItems(viewer)) do
			local info = GetItemInfo(item)
			if info then
				infos[#infos + 1] = info
			end
		end
	elseif C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCategorySet and Enum.CooldownViewerCategory then
		local ok, cooldownIDs = pcall(C_CooldownViewer.GetCooldownViewerCategorySet, Enum.CooldownViewerCategory.TrackedBuff, false)
		if ok and type(cooldownIDs) == "table" then
			for _, cooldownID in ipairs(cooldownIDs) do
				local info = GetCooldownInfo(cooldownID)
				if info then
					infos[#infos + 1] = info
				end
			end
		end
	end

	local group = ns.Profile.GetGroup(profile, "cdm")
	local added = 0
	for _, info in ipairs(infos) do
		local ids = InfoSpellIDs(info)
		local covered = #ids == 0
		for _, icon in ipairs(profile.icons) do
			local rt = RT[icon] or ns.Tracker:Resolve(icon)
			if IconMatches(rt, ids) or tContains(icon.spells, ids[1]) then
				covered = true
				break
			end
		end
		if not covered and #profile.icons < ns.Profile.LIMITS.icons then
			if not group then
				group = ns.Profile.AddGroup(profile, L["Cooldown Manager"])
				if not group then
					break
				end
				group.key = "cdm"
				group.y = -140
				group.x = 116
			end
			local selfAura = info.selfAura
			local newIcon = {
				spells = { info.spellID or ids[1] },
				track = "aura",
				unit = selfAura and "player" or "target",
				filter = selfAura and "HELPFUL" or "HARMFUL",
				anySource = {},
				group = group.key,
				slot = ns.Profile.NextFreeSlot(profile, group.key),
				disabled = false,
			}
			profile.icons[#profile.icons + 1] = newIcon
			ns.Tracker:Resolve(newIcon)
			added = added + 1
		end
	end
	return added
end
