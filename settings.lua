-- "true" means enabled, "false" means disabled
sFilter_Settings = {
    configmode = false, -- In this mode all icons are shown and can be moved.
    FontSize = 17,      -- Font size for stacks text
    r = .8,             -- Text color for stacks text More info: http://www.wowwiki.com/API_FontString_SetTextColor
    g = .8,
    b = .8,
    CountPoint = {"TOP"},            -- Stacks text position. More info: http://www.wowwiki.com/API_Region_SetPoint
}

--[[ More info about config mode:
You can move icons with left mouse button while holding Alt OR Shift. Changed position won't be saved between sessions.
After click on icon you will see in chat info about its position. This can be used to change setPoint attribute is spell list.
Clicking on icon with right mouse button will reset its position to default.
]]

--[[ Closer look at spell lists:
All classes have their own spell list.
Each entry in list creates a separate icon. Entry is a table with values in it:
- spellId - id of spell you want to track. If you don't know it - check wowhead.com - last number in any spell link is spellid (example: http://www.wowhead.com/?spell=55095, id is 55095)
- spellId2, spellId3, spellId4, spellId5 - optional entries, these are the spellids you want to track if primary spell is NOT active.
- size - icon size in pixels
- unitId - unit at which you wish to track selected spell(s). More info: http://www.wowwiki.com/UnitId
- isMine - this is filter. isMine = 1 means only  effects from units in MyUnits table will be shown (see below for this table. Note: isMine = "1" will NOT work, it should be number, not string. Any other value will show effect from any source
- filter - filter again =). Needs to be "HELPFUL" for buffs and "HARMFUL" for debuffs.
- setPoint - where to place the icon. It's a table with coordinates inside. More info: http://www.wowwiki.com/API_Region_SetPoint

I removed alpha settings and some other things, you can use original addon version for these features: http://toxila.googlecode.com/svn/zips/sFilter/
]]

sFilter_Spells = {
    ["DEATHKNIGHT"] = {
    -- Frost Fever
    {spellId = 55095, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
    -- Blood Plague
    {spellId = 55078, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
    -- Ebon Plague
    {spellId = 51726, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- Unholy Blight
    {spellId = 50536, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
	-- Killing Machine
	{spellId = 51124, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -54}},
	-- Rime (Freezing Fog
	{spellId = 59052, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -54}},
    },
--[[}    ["DRUID"] = {    

    },
]]
    ["DRUID"] = {
    -- Insect Swarm
	{spellId = 27013, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
    -- Moonfire
    {spellId = 26988, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 280, 0}},
    -- Entangling Roots
    {spellId = 26989, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 317, 0}},
    -- Earth and Moon
    {spellId = 48511, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
    -- Eclipse
    {spellId = 48525, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"LEFT", UIParent, "CENTER", 85, -80}},
	 -- Lacerate
    {spellId = 48568, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
    -- Rake
    {spellId = 48574, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
    -- Rip
    {spellId = 49800, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- Mangle
    {spellId = 48566, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
    -- Barkskin
    {spellId = 22812, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", -132, 0}},
    -- Survival Instincts
    {spellId = 61336, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", -169, 0}},
    -- Savage roar
    {spellId = 52610, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", -95, 0}},
    },
    ["HUNTER"] = { -- by haylie from wowinterface.com
    -- Hunter's Mark
    {spellId = 53338, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- Serpent Sting
    {spellId = 49001, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
    -- Black Arrow
    {spellId = 63672, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 280, 0}},
    -- Explosive Shot DoT
    {spellId = 60053, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 317, 0}},
    -- Lock and Load
    {spellId = 56453, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"LEFT", UIParent, "CENTER", 85, 0}},
    -- Aspect of the Viper
    {spellId = 34074, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"LEFT", UIParent, "CENTER", 85, 70}},
    },
    ["MAGE"] = {-- by Zaben from wowinterface.com
    -- Living Bomb
    {spellId = 55360, size = 64, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"LEFT", UIParent, "CENTER", 85, -80}},
    -- Fingers of Frost (Frost), Missile Barrage (Arcane), Hot Streak (Fire)
    {spellId = 44545, spellId2 = 54490, spellId3 = 44448, size = 64, unitId = "player", isMine = all, filter = "HELPFUL", setPoint = {"LEFT", UIParent, "CENTER", 85, 0}},
    -- Fireball! 
    {spellId = 57761, size = 32, unitId = "player", isMine = "all", filter = "HELPFULL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
    -- Clear Casting
    {spellId = 12536, size = 64, unitId = "player", isMine = all, filter = "HELPFUL", setPoint = {"LEFT", UIParent, "CENTER", 85, -80}},
    -- Fiery Payback (Rank 1 and 2)
    {spellId = 44440, spellId2 = 44441, size = 32, unitId = "player", isMine = "all", filter = "HELPFULL", setPoint = {"CENTER", UIParent, "CENTER", 85, 0}},
    -- Impact
    {spellId = 12358, size = 32, unitId = "target", isMine = "1", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
    -- Arcane Blast debuff 
    {spellId = 36032, size = 32, unitId = "player", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- Spell Crit - Winter's Chill (Frost), Improved Scorch (Fire)
    {spellId = 28593, spellId2 = 22959, size = 32, unitId = "target", isMine = "1", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},  
    -- Polymorph - Sheep, Pig, Turkey, Black Cat, Rabbit, Turtle, 
    {spellId = 12826, spellId2 = 28272, spellId3 = 61780, spellId4 = 61305, spellId5 = 61721, spellId6 = 28271, size = 32, unitId = "target", isMine = "1", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
    -- Slow (Arcane), Ignite (Fire), Frostbite (Frost)
    {spellId = 31589, spellId2 = 12848, spellId3 = 12497, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 238, 0}},
    },
    ["PALADIN"] = {
    -- Art of War
    -- {spellId = 53488, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "BOTTOMLEFT", 788, 549}},
    -- Vengeance
    -- {spellId = 20053, spellId = 20052, spellId = 20050, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "BOTTOMLEFT", 820, 549}},
    -- Holy Shield
    {spellId = 20927, spellId = 20928, spellId = 27179, spellId = 48951, spellId = 48952, spellId = 20925, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
    -- Divine Plea
	{spellId = 54428 , size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
    -- Forbearance
	{spellId = 25771, size = 32, unitId = "player", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},
	},
    ["PRIEST"] = {
    -- Inner Fire
--    {spellId = 48168, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
    -- PW:Shield on self
    {spellId = 48066, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
	-- Прозорливость
	{spellId = 63734, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
    -- Renew on target
    {spellId = 25222, size = 32, unitId = "target", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
    -- PW:Shield on target
    {spellId = 48066, size = 32, unitId = "target", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
    -- Surge of Light
    {spellId = 33151, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- SW:Pain
    {spellId = 48125, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
    -- VT (shadow)
    {spellId = 48160, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
    -- VE (shadow)
 --   {spellId = 15286, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
    -- Devouring Plague
    {spellId = 48300, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},
    },
    ["ROGUE"] = {
    },
    ["SHAMAN"] = {
    -- Hex
    {spellId = 51514, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
    -- Water Shield, Earth Shield, Lightning Shield
    {spellId = 57960, spellId2 = 49284, spellId3 = 49281, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
    -- Tidal Waves (resto), Maelstrom (ench)
    {spellId = 53390, spellId2 = 53817, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
    -- Flame Shock, Frost Shock
    {spellId = 49233, spellId2 = 49236, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- ES on target (resto)
    {spellId = 49284, size = 32, unitId = "target", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
    -- Riptide (resto)
    {spellId = 61301, size = 32, unitId = "target", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
    
    },
    ["WARLOCK"] = {
    -- CoE, Ebon Plaguebringer, Earth and Moon
    {spellId = 47865, spellId2 = 51161, spellId3 = 48511, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
    -- CoT, CoE, CoW
    {spellId = 11719, spellId2 = 18223, spellId3 = 50511, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
    -- Molten Core(destro), Shadow Trance (afflict)
    {spellId = 47383, spellId2 = 17941, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- Decimation (demo), Backdraft (destro), Eradication (afflict)
    {spellId = 63158, spellId2 = 54277, spellId3 = 47195, spellId4 = 47196, spellId5 = 47197, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
    -- Immolation, Unstable Affliction (afflict)
    {spellId = 47811, spellId2 = 47843, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
    -- Corruption
    {spellId = 47813, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
    -- CoA, CoD
    {spellId = 47864, spellId2 = 47867, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
    -- Haunt
	{spellId = 48181, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},
	-- Life Tap
	{spellId = 63321, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},
	-- Backlash
	{spellId = 34936, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 74}},
	},
    ["WARRIOR"] = {
    -- Blood Draining
    {spellId = 64568, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},
    -- Instant Slam!
    {spellId = 46916, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"LEFT", UIParent, "CENTER", 85, 0}},
    -- Sudden Death
    {spellId = 52437, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"LEFT", UIParent, "CENTER", 85, 0}},
    -- Hamstring
    {spellId = 1715, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
    -- Rend
    {spellId = 47465, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
    -- Instant Shield Slam
    {spellId = 50227, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"LEFT", UIParent, "CENTER", 85, 0}},
    -- Armor debuff - major: sunder, expose
    {spellId = 7386, spellId2 = 48669, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
    -- Attack speed debuff: warrior clap, feral wounds, dk frost fever
    {spellId = 6343, spellId2 = 48485, spellId3 = 55095, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- Attack power debuff: warrior shout, druid roar, lock curse
    {spellId = 1160, spellId2 = 48560, spellId3 = 50511, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
    }
}