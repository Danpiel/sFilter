-- Saved variables, profile validation and export/import.
--
-- One profile per class (and per game: Forever and retail have separate spell lists). Every profile
-- that enters the addon, from SavedVariables or from an import string, goes through Sanitize, so the
-- rest of the code can trust its shape.

local _, ns = ...
local L = ns.L

local Profile = {}
ns.Profile = Profile

local DB_VERSION = 1
-- Up to 40 spell IDs per icon: Blizzard's aura container matches IDs only, and in Forever every
-- rank of a spell (Seal of Righteousness has nine) has its own ID.
Profile.LIMITS = { groups = 20, icons = 300, spellsPerIcon = 40, slots = 60 }
local LIMITS = Profile.LIMITS

local floor = math.floor

------------------------------------------------------------------------
-- Field validators
------------------------------------------------------------------------

local function Number(value, low, high, default)
	value = tonumber(value)
	if not value or value ~= value then
		return default
	end
	return ns.Clamp(value, low, high)
end

local function Integer(value, low, high, default)
	return ns.Round(Number(value, low, high, default))
end

local function Text(value, maxLength, default)
	if type(value) ~= "string" then
		return default
	end
	value = value:gsub("[%c|]", ""):sub(1, maxLength)
	if value == "" then
		return default
	end
	return value
end

local function OneOf(value, list, default)
	for i = 1, #list do
		if list[i] == value then
			return value
		end
	end
	return default
end

------------------------------------------------------------------------
-- Sanitize
------------------------------------------------------------------------

local function SanitizeGroup(group, index, usedKeys)
	if type(group) ~= "table" then
		return nil
	end

	local key = type(group.key) == "string" and group.key:match("^[%w_%-]+$") and group.key:sub(1, 32) or ("group" .. index)
	while usedKeys[key] do
		key = key .. "_"
	end
	usedKeys[key] = true

	local grow = OneOf(group.grow, ns.DIRECTIONS, "RIGHT")
	local wrap = OneOf(group.wrap, ns.DIRECTIONS, nil)
	if not wrap or ns.IsHorizontal(wrap) == ns.IsHorizontal(grow) then
		wrap = ns.IsHorizontal(grow) and "DOWN" or "RIGHT"
	end

	return {
		key = key,
		name = Text(group.name, 40, key),
		x = Integer(group.x, -5000, 5000, 0),
		y = Integer(group.y, -5000, 5000, 0),
		size = Integer(group.size, 12, 128, 32),
		spacing = Integer(group.spacing, 0, 60, 5),
		perRow = Integer(group.perRow, 1, 40, 6),
		grow = grow,
		wrap = wrap,
		alpha = Number(group.alpha, 0.1, 1, 1),
		-- Seconds before expiry over which an icon fades out (0 = no fade).
		fadeTime = Integer(group.fadeTime, 0, 10, 2),
		-- Flash once when the timer runs out.
		flashOnExpire = group.flashOnExpire == true,
		showInactive = group.showInactive == true,
		hidden = group.hidden == true,
		locked = group.locked == true,
	}
end

local function SanitizeIcon(icon, groupKeys, firstGroupKey)
	if type(icon) ~= "table" or type(icon.spells) ~= "table" then
		return nil
	end

	local spells, seen = {}, {}
	for i = 1, #icon.spells do
		local spellID = tonumber(icon.spells[i])
		if spellID and spellID > 0 and spellID < 2147483647 and spellID == floor(spellID) and not seen[spellID] then
			seen[spellID] = true
			spells[#spells + 1] = spellID
			if #spells >= LIMITS.spellsPerIcon then
				break
			end
		end
	end
	if #spells == 0 then
		return nil
	end

	-- Spells whose auras count from any caster; the others count only when cast by you or your
	-- pet. Profiles from before the per-spell switch had one "mine" flag for the whole icon.
	local any = {}
	if type(icon.anySource) == "table" then
		for _, spellID in pairs(icon.anySource) do
			spellID = tonumber(spellID)
			if spellID then
				any[spellID] = true
			end
		end
	elseif icon.mine == false then
		for _, spellID in ipairs(spells) do
			any[spellID] = true
		end
	end
	local anySource = {}
	for _, spellID in ipairs(spells) do
		if any[spellID] then
			anySource[#anySource + 1] = spellID
		end
	end

	return {
		spells = spells,
		-- "aura": shown while one of the spells is an aura on the unit;
		-- "cooldown": shown while the spell's cooldown runs (ground effects such as Consecration).
		track = OneOf(icon.track, ns.TRACKS, "aura"),
		unit = OneOf(icon.unit, ns.UNITS, "player"),
		filter = OneOf(icon.filter, ns.FILTERS, "HELPFUL"),
		anySource = anySource,
		group = groupKeys[icon.group] and icon.group or firstGroupKey,
		slot = Integer(icon.slot, 1, LIMITS.slots, 1),
		disabled = icon.disabled == true,
	}
end

-- Returns a validated copy of a profile, or nil and an error message.
function Profile.Sanitize(source)
	if type(source) ~= "table" then
		return nil, "not a table"
	end

	local clean = { groups = {}, icons = {} }

	local usedKeys = {}
	if type(source.groups) == "table" then
		for i = 1, math.min(#source.groups, LIMITS.groups) do
			local group = SanitizeGroup(source.groups[i], i, usedKeys)
			if group then
				clean.groups[#clean.groups + 1] = group
			end
		end
	end
	if #clean.groups == 0 then
		for i, group in ipairs(ns.Defaults.Groups()) do
			clean.groups[i] = SanitizeGroup(group, i, usedKeys)
		end
	end

	local groupKeys = {}
	for _, group in ipairs(clean.groups) do
		groupKeys[group.key] = true
	end

	if type(source.icons) == "table" then
		for i = 1, math.min(#source.icons, LIMITS.icons) do
			local icon = SanitizeIcon(source.icons[i], groupKeys, clean.groups[1].key)
			if icon then
				clean.icons[#clean.icons + 1] = icon
			end
		end
	end

	return clean
end

function Profile.CreateDefault(gameKey, class)
	return Profile.Sanitize({
		groups = ns.Defaults.Groups(),
		icons = ns.Defaults.Icons(gameKey, class),
	})
end

------------------------------------------------------------------------
-- Saved variables
------------------------------------------------------------------------

function ns:InitDB()
	if type(sFilterDB) ~= "table" then
		sFilterDB = {}
	end
	local db = sFilterDB
	db.dbVersion = DB_VERSION
	if type(db.profiles) ~= "table" then
		db.profiles = {}
	end
	if type(db.settings) ~= "table" then
		db.settings = {}
	end
	self.db = db
	self:ImportLegacyDB()
end

-- Settings saved while the addon was called DSFilter: group positions and look are kept, the
-- spell lists are replaced by the current presets. The old saved variable is cleared afterwards.
function ns:ImportLegacyDB()
	local legacy = _G.DSFilterDB
	if type(legacy) ~= "table" then
		return
	end
	if type(legacy.profiles) == "table" then
		self.db.legacyGroups = self.db.legacyGroups or {}
		for key, profile in pairs(legacy.profiles) do
			if self.db.profiles[key] == nil and type(profile) == "table" and type(profile.groups) == "table" then
				self.db.legacyGroups[key] = profile.groups
			end
		end
	end
	if type(legacy.settings) == "table" then
		for setting, value in pairs(legacy.settings) do
			if self.db.settings[setting] == nil then
				self.db.settings[setting] = value
			end
		end
	end
	_G.DSFilterDB = nil
end

function ns:ProfileKey()
	return self.gameKey .. ":" .. self.playerClass
end

-- New default profile, laid out with the groups from a DSFilter profile if there is one.
function Profile.CreateFromLegacy(gameKey, class, legacyGroups)
	local profile = Profile.CreateDefault(gameKey, class)
	if type(legacyGroups) ~= "table" then
		return profile
	end
	local groups = Profile.Sanitize({ groups = legacyGroups }).groups
	for _, default in ipairs(profile.groups) do
		local group = Profile.GetGroup({ groups = groups }, default.key)
		if group then
			-- Presets may have grown; keep every slot of a default group in one row.
			group.perRow = math.max(group.perRow, default.perRow)
		end
	end
	return Profile.Sanitize({ groups = groups, icons = profile.icons })
end

-- Passive auras (talent and rune effects the player cannot react to) that earlier presets
-- contained. Revision 2 strips them from saved profiles; an icon left without spells goes away,
-- so a shared icon such as "Ignite, Living Bomb" keeps its active part.
local PROFILE_REVISION = 5

local CONSECRATION_DEBUFF = {
	group = "debuff", track = "aura", unit = "target", filter = "HARMFUL", anySource = {},
	spells = { 1280345, 1280346, 1280347, 1280348, 1280349, 1280353 },
}

-- Icons added to the presets after a profile was created (revision -> game -> class -> icon).
local ADDED_ICONS = {
	[3] = { forever = { PALADIN = CONSECRATION_DEBUFF } },
}

-- Revision 4: Consecration was first tracked by its cooldown; it is a debuff on the target
-- while it stands in the area, so such icons become the debuff icon in place.
local function ConvertConsecration(profile)
	for _, icon in ipairs(profile.icons) do
		if icon.track == "cooldown" and tContains(icon.spells, 26573) then
			icon.track = CONSECRATION_DEBUFF.track
			icon.unit = CONSECRATION_DEBUFF.unit
			icon.filter = CONSECRATION_DEBUFF.filter
			icon.anySource = {}
			icon.spells = ns.CopyTable(CONSECRATION_DEBUFF.spells)
		end
	end
end

-- Revision 5: whose auras count became a per-spell switch, and the presets now default to
-- "yours" for damage spells and "anyone's" for other debuffs. Every spell of a saved icon that the
-- class preset knows takes the preset's setting; spells you added yourself keep theirs.
local function ApplyPresetSources(profile, gameKey, class)
	local preset = ns.Defaults.presets[gameKey] and ns.Defaults.presets[gameKey][class]
	local presetAny = {}
	for _, icon in ipairs(preset or {}) do
		local any = {}
		for _, spellID in ipairs(icon.anySource) do
			any[spellID] = true
		end
		for _, spellID in ipairs(icon.spells) do
			presetAny[spellID] = any[spellID] or false
		end
	end
	for _, icon in ipairs(profile.icons) do
		local any = {}
		for _, spellID in ipairs(icon.anySource or {}) do
			any[spellID] = true
		end
		local anySource = {}
		for _, spellID in ipairs(icon.spells) do
			local fromPreset = presetAny[spellID]
			if fromPreset == nil then
				fromPreset = any[spellID] or false
			end
			if fromPreset then
				anySource[#anySource + 1] = spellID
			end
		end
		icon.anySource = anySource
	end
end

local REMOVED_PASSIVE_IDS = {
	6150, 12579, 12654, 12966, 14143, 15258, 15271, 16177, 16246, 16257, 16886, 17794, 19615,
	20050, 20128, 32390, 51714, 53365, 194879, 196741, 262115, 316220, 325092, 384267, 390978,
	402906, 409507, 412325, 412326, 412538, 412545, 412609, 412800, 415362, 415407, 425714,
	425718, 427714, 428728, 431606, 461615,
}

function Profile.Migrate(profile, revision, gameKey, class)
	revision = revision or 1
	if revision < 4 then
		ConvertConsecration(profile)
	end
	for added = revision + 1, PROFILE_REVISION do
		local icon = ADDED_ICONS[added] and ADDED_ICONS[added][gameKey] and ADDED_ICONS[added][gameKey][class]
		local present = false
		for _, existing in ipairs(icon and profile.icons or {}) do
			if tContains(existing.spells, icon.spells[1]) then
				present = true
			end
		end
		if icon and not present then
			local newIcon = ns.CopyTable(icon)
			newIcon.group = Profile.GetGroup(profile, icon.group) and icon.group or profile.groups[1].key
			newIcon.slot = Profile.NextFreeSlot(profile, newIcon.group)
			newIcon.disabled = false
			profile.icons[#profile.icons + 1] = newIcon
		end
	end
	if revision < 2 then
		local removed = {}
		for _, spellID in ipairs(REMOVED_PASSIVE_IDS) do
			removed[spellID] = true
		end
		for index = #profile.icons, 1, -1 do
			local icon = profile.icons[index]
			for spellIndex = #icon.spells, 1, -1 do
				if removed[icon.spells[spellIndex]] then
					table.remove(icon.spells, spellIndex)
				end
			end
			if #icon.spells == 0 then
				table.remove(profile.icons, index)
			end
		end
	end
	if revision < 5 then
		ApplyPresetSources(profile, gameKey, class)
	end
	return PROFILE_REVISION
end

function ns:LoadProfile()
	local key = self:ProfileKey()
	if type(self.db.revisions) ~= "table" then
		self.db.revisions = {}
	end
	local profile = Profile.Sanitize(self.db.profiles[key])
	if profile then
		self.db.revisions[key] = Profile.Migrate(profile, self.db.revisions[key], self.gameKey, self.playerClass)
	else
		local legacyGroups = self.db.legacyGroups and self.db.legacyGroups[key]
		profile = Profile.CreateFromLegacy(self.gameKey, self.playerClass, legacyGroups)
		if self.db.legacyGroups then
			self.db.legacyGroups[key] = nil
		end
		self.db.revisions[key] = PROFILE_REVISION
	end
	self.db.profiles[key] = profile
	self.profile = profile
end

function ns:SetProfile(profile)
	self.db.profiles[self:ProfileKey()] = profile
	self.profile = profile
	self:RefreshAll()
end

function ns:ResetProfile()
	self:SetProfile(Profile.CreateDefault(self.gameKey, self.playerClass))
end

------------------------------------------------------------------------
-- Group helpers used by the settings window and movers
------------------------------------------------------------------------

function Profile.GetGroup(profile, key)
	for index, group in ipairs(profile.groups) do
		if group.key == key then
			return group, index
		end
	end
end

function Profile.AddGroup(profile, name)
	if #profile.groups >= LIMITS.groups then
		return nil
	end
	local index = #profile.groups + 1
	local key
	repeat
		key = "group" .. index
		index = index + 1
	until not Profile.GetGroup(profile, key)

	local group = {
		key = key, name = name or key, x = 0, y = 0, size = 32, spacing = 5, perRow = 6,
		grow = "RIGHT", wrap = "DOWN", alpha = 1, fadeTime = 2, flashOnExpire = false,
		showInactive = false, hidden = false, locked = false,
	}
	profile.groups[#profile.groups + 1] = group
	return group
end

-- Deletes a group and moves its icons into the first remaining group.
function Profile.DeleteGroup(profile, key)
	if #profile.groups <= 1 then
		return false
	end
	local _, index = Profile.GetGroup(profile, key)
	if not index then
		return false
	end
	table.remove(profile.groups, index)
	local fallback = profile.groups[1].key
	for _, icon in ipairs(profile.icons) do
		if icon.group == key then
			icon.group = fallback
		end
	end
	return true
end

function Profile.ResetGroupPosition(group)
	for _, default in ipairs(ns.Defaults.Groups()) do
		if default.key == group.key then
			group.x, group.y = default.x, default.y
			return
		end
	end
	group.x, group.y = 0, 0
end

-- Next free slot number in a group.
function Profile.NextFreeSlot(profile, groupKey)
	local used = {}
	for _, icon in ipairs(profile.icons) do
		if icon.group == groupKey then
			used[icon.slot] = true
		end
	end
	for slot = 1, LIMITS.slots do
		if not used[slot] then
			return slot
		end
	end
	return LIMITS.slots
end

------------------------------------------------------------------------
-- Export / import
------------------------------------------------------------------------

local LAYOUT_FIELDS = {
	"x", "y", "size", "spacing", "perRow", "grow", "wrap", "alpha", "fadeTime", "flashOnExpire",
	"showInactive", "hidden", "locked", "name",
}

-- scope: "all" (groups and icons) or "layout" (group positions and look only).
function Profile.Export(profile, scope)
	local data = {
		addon = "sFilter",
		version = 1,
		scope = scope == "layout" and "layout" or "all",
		game = ns.gameKey,
		class = ns.playerClass,
		profile = { groups = ns.CopyTable(profile.groups) },
	}
	if data.scope == "all" then
		data.profile.icons = ns.CopyTable(profile.icons)
	end
	return ns.Serializer.Encode(data)
end

-- Returns ok, data or false, errorMessage.
function Profile.ParseImport(text)
	local ok, data = ns.Serializer.Decode(text)
	if not ok then
		return false, data
	end
	local fromAddon = type(data) == "table" and (data.addon == "sFilter" or data.addon == "DSFilter")
	if not fromAddon or type(data.profile) ~= "table" then
		return false, L["The string does not contain sFilter settings."]
	end
	if data.scope ~= "layout" then
		data.scope = "all"
	end
	return true, data
end

-- Applies a parsed import to a copy of the given profile and returns the new profile.
-- mode "all" replaces groups and icons; mode "layout" only updates group positions and look,
-- adding groups that do not exist yet.
function Profile.ApplyImport(current, data, mode)
	local imported = Profile.Sanitize(data.profile)
	if not imported then
		return nil, L["The string does not contain sFilter settings."]
	end

	if mode == "all" and data.scope == "all" then
		return imported
	end

	local result = ns.CopyTable(current)
	for _, importedGroup in ipairs(imported.groups) do
		local group = Profile.GetGroup(result, importedGroup.key)
		if group then
			for _, field in ipairs(LAYOUT_FIELDS) do
				group[field] = importedGroup[field]
			end
		elseif #result.groups < LIMITS.groups then
			result.groups[#result.groups + 1] = importedGroup
		end
	end
	return Profile.Sanitize(result)
end
