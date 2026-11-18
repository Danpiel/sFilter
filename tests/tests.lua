-- sFilter tests. Globals provided by the runner: TEST_DIR, ADDON_DIR, SCENARIO.
package.path = TEST_DIR .. "/?.lua;" .. package.path
local M = require("wowmock")

M.toc = SCENARIO == "retail" and 120100 or 16001
M.locale = SCENARIO == "enUS" and "enUS" or "ruRU"
-- "legacy" simulates a client without Blizzard's CustomAuraContainer (own engine + CDM only).
M.auraContainer = SCENARIO ~= "legacy"
M.Install(_G)

if SCENARIO == "migrate" then
	-- Saved while the addon was called DSFilter.
	DSFilterDB = {
		profiles = { ["forever:WARLOCK"] = {
			groups = {
				{ key = "def", x = 10, y = 20 },
				{ key = "buff", x = 10, y = -20 },
				{ key = "debuff", name = "Old debuffs", x = 500, y = -300, size = 40 },
				{ key = "proc", x = 1, y = 2, perRow = 2 },
			},
			icons = { { spells = { 706 }, unit = "player", filter = "HELPFUL", group = "def", slot = 1 } },
		} },
		settings = { grid = true },
	}
end

local passed, failed = 0, 0
local function check(cond, label)
	if cond then
		passed = passed + 1
	else
		failed = failed + 1
		print("FAIL [" .. SCENARIO .. "] " .. label)
	end
end

local function deepEqual(a, b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for k, v in pairs(a) do if not deepEqual(v, b[k]) then return false end end
	for k in pairs(b) do if a[k] == nil then return false end end
	return true
end

-- Fake ElvUI ---------------------------------------------------------------
local elv = { calls = {} }
if SCENARIO == "elvui" then
	local Widget = getmetatable(M.newWidget("Frame")).__index
	local mt = getmetatable(M.newWidget("Frame"))
	local orig = mt.__index
	mt.__index = function(t, k)
		if k == "SetTemplate" then return function(self, tpl) self.__template = tpl or "Default"; elv.calls.SetTemplate = (elv.calls.SetTemplate or 0) + 1 end end
		if k == "FontTemplate" then return function(self, font, size) self.__font = "ElvFont"; self.__elvFont = size or true end end
		if k == "SetInside" then return function(self) end end
		return orig(t, k)
	end
	local S = {}
	for _, name in ipairs({ "HandleButton", "HandleCloseButton", "HandleEditBox", "HandleCheckBox", "HandleDropDownBox", "HandleTrimScrollBar", "HandleSliderFrame" }) do
		S[name] = function() elv.calls[name] = (elv.calls[name] or 0) + 1 end
	end
	local E = {
		media = { normFont = "ElvFont", rgbvaluecolor = { r = 0, g = 0.5, b = 1 } },
		TexCoords = { 0.1, 0.9, 0.1, 0.9 },
		RegisterCooldown = function(_, cd, which) elv.calls.RegisterCooldown = which end,
		GetModule = function(_, name) return name == "Skins" and S or nil end,
		ToggleMovers = function() end,
	}
	_G.ElvUI = { E, {}, {}, {} }
	elv.E, elv.S = E, S
end

-- Load the addon in TOC order ---------------------------------------------
local ns = {}
local files = {}
for line in io.lines(ADDON_DIR .. "/sFilter.toc") do
	if line:match("%.lua%s*$") then
		files[#files + 1] = line:gsub("%s+$", "")
	end
end
check(#files == 11, "toc lists 11 lua files")
for _, file in ipairs(files) do
	local chunk = assert(loadfile(ADDON_DIR .. "/" .. file))
	chunk("sFilter", ns)
end

-- Spell database: every preset spell exists; a few get real names.
for _, game in pairs(ns.Defaults.presets) do
	for _, icons in pairs(game) do
		for _, icon in ipairs(icons) do
			for _, id in ipairs(icon.spells) do
				M.spells[id] = M.spells[id] or { name = "Spell" .. id }
			end
		end
	end
end
local names = {
	[172] = "Corruption", [6222] = "Corruption", [980] = "Curse of Agony", [348] = "Immolate",
	[440892] = "Curse of the Elements", [17794] = "Shadow Vulnerability", [17941] = "Shadow Trance",
	[706] = "Demon Armor", [755] = "Health Funnel", [25311] = "Corruption",
}
for id, name in pairs(names) do
	M.spells[id] = { name = name, harmful = id ~= 17941 and id ~= 706 and id ~= 755 }
end

M.cdmInfos[11] = { cooldownID = 11, spellID = 980, linkedSpellIDs = {}, selfAura = false, hasAura = true, category = 2 }
M.cdmInfos[12] = { cooldownID = 12, spellID = 424242, linkedSpellIDs = {}, selfAura = true, hasAura = true, category = 2 }
M.cdmInfos[13] = { cooldownID = 13, spellID = 18265, linkedSpellIDs = {}, selfAura = false, hasAura = true, category = 3 }
local viewer = M.MakeViewer(_G, { 11, 12 })

M.FireEvent("ADDON_LOADED", "sFilter")
M.FireEvent("PLAYER_LOGIN")
M.FireEvent("PLAYER_ENTERING_WORLD")

local function tick()
	local frame = ns.Tracker.eventFrame
	frame.__scripts.OnUpdate(frame, 0.25)
end
tick()

local RT = ns.RT
local function findIcon(spellID)
	for _, icon in ipairs(ns.profile.icons) do
		if icon.spells[1] == spellID then return icon end
	end
end

-- Basics -------------------------------------------------------------------
local game = SCENARIO == "retail" and "retail" or "forever"
check(ns.isForever == (game == "forever"), "game detection")
check(sFilterDB and sFilterDB.profiles[game .. ":WARLOCK"] == ns.profile, "profile stored per game and class")
if SCENARIO == "migrate" then
	check(DSFilterDB == nil, "old DSFilter saved variable cleared")
	local debuffGroup = ns.Profile.GetGroup(ns.profile, "debuff")
	check(debuffGroup and debuffGroup.x == 500 and debuffGroup.size == 40 and debuffGroup.name == "Old debuffs", "group layout carried over")
	check(ns.Profile.GetGroup(ns.profile, "proc").perRow == 4, "proc row widened for the new presets")
	check(#ns.profile.icons == #ns.Defaults.presets.forever.WARLOCK, "icons come from the new presets")
	check(ns.db.settings.grid == true, "settings carried over")
	local legacyString = "!DSF1!" .. ns.Serializer.Encode({ addon = "DSFilter", scope = "layout", profile = { groups = {} } }):sub(6)
	check(ns.Profile.ParseImport(legacyString), "old DSFilter export strings still import")
	return print(string.format("RESULT %s passed=%d failed=%d", SCENARIO, passed, failed))
end
check(#ns.profile.groups == 4, "four default groups")
check(#ns.profile.icons == #ns.Defaults.presets[game].WARLOCK, "default warlock icons all valid")

for gameKey, classes in pairs(ns.Defaults.presets) do
	for class, icons in pairs(classes) do
		local profile = ns.Profile.Sanitize({ groups = ns.Defaults.Groups(), icons = ns.Defaults.Icons(gameKey, class) })
		check(#profile.icons == #icons, "preset " .. gameKey .. " " .. class .. " survives sanitize")
		local slots = {}
		for _, icon in ipairs(profile.icons) do
			check(ns.Profile.GetGroup(profile, icon.group) ~= nil, "preset group exists " .. class)
			local group = ns.Profile.GetGroup(profile, icon.group)
			check(icon.slot <= group.perRow, "preset " .. gameKey .. " " .. class .. " slot fits in one row (" .. icon.group .. " #" .. icon.slot .. ")")
		end
	end
end

if SCENARIO == "enUS" then
	check(ns.L["Buffs"] == "Buffs", "english fallback")
	return print(string.format("RESULT %s passed=%d failed=%d", SCENARIO, passed, failed))
end
if SCENARIO ~= "retail" then
	check(ns.L["Buffs"] == "Баффы", "russian locale")
end

-- Layout geometry ------------------------------------------------------------
local D = ns.Display
local g = { grow = "RIGHT", wrap = "DOWN", perRow = 3, size = 32, spacing = 5 }
check(D.GetOrigin(g) == "TOPLEFT", "origin RIGHT/DOWN")
check(D.GetOrigin({ grow = "LEFT", wrap = "UP" }) == "BOTTOMRIGHT", "origin LEFT/UP")
check(D.GetOrigin({ grow = "UP", wrap = "LEFT" }) == "BOTTOMRIGHT", "origin UP/LEFT")
check(D.GetOrigin({ grow = "DOWN", wrap = "RIGHT" }) == "TOPLEFT", "origin DOWN/RIGHT")
local x, y = D.GetSlotOffset(g, 5)
check(x == 37 and y == -37, "slot 5 offset")
local w, h = D.GetGroupSize(g, 5)
check(w == 106 and h == 69, "group size")
local g2 = { grow = "UP", wrap = "LEFT", perRow = 2, size = 10, spacing = 0 }
x, y = D.GetSlotOffset(g2, 3)
check(x == -10 and y == 0, "vertical wrap offset")

if SCENARIO == "legacy" then
	-- Own engine without Blizzard's aura container -------------------------
	check(not ns.Native.available, "no aura container in legacy client")
	M.now = 85 -- before the test auras expire (they end at 100)
	-- Aura matching out of combat ------------------------------------------
	M.auras.target = {
		{ spellId = 6222, name = "Corruption", icon = 136118, applications = 0, duration = 18, expirationTime = 100, isHelpful = false, sourceUnit = "player", isFromPlayerOrPlayerPet = true },
		{ spellId = 440892, name = "Curse of the Elements", icon = 1, applications = 0, duration = 300, expirationTime = 400, isHelpful = false, sourceUnit = "party1", isFromPlayerOrPlayerPet = false },
		{ spellId = 348, name = "Immolate", icon = 2, applications = 0, duration = 15, expirationTime = 50, isHelpful = false, sourceUnit = "party1", isFromPlayerOrPlayerPet = false },
	}
	M.auras.player = {
		{ spellId = 17941, name = "Shadow Trance", icon = 3, applications = 3, duration = 10, expirationTime = 30, isHelpful = true, sourceUnit = "player", isFromPlayerOrPlayerPet = true },
	}
	M.FireEvent("UNIT_AURA", "target")
	M.FireEvent("UNIT_AURA", "player")
	M.FireEvent("UNIT_AURA", "raid1")
	tick()

	local corruption, curses, immolate, trance = findIcon(172), findIcon(440892), findIcon(348), findIcon(17941)
	check(RT[corruption].state.active, "corruption rank 2 matched by name")
	check(RT[corruption].slot:IsShown(), "corruption slot shown")
	check(RT[corruption].slot.cooldown.__cd and RT[corruption].slot.cooldown.__cd[1] == 82, "cooldown start set")
	check(RT[curses].state.active, "curse from another player shown (any source)")
	check(not RT[immolate].state.active, "immolate from another player hidden (mine only)")
	check(not RT[immolate].slot:IsShown(), "immolate slot hidden")
	check(RT[trance].state.active and RT[trance].slot.count:GetText() == 3, "proc stack count")

	-- Whose auras count is set per spell ----------------------------------------
	check(#immolate.anySource == 0 and #curses.anySource == #curses.spells, "presets: damage spell yours, curse anyone's")
	immolate.anySource = { 348 }
	ns:RefreshAll()
	check(RT[immolate].state.active, "immolate from another player shown once switched to anyone's")
	immolate.anySource = {}
	ns:RefreshAll()
	check(not RT[immolate].state.active, "and hidden again when switched back to yours")
	local curseSources = curses.anySource
	curses.anySource = {}
	ns:RefreshAll()
	check(not RT[curses].state.active, "curse from another player hidden when switched to yours")
	curses.anySource = curseSources
	-- Ranks follow their spell by name: switching one Corruption ID covers every rank.
	corruption.anySource = { 25311 }
	ns:RefreshAll()
	check(RT[corruption].anyIds[172] and RT[corruption].anyIds[6222] and not RT[corruption].anyIds[6223], "ranks share the source through the spell name")
	corruption.anySource = {}
	ns:RefreshAll()
	check(RT[corruption].state.active and RT[curses].state.active, "sources restored")

	-- Restricted (secret) mode ------------------------------------------------
	M.secret = true
	tick()
	check(not RT[corruption].state.active and RT[corruption].state.blocked, "secret: unreadable aura hidden")
	check(not RT[corruption].slot:IsShown(), "secret: slot hidden")
	M.whitelist[172] = true
	table.insert(M.auras.target, { spellId = 172, name = "Corruption", icon = 9, applications = 0, duration = 12, expirationTime = 60, isHelpful = false, sourceUnit = "player", isFromPlayerOrPlayerPet = true })
	ns:RefreshAll()
	check(RT[corruption].state.active, "secret: whitelisted spell readable")
	check(ns.Tracker:CombatStatus(corruption) == "open", "status open for whitelisted")
	M.secret = false
	M.whitelist[172] = nil
	table.remove(M.auras.target)
	ns:RefreshAll()
	tick()
	check(RT[corruption].state.active, "back out of combat")

	-- Timer text, fade-out and expiry flash (corruption expires at 100, fade starts at 98)
	local cslot = RT[corruption].slot
	local cgroup = cslot.groupFrame.group
	check(ns.FormatTime(75.9) == "1:15" and ns.FormatTime(605) == "10:05" and ns.FormatTime(59.9) == "59" and ns.FormatTime(5) == "5" and ns.FormatTime(-3) == "0", "timer format without leading zeros")
	cgroup.flashOnExpire = true
	M.now = 90
	cslot.__scripts.OnUpdate(cslot, 1)
	check(cslot.timeText:GetText() == "10" and cslot:GetAlpha() == 1, "timer runs, no fade yet")
	M.now = 99
	cslot.__scripts.OnUpdate(cslot, 1)
	check(math.abs(cslot:GetAlpha() - 0.5) < 1e-6 and cslot.timeText:GetText() == "1", "icon fades out in the last seconds")
	check(not (cslot.flash and cslot.flash.animation.__playing), "no flash before expiry")
	M.now = 100.2
	cslot.__scripts.OnUpdate(cslot, 1)
	check(cslot:GetAlpha() == 0 and cslot.flash and cslot.flash.animation.__playing and cslot.flash:IsShown(), "flash when the timer runs out")
	local plays = cslot.flash.animation.__plays
	cslot.__scripts.OnUpdate(cslot, 1)
	check(cslot.flash.animation.__plays == plays, "flashes only once")
	-- The aura is removed right at expiry before the timer ticks: still one flash.
	M.auras.target[1].expirationTime = 110
	M.now = 100
	M.FireEvent("UNIT_AURA", "target")
	tick()
	local before = cslot.flash.animation.__plays
	M.now = 109.8
	table.remove(M.auras.target, 1)
	M.FireEvent("UNIT_AURA", "target")
	tick()
	check(cslot.flash.animation.__plays == before + 1, "flash when the aura is removed at expiry")
	cgroup.flashOnExpire = false
	cgroup.fadeTime = 0
	M.now = 99
	table.insert(M.auras.target, 1, { spellId = 6222, name = "Corruption", icon = 136118, applications = 0, duration = 18, expirationTime = 100, isHelpful = false, sourceUnit = "player", isFromPlayerOrPlayerPet = true })
	ns:RefreshAll()
	cslot.__scripts.OnUpdate(cslot, 1)
	check(cslot:GetAlpha() == 1, "fade can be turned off")
	cgroup.fadeTime = 2
	M.now = 100

	-- Cooldown Manager bridge ---------------------------------------------
	local agony = findIcon(980)
	local item = viewer.__items[1]
	check(RT[agony].source == "cdm", "CDM item claimed for Curse of Agony")
	check(ns.Tracker:CombatStatus(agony) == "cdm", "status cdm")
	local point = item.__points[1]
	check(point and point[2] == RT[agony].slot, "CDM item anchored into the sFilter slot")
	check(math.abs(item.__scale - 32 / 40) < 1e-6, "CDM item scaled to slot size")
	check(viewer.__items[2].__points[1] == nil, "unmatched CDM item untouched")
	viewer:Layout()
	check(item.__points[1][2] == RT[agony].slot, "re-anchored after Blizzard layout")
	check(ns.CDM:GetStatus().claimed == 1, "status counts claimed items")
	check(ns.CDM:CanTrack(findIcon(18265)), "Siphon Life is available in CDM")
	local before = viewer.layoutCalls
	agony.disabled = true
	ns:RefreshAll()
	check(viewer.layoutCalls > before, "released item handed back to Blizzard layout")
	check(RT[agony].source == "own", "disabled icon not claimed")
	agony.disabled = false
	ns:RefreshAll()
	local added = ns.CDM:ImportTrackedBuffs(ns.profile)
	check(added == 1, "import tracked buffs adds the unknown one")
	check(ns.Profile.GetGroup(ns.profile, "cdm") ~= nil, "cdm group created")
	check(ns.CDM:ImportTrackedBuffs(ns.profile) == 0, "import is idempotent")
	ns:RefreshAll()
end

local function containerFor(unit)
	for _, c in ipairs(M.containers or {}) do
		if c.__unit == unit then return c end
	end
end

local function slotOf(button)
	for _, c in ipairs(M.containers or {}) do
		for _, slot in pairs(c.__slots) do
			if slot.button == button then return slot, c end
		end
	end
end

if SCENARIO == "forever" or SCENARIO == "elvui" then
	-- In-combat display through Blizzard's aura container --------------------
	local N = ns.Native
	check(N.available, "aura container available")
	local corruption, curses, immolate, trance, agony = findIcon(172), findIcon(440892), findIcon(348), findIcon(17941), findIcon(980)
	check(RT[corruption].source == "native" and RT[trance].source == "native", "eligible icons use the aura container")
	check(ns.Tracker:CombatStatus(corruption) == "native", "status native")
	check(RT[agony].source == "native" and viewer.__items[1].__points[1] == nil, "CDM leaves icons the container shows")
	check(#N.assigned[corruption] == 1, "one container slot for an icon with one source")
	local button = N.assigned[corruption][1]
	check(button and button.__iconRegion and button.__cooldownRegion and button.__countRegion and button.__timeRegion, "sFilter parts bound to the Blizzard button")
	check(button and button.__points[1] and button.__points[1][2] == RT[corruption].slot and button.__width == 32, "button placed over the sFilter slot")
	local slot = slotOf(button)
	check(slot and slot.filter == "HARMFUL" and slot.filters.isFromPlayerOrPlayerPet == true, "slot filter and mine flag")
	check(slot and slot.filters.includeSpellIDs[172] and slot.filters.includeSpellIDs[25311], "spell list has the icon IDs and the known rank")
	check(slotOf(N.assigned[curses][1]).filters.isFromPlayerOrPlayerPet == nil, "any-source icon has no mine flag")

	M.auras.target = {
		{ spellId = 999001, name = "Corruption", icon = 136118, applications = 0, duration = 18, expirationTime = 100, isHelpful = false, sourceUnit = "player", isFromPlayerOrPlayerPet = true },
		{ spellId = 440892, name = "Curse of the Elements", icon = 1, applications = 0, duration = 300, expirationTime = 400, isHelpful = false, sourceUnit = "party1", isFromPlayerOrPlayerPet = false },
		{ spellId = 348, name = "Immolate", icon = 2, applications = 0, duration = 15, expirationTime = 50, isHelpful = false, sourceUnit = "party1", isFromPlayerOrPlayerPet = false },
	}
	M.auras.player = {
		{ spellId = 17941, name = "Shadow Trance", icon = 3, applications = 3, duration = 10, expirationTime = 30, isHelpful = true, sourceUnit = "player", isFromPlayerOrPlayerPet = true },
	}
	M.FireEvent("UNIT_AURA", "target")
	M.FireEvent("UNIT_AURA", "player")
	tick()
	tick()
	check(ns.db.learned and ns.db.learned.Corruption and ns.db.learned.Corruption[999001], "other rank seen out of combat is learned")
	button = N.assigned[corruption][1]
	slot = slotOf(button)
	check(slot and slot.filters.includeSpellIDs[999001], "learned rank added to the container")
	containerFor("target"):UpdateAllAuras()
	containerFor("player"):UpdateAllAuras()
	check(button.__shown, "corruption shown by the container")
	check(not N.assigned[immolate][1].__shown, "immolate from another player not shown (mine only)")
	check(N.assigned[curses][1].__shown, "curse from another player shown (any source)")
	check(N.assigned[trance][1].__shown, "proc on the player shown")
	check(not RT[corruption].state.active and not RT[corruption].slot:IsShown(), "own icon stays hidden under the Blizzard button")

	-- An icon whose spells mix "yours" and "anyone's" gets two slots over the same place.
	immolate.anySource = { 348 }
	ns:RefreshAll()
	local mixed = N.assigned[immolate]
	check(mixed and #mixed == 2, "mixed-source icon gets two container slots")
	local mineSlot, anySlot = slotOf(mixed[1]), slotOf(mixed[2])
	check(mineSlot.filters.isFromPlayerOrPlayerPet == true and mineSlot.filters.includeSpellIDs[707] and not mineSlot.filters.includeSpellIDs[348], "first slot: spells that count only when yours")
	check(anySlot.filters.isFromPlayerOrPlayerPet == nil and anySlot.filters.includeSpellIDs[348] and not anySlot.filters.includeSpellIDs[707], "second slot: spells that count from anyone")
	check(mixed[2].__points[1] and mixed[2].__points[1][2] == RT[immolate].slot and mixed[1].__points[1][2] == RT[immolate].slot, "both slots placed over the icon")
	containerFor("target"):UpdateAllAuras()
	check(mixed[2].__shown and not mixed[1].__shown, "immolate from another player shown through the anyone's slot")
	immolate.anySource = {}
	ns:RefreshAll()
	check(#N.assigned[immolate] == 1 and N.assigned[corruption][1] == button, "back to one slot, other icons keep theirs")

	-- Combat: auras secret, buttons restricted
	M.secret, M.inCombat = true, true
	tick()
	containerFor("target"):UpdateAllAuras()
	check(button.__shown, "container keeps showing auras in combat")
	local group = ns.Profile.GetGroup(ns.profile, "debuff")
	group.size = 40
	local ok = pcall(ns.RefreshLayout, ns)
	check(ok and N.pending, "layout change in combat is deferred, not an error")
	ok = pcall(ns.RefreshAll, ns)
	check(ok and RT[corruption].source == "native", "rebuild in combat is deferred and keeps the icons")
	local updates = M.containerUpdates
	M.FireEvent("PLAYER_TARGET_CHANGED")
	check(M.containerUpdates > updates, "target change refreshes the container")
	M.secret, M.inCombat = false, false
	M.FireEvent("PLAYER_REGEN_ENABLED")
	check(not N.pending and N.assigned[corruption][1].__width == 40, "deferred changes applied after combat")
	group.size = 32
	ns:RefreshLayout()

	-- Disabled icon frees its container slot
	corruption.disabled = true
	ns:RefreshAll()
	local enabled, nativeTarget = 0, 0
	for _, s in pairs(containerFor("target").__slots) do
		if s.enabled then enabled = enabled + 1 end
	end
	for _, icon in ipairs(ns.profile.icons) do
		if RT[icon].source == "native" and icon.unit == "target" then nativeTarget = nativeTarget + #N.assigned[icon] end
	end
	check(enabled == nativeTarget and RT[corruption].source ~= "native", "unused container slots are switched off")
	corruption.disabled = false
	ns:RefreshAll()
	check(#M.containers <= 4, "one container per unit")

	-- Preview while unlocked / Edit Mode
	EventRegistry:TriggerEvent("EditMode.Enter")
	check(ns.unlocked, "Edit Mode unlocks the groups")
	local preview = RT[corruption].slot
	check(preview:IsShown() and preview.count:GetText() == 3 and preview.cooldown.__cd and preview.cooldown.__cd[2] == 20, "preview shows the icon as procced")
	check(preview.timeText:GetText() == "20", "preview timer text")
	EventRegistry:TriggerEvent("EditMode.Exit")
	check(not ns.unlocked, "leaving Edit Mode locks the groups")

	if SCENARIO == "elvui" then
		check(button.__template == "Default", "ElvUI template on the Blizzard aura button")
	end
end

-- Passive proc cleanup for saved profiles -------------------------------------
do
	local old = { icons = {
		{ spells = { 412538, 400613 } },       -- Ignite + Living Bomb
		{ spells = { 20050 } },                -- Vengeance
		{ spells = { 172, 6222 } },            -- Corruption
	} }
	check(ns.Profile.Migrate(old, nil) == 5, "migration returns the new revision")
	check(#old.icons == 2 and #old.icons[1].spells == 1 and old.icons[1].spells[1] == 400613, "passive part removed, active part kept")
	check(old.icons[2].spells[1] == 172, "unrelated icons untouched")
	local again = { icons = { { spells = { 20050 } } } }
	ns.Profile.Migrate(again, 2)
	check(#again.icons == 1, "migration runs only for older revisions")
	check(sFilterDB.revisions[ns:ProfileKey()] == 5, "revision stored for the profile")
	local presetIDs = {}
	for _, classes in pairs(ns.Defaults.presets) do
		for _, icons in pairs(classes) do
			for _, icon in ipairs(icons) do
				for _, id in ipairs(icon.spells) do presetIDs[id] = true end
			end
		end
	end
	check(not presetIDs[20050] and not presetIDs[12966] and not presetIDs[15271] and not presetIDs[6150], "passive procs are gone from the presets")
	check(presetIDs[413399] and presetIDs[53489] and presetIDs[48108] and presetIDs[440895], "reactive procs stay in the presets")
end

-- Whose auras count: old profiles, revision 5 and export ------------------------
do
	local old = ns.Profile.Sanitize({ groups = ns.Defaults.Groups(), icons = {
		{ spells = { 5782, 6213 }, unit = "target", filter = "HARMFUL", group = "debuff", slot = 6 },             -- Fear, "only mine"
		{ spells = { 172, 6222 }, unit = "target", filter = "HARMFUL", mine = false, group = "debuff", slot = 1 }, -- Corruption, "anyone"
		{ spells = { 999777 }, unit = "target", filter = "HARMFUL", mine = false, group = "debuff", slot = 7 },     -- own spell, "anyone"
		{ spells = { 999778 }, unit = "target", filter = "HARMFUL", group = "debuff", slot = 8 },                 -- own spell, "only mine"
	} })
	check(#old.icons[1].anySource == 0 and deepEqual(old.icons[2].anySource, { 172, 6222 }) and old.icons[2].mine == nil, "old per-icon flag becomes per-spell sources")
	ns.Profile.Migrate(old, 4, "forever", "WARLOCK")
	check(deepEqual(old.icons[1].anySource, { 5782, 6213 }), "crowd control counts from anyone after the update")
	check(#old.icons[2].anySource == 0, "damage over time counts only when yours after the update")
	check(deepEqual(old.icons[3].anySource, { 999777 }) and #old.icons[4].anySource == 0, "spells added by hand keep their source")
	local current = { icons = { { spells = { 5782 }, anySource = {} } } }
	ns.Profile.Migrate(current, 5, "forever", "WARLOCK")
	check(#current.icons[1].anySource == 0, "a switched spell is not reset again later")

	local rogue = ns.Profile.Sanitize({ groups = ns.Defaults.Groups(), icons = ns.Defaults.Icons("forever", "ROGUE") })
	local poisons
	for _, icon in ipairs(rogue.icons) do
		if tContains(icon.spells, 2818) then poisons = icon end
	end
	check(poisons and tContains(poisons.anySource, 13218) and tContains(poisons.anySource, 439473) and not tContains(poisons.anySource, 2818), "preset icon mixes yours (Deadly Poison) and anyone's (Wound Poison)")
	check(poisons and poisons.spells[1] == 2818 and #poisons.spells == 16, "ANY{} keeps the spell order")

	local ok, data = ns.Profile.ParseImport(ns.Profile.Export(ns.profile, "all"))
	local imported = ok and ns.Profile.ApplyImport(ns.profile, data, "all")
	local same = imported and #imported.icons == #ns.profile.icons
	for i, icon in ipairs(same and ns.profile.icons or {}) do
		same = same and deepEqual(imported.icons[i].anySource, icon.anySource)
	end
	check(same, "per-spell sources survive export and import")
end

-- Consecration added to existing Forever paladin profiles ----------------------
do
	local paladin = { groups = { { key = "def" }, { key = "debuff" } }, icons = { { spells = { 853 }, group = "debuff", slot = 1 } } }
	ns.Profile.Migrate(paladin, 2, "forever", "PALADIN")
	local added = paladin.icons[2]
	check(added and added.track == "aura" and added.unit == "target" and added.filter == "HARMFUL" and tContains(added.spells, 1280353) and added.group == "debuff" and added.slot == 2, "Consecration debuff added to an old paladin profile")
	ns.Profile.Migrate(paladin, 2, "forever", "PALADIN")
	check(#paladin.icons == 2, "Consecration is not added twice")
	local warlock = { groups = { { key = "debuff" } }, icons = {} }
	ns.Profile.Migrate(warlock, 2, "forever", "WARLOCK")
	check(#warlock.icons == 0, "other classes get nothing")
	local preset = ns.Defaults.presets.forever.PALADIN
	local found
	for _, icon in ipairs(preset) do
		if tContains(icon.spells, 1280353) then found = icon end
	end
	check(found and found.group == "debuff" and found.unit == "target" and found.filter == "HARMFUL" and (found.track or "aura") == "aura", "Consecration debuff is in the paladin debuff preset")
	-- Yesterday's cooldown icon turns into the debuff icon in place.
	local converted = { groups = { { key = "debuff" } }, icons = { { spells = { 26573, 20116 }, track = "cooldown", unit = "player", filter = "HELPFUL", group = "debuff", slot = 5 } } }
	ns.Profile.Migrate(converted, 3, "forever", "PALADIN")
	local c = converted.icons[1]
	check(#converted.icons == 1 and c.track == "aura" and c.unit == "target" and c.filter == "HARMFUL" and tContains(c.spells, 1280345) and c.slot == 5, "Consecration cooldown icon converted to the debuff in place")
end

-- Cooldown icons (Consecration-style ground effects) ---------------------------
if SCENARIO == "forever" or SCENARIO == "elvui" then
	M.known = { [20116] = true }
	M.cooldowns = {}
	local consecration = { spells = { 26573, 20116, 20922 }, track = "cooldown", unit = "player", filter = "HELPFUL", anySource = {}, group = "debuff", slot = 6, disabled = false }
	table.insert(ns.profile.icons, consecration)
	ns:RefreshAll()
	local crt = RT[consecration]
	check(crt.source == "own" and ns.Tracker:CombatStatus(consecration) == "cooldown", "cooldown icon is drawn by sFilter and works in combat")
	check(not crt.state.active and not crt.slot:IsShown(), "hidden while the spell is ready")

	M.cooldowns[20116] = { start = 100, duration = 8 }
	M.now = 102
	M.FireEvent("SPELL_UPDATE_COOLDOWN")
	tick()
	check(crt.state.active and crt.state.expiration == 108 and crt.slot:IsShown(), "shown while the cooldown runs (known rank)")
	check(crt.slot.timeText:GetText() == "6", "timer text for the cooldown")

	M.cooldowns[20116] = { start = 102, duration = 1.5, gcd = true }
	M.FireEvent("SPELL_UPDATE_COOLDOWN")
	tick()
	check(not crt.state.active, "global cooldown is ignored")

	M.cooldowns[20116] = { start = 100, duration = 8 }
	M.secret, M.now = true, 107
	M.FireEvent("SPELL_UPDATE_COOLDOWN")
	tick()
	check(crt.state.active and crt.state.durationObject and crt.slot:IsShown(), "secret cooldown still shown (isActive is never secret)")
	crt.slot.__scripts.OnUpdate(crt.slot, 1)
	check(math.abs(crt.slot:GetAlpha() - 0.5) < 1e-6, "secret cooldown fades through the curve")
	local text = crt.slot.timeText:GetText()
	check(type(text) == "table" and text.__secret and text.text == "1", "secret timer text comes from the duration object")

	M.now = 109
	M.FireEvent("SPELL_UPDATE_COOLDOWN")
	tick()
	check(not crt.state.active and not crt.slot:IsShown(), "hidden when the cooldown is over")

	M.secret, M.now = false, 100
	table.remove(ns.profile.icons)
	ns:RefreshAll()
end

-- Serializer ------------------------------------------------------------------
local S = ns.Serializer
local sample = { a = 1, b = -2.5, c = "x:y}t{s5:", d = { true, false, { "ю", 1e300 } }, [10] = "ten", e = "" }
local ok, out = S.Deserialize(S.Serialize(sample))
check(ok and deepEqual(out, sample), "serializer roundtrip")
local bytes = {}
for i = 0, 255 do bytes[#bytes + 1] = string.char(i) end
bytes = table.concat(bytes)
for len = 0, 5 do
	local s = bytes:sub(1, 250 + len)
	check(S.DecodeBase64Lua(S.EncodeBase64Lua(s)) == s, "base64 roundtrip " .. len)
end
check(S.EncodeBase64Lua("Man") == "TWFu" and S.EncodeBase64Lua("Ma") == "TWE=", "base64 known values")
check(not S.Deserialize("t") , "unterminated table rejected")
check(not S.Deserialize("s99:abc"), "bad string length rejected")
check(not S.Deserialize("n1;x"), "trailing data rejected")
local deep = "t"
for i = 1, 40 do deep = deep .. "n1;t" end
check(not S.Deserialize(deep), "deep nesting rejected")
check(not (S.Decode("hello")), "non-sFilter string rejected")
check(not (S.Decode("!SF1!r@@@")), "broken base64 rejected")

-- Export / import -----------------------------------------------------------
local P = ns.Profile
local exported = P.Export(ns.profile, "all")
check(exported:sub(1, 6) == "!SF1!r", "export header (no compression API)")
local okImport, data = P.ParseImport(exported)
check(okImport, "parse own export")
local imported = P.ApplyImport(ns.profile, data, "all")
check(deepEqual(imported, ns.profile), "full import equals current profile")
check(P.ParseImport("  \n" .. exported .. "\n "), "whitespace around the string is ignored")

local moved = ns.CopyTable(ns.profile)
moved.groups[1].x, moved.groups[1].y, moved.groups[1].size = 500, -300, 48
moved.icons = {}
local layoutString = P.Export(moved, "layout")
local okLayout, layoutData = P.ParseImport(layoutString)
check(okLayout and layoutData.profile.icons == nil and layoutData.scope == "layout", "layout export has no icons")
local afterLayout = P.ApplyImport(ns.profile, layoutData, "all")
check(afterLayout.groups[1].x == 500 and afterLayout.groups[1].size == 48, "layout import moves group")
check(#afterLayout.icons == #ns.profile.icons, "layout import keeps icons")

local evil = S.Encode({ addon = "sFilter", scope = "all", profile = {
	groups = { { key = "a|b", name = "|cffff0000x\n", x = 1e9, y = "nope", size = 99999, grow = "DIAGONAL", wrap = "RIGHT", perRow = 0 }, "junk" },
	icons = { { spells = { "abc", -5, 1.5, 172, 172 }, unit = "raid1", filter = "BOTH", group = "missing", slot = 1e6 }, { spells = {} }, 5 },
} })
local okEvil, evilData = P.ParseImport(evil)
local clean = okEvil and P.ApplyImport(ns.profile, evilData, "all")
check(clean and #clean.groups == 1 and #clean.icons == 1, "hostile import trimmed")
if clean then
	local cg, ci = clean.groups[1], clean.icons[1]
	check(cg.key == "group1" and cg.name == "cffff0000x" and cg.x == 5000 and cg.y == 0 and cg.size == 128 and cg.perRow == 1, "hostile group sanitized")
	check(cg.grow == "RIGHT" and cg.wrap == "DOWN", "hostile directions fixed")
	check(#ci.spells == 1 and ci.spells[1] == 172 and ci.unit == "player" and ci.filter == "HELPFUL" and ci.group == "group1" and ci.slot == 60, "hostile icon sanitized")
end
check(not P.ParseImport(S.Encode({ addon = "WeakAuras" })), "foreign addon string rejected")

-- Unlock mode and movers ------------------------------------------------------
ns:SetUnlocked(true)
local debuffFrame = D.activeGroups.debuff
check(debuffFrame.mover:IsShown(), "mover visible when unlocked")
check(D.unlockBar and D.unlockBar:IsShown(), "unlock bar visible")
local anySlotHidden = false
for _, slot in pairs(debuffFrame.slots) do
	if slot.used and not slot:IsShown() then anySlotHidden = true end
end
check(not anySlotHidden, "placeholders shown while unlocked")
debuffFrame.__left, debuffFrame.__top = 1076, 519
debuffFrame.mover.__scripts.OnDragStart()
debuffFrame.mover.__scripts.OnDragStop()
check(debuffFrame.group.x == 116 and debuffFrame.group.y == -21, "drag saves origin corner offset")
debuffFrame.__left = 1000
debuffFrame.mover.__scripts.OnDragStart()
debuffFrame.mover.__scripts.OnDragStop()
check(debuffFrame.group.x == 40, "drag moves group")
debuffFrame.group.locked = true
debuffFrame.__left = 1200
debuffFrame.mover.__scripts.OnDragStart()
debuffFrame.mover.__scripts.OnDragStop()
check(debuffFrame.group.x == 40, "pinned group does not move")
debuffFrame.mover.__scripts.OnMouseUp(debuffFrame.mover, "RightButton")
check(M.lastMenu and #M.lastMenu.items >= 5, "group context menu")
for _, item in ipairs(M.lastMenu.items) do
	if item[2] == ns.L["Reset position"] then item[3]() end
end
check(debuffFrame.group.x == 116 and debuffFrame.group.y == -21, "menu reset position")
debuffFrame.group.locked = false
debuffFrame.mover.__scripts.OnEnter(debuffFrame.mover)
D.unlockBar.__children[1].__scripts.OnClick()
check(D.grid and D.grid:IsShown(), "grid toggled on")
ns:SetUnlocked(false)
check(not debuffFrame.mover:IsShown() and not D.grid:IsShown(), "lock hides movers and grid")

-- Settings window ------------------------------------------------------------
local O = ns.Options
O:Show("icons")
check(O.frame:IsShown(), "options shown")
check(#O.iconList.__rows == #ns.profile.icons, "icon rows")
O.iconList.__rows[2].__scripts.OnClick(O.iconList.__rows[2])
check(O.selectedIcon == ns.profile.icons[2], "row click selects")
local editor = O.iconEditor
editor.spells:SetText("Immolate, 6222, nonsense, 6222")
editor.spells.__scripts.OnEditFocusLost(editor.spells)
check(deepEqual(O.selectedIcon.spells, { 348, 6222 }), "spell list edit parses names and ids")
editor.slot:SetText("7")
editor.slot.__scripts.OnEditFocusLost(editor.slot)
check(O.selectedIcon.slot == 7, "slot edit")
-- One row per spell with a button that switches whose auras count.
local spellRows = editor.spellList.__rows
check(#spellRows == 2 and spellRows[1].source.__text == ns.L["Mine"] and spellRows[2].source.__text == ns.L["Mine"], "spell rows with their source")
spellRows[1].source.__scripts.OnEnter(spellRows[1].source)
check(GameTooltip:IsShown(), "source button explains itself")
spellRows[1].source.__scripts.OnLeave(spellRows[1].source)
spellRows[1].source.__scripts.OnClick(spellRows[1].source)
check(deepEqual(O.selectedIcon.anySource, { 348 }), "source button switches one spell to anyone's")
check(editor.spellList.__rows[1].source.__text == ns.L["Anyone"] and editor.spellList.__rows[2].source.__text == ns.L["Mine"], "rows show the new source")
check(RT[O.selectedIcon].anyIds[348] and not RT[O.selectedIcon].anyIds[6222], "tracker follows the switch")
editor.spellList.__rows[1].source.__scripts.OnClick(editor.spellList.__rows[1].source)
check(#O.selectedIcon.anySource == 0, "and back to yours")
local count = #ns.profile.icons
local page = O.pages.icons
local addBox
for _, child in ipairs(page.__children) do
	if child.__kind == "EditBox" then addBox = child break end
end
addBox:SetText("Immolate")
addBox.__scripts.OnEnterPressed(addBox)
check(#ns.profile.icons == count + 1 and ns.profile.icons[count + 1].spells[1] == 348, "add icon by name")
check(ns.profile.icons[count + 1].unit == "target", "harmful spell defaults to target")
O.selectedIcon = ns.profile.icons[count + 1]
for _, child in ipairs(page.__children) do
	if child.__kind == "Button" and child.__text == ns.L["Delete"] then child.__scripts.OnClick() end
end
check(M.lastPopup and M.lastPopup.data, "delete asks for confirmation")
M.lastPopup.data()
check(#ns.profile.icons == count, "icon deleted")
editor.unit:GenerateMenu()

O:Show("groups")
check(#O.groupList.__rows == #ns.profile.groups, "group rows")
local groupCount = #ns.profile.groups
for _, child in ipairs(O.pages.groups.__children) do
	if child.__kind == "Button" and child.__text == ns.L["New group"] then child.__scripts.OnClick() end
end
check(#ns.profile.groups == groupCount + 1, "new group")
local ge = O.groupEditor
ge.numbers[3]:SetText("50")
ge.numbers[3].__scripts.OnEditFocusLost(ge.numbers[3])
check(ns.profile.groups[#ns.profile.groups].size == 50, "group size edit")
ge.alpha:SetText("40")
ge.alpha.__scripts.OnEditFocusLost(ge.alpha)
check(math.abs(ns.profile.groups[#ns.profile.groups].alpha - 0.4) < 1e-9, "group alpha edit")
for _, child in ipairs(O.pages.groups.__children) do
	if child.__kind == "Button" and child.__text == ns.L["Delete"] then child.__scripts.OnClick() end
end
M.lastPopup.data()
check(#ns.profile.groups == groupCount, "group deleted")

O:Show("profile")
O:ShowExport("all")
check(O.profileBox:GetInputText():sub(1, 5) == "!SF1!", "export into box")
O:Import("all")
M.lastPopup.data()
check(O.profileStatus:GetText():find(ns.L["Settings imported."], 1, true) ~= nil, "import through the window")
O.profileBox:SetText("garbage")
O:Import("all")
check(O.profileStatus:GetText():find(ns.L["Import failed:"], 1, true) ~= nil, "bad import reported")

O:Show("cdm")
check(O.cdmStatus:GetText() ~= "", "cdm status text")
O:Show("groups", "proc")
check(O.selectedGroup == "proc", "open specific group")

SlashCmdList.SFILTER("unlock")
check(ns.unlocked, "slash unlock")
SlashCmdList.SFILTER("lock")
check(not ns.unlocked, "slash lock")
SlashCmdList.SFILTER("help")
SlashCmdList.SFILTER("export")
SlashCmdList.SFILTER("reset")
M.lastPopup.data()
check(#ns.profile.icons == #ns.Defaults.presets[game].WARLOCK, "reset profile")
sFilter_OnAddonCompartmentClick(nil, "RightButton")
check(ns.unlocked, "compartment right click unlocks")
ns:SetUnlocked(false)

if SCENARIO == "elvui" then
	local slot = RT[ns.profile.icons[1]].slot
	check(ns.Skin.elvui and slot.elvui and not slot.border:IsShown() and not slot.gloss:IsShown(), "ElvUI icon template")
	check(slot.count.__elvFont and slot.slotText.__elvFont, "icon texts use the ElvUI font")
	check(D.activeGroups.def.mover.label.__elvFont, "mover label uses the ElvUI font")
	check(O.iconEditor.title.__elvFont and O.iconEditor.disabled.Text.__elvFont, "settings texts use the ElvUI font")
	check(ns.Skin:GetFont() == "ElvFont", "fallback font is the ElvUI font")
	check(elv.calls.RegisterCooldown == nil, "sFilter draws its own mm:ss timer instead of ElvUI cooldown text")
	check((elv.calls.HandleButton or 0) > 5 and (elv.calls.HandleEditBox or 0) > 3 and (elv.calls.HandleDropDownBox or 0) > 2, "ElvUI skins widgets")
	check((elv.calls.HandleCheckBox or 0) > 2 and (elv.calls.HandleTrimScrollBar or 0) >= 2 and (elv.calls.HandleCloseButton or 0) == 1, "ElvUI skins checkboxes and scrollbars")
	check(O.frame.__template == "Transparent", "ElvUI window template")
	elv.E:ToggleMovers(true, "all")
	check(ns.unlocked, "ElvUI /moveui unlocks sFilter")
	elv.E:ToggleMovers(false, "all")
	check(not ns.unlocked, "ElvUI move mode off locks sFilter")
	elv.E:ToggleMovers(true, "ActionBars")
	check(not ns.unlocked, "ElvUI single mover ignored")
else
	local slot = RT[ns.profile.icons[1]].slot
	check(not slot.elvui and slot.gloss:IsShown(), "default icon style with gloss")
end

print(string.format("RESULT %s passed=%d failed=%d", SCENARIO, passed, failed))
