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
- setPoint - where to place the icon. It's a table with coordinates inside. More info: http://www.wowwiki.com/API_Region_SetPoint
Original addon version: http://toxila.googlecode.com/svn/zips/sFilter/
]]

--[[ PVP Section
This is a list of bufs on targets i.e. Shild Wall or Bubble, there will be three icons, first will be major safe ablities (Ice Block, Icebond Fortitude), second is safe abilities from another player (Blessing of protection, Antimagic zone)
and third wiil be minor buffs (Blessing of Freedom, Stoneclaw totem)

Spells will be added by slot of priority

All icons 64 size

-- Add this list to your character class

PVP Spells = {
	-- Major Safe abilities: Icebond Fortitude(DK), Anti-magic shield (DK), Divine Protection(PAL), Divine Protection(PAL), Dispersion(PRIEST), Ice Block(MAGE), Dettrence(HUNTER), Spell Reflect(WAR), Shield Wall(WAR), Barkskin(DRU), Survival Instincts(DRU), Cloack of Shadows(ROG), Evasion(ROG), Sacrifice(LOCK Pet), Shamanistic Rage(SHA), The Beast Within(HUNT)
	{spellId = 48792, spellId2 = 48707, spellId3 = 498, spellId4 = 642, spellId5 = 47585, spellId6 = 45438, spellId7 = 19263, spellId8 = 23920, spellId9 = 871, spellId10 = 22812, spellId11 = 61336, spellId12 = 31224, spellId13 = 26669, spellId14 = 47986, spellId15 = 30823, spellid16 = 34471, size = 64, unitId = "target", isMine = all, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", -148, 37}},
	-- Shareable safe abilities: Anti-magic zone(DK), Hand of Protection(PAL), Hand of Sacriface(PAL), Aura Mastery(PAL), Divine Sacriface(PAL), Guardian Spirit(PRIEST), Pain Suppression(PRIEST), Intervene(WAR), Hymn of Hope(PRIEST), Tranquility(DRU)
	{spellId = 50461, spellId2 = 1022, spellId3 = 6940, spellId4 = 31821, spellId5 = 64205, spellId6 = 47788, spellId7 = 33206, spellId8 = 3411, spellId9 = 64901, spellId10 = 48447, size = 64, unitId = "target", isMine = all, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", -222, 37}},
	-- Minor safe abilities: Hand of Freedom(PAL), Divine Hymn(PRIEST), , Ice Barrier(MAGE), Mana Shield(MAGE), Fire Ward(MAGE), Frost Ward(MAGE), Shield Block(WAR), Enraged Regeneration(WAR), Frenzied Regeneration(DRU), Shadow Ward(LOCK), Stoneclaw Totem(SHA)
	{spellId = 1044, spellId2 = 64843, spellId3 = 43039, spellId4 = 43020, spellId67= 43010, spellId8 = 43012, spellId9 = 2565, spellId10 = 55694, spellId11 = 22842, spellId12 = 47891, spellid13 = 58582, size = 64, unitId = "target", isMine = all, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", -296, 37}},

--]]

sFilter_Spells = {
    ["DEATHKNIGHT"] = {
    -- Ebon Plague
    {spellId = 65142, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
    -- Frost Fever
    {spellId = 59921, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
    -- Blood Plague
    {spellId = 59879, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- Unholy Blight
    {spellId = 49194, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
	-- Killing Machine
	{spellId = 51124, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -54}},
	-- Rime (Freezing Fog)
	{spellId = 59052, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -54}},
	-- Desolation
	{spellId = 66803, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
	-- Icebond Fortitude
	{spellId = 48792, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
	-- Vampiric Blood, Unbreakable Armor, Bone Shield 
	{spellId = 55233, spellId2 = 51271, spellId3 = 49222, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
	-- Anti-magic shield and zone
	{spellId = 48707, spellId2 = 50461, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},
    },
    ["DRUID"] = {

    },
    ["HUNTER"] = {

    },
    ["MAGE"] = {
    -- Living Bomb
    {spellId = 44457, size = 64, unitId = "target", isMine = 1, setPoint = {"CENTER", UIParent, "CENTER", 222, -54}},
    -- Fingers of Frost (Frost), Arcane Missiles! (Arcane), Hot Streak (Fire)
    {spellId = 44544, spellId2 = 79683, spellId3 = 44448, size = 64, unitId = "player", isMine = all, setPoint = {"CENTER", UIParent, "CENTER", 148, -54}},
    -- Invocation
    {spellId = 87098, size = 32, unitId = "player", isMine = 1, setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
    -- Clear Casting
    {spellId = 12536, size = 32, unitId = "player", isMine = 1, setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
    -- Fiery Payback (Fire)  
    {spellId = 44440, size = 32, unitId = "player", isMine = "all", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},
	-- Deep Freeze (Frost)
	{spellId = 44572, size = 32, unitId = "target", isMine = "all", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},
    -- Impact, Arcane Potency (Arcane)
    {spellId = 12358, spellId2 = 57531, size = 32, unitId = "target", isMine = "all", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
    -- Arcane Blast debuff 
    {spellId = 36032, size = 32, unitId = "player", isMine = "all", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
	-- Blazing Speed (Fire), Improved Blink (Arcane)
	{spellId = 31643, spellId2 = 47000, size = 32, unitId = "player", isMine = "all", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
    -- Spell Crit - Winter's Chill (Frost), Improved Scorch (Fire)
    {spellId = 28593, spellId2 = 22959, size = 32, unitId = "target", isMine = "1", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},  
    -- Polymorph - Sheep, Pig, Turkey, Black Cat, Rabbit, Turtle, 
    {spellId = 118, spellId2 = 28272, spellId3 = 61780, spellId4 = 61305, spellId5 = 61721, spellId6 = 28271, size = 32, unitId = "target", isMine = "1", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
    -- Slow (Arcane), Ignite (Fire), Frostbite (Frost)
    {spellId = 31589, spellId2 = 12848, spellId3 = 12497, size = 32, unitId = "target", isMine = 1, setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
    },
    ["PALADIN"] = {
    -- Hand of Light (Retrobution), Grand Crusader (Protection) 
	{spellId = 90174, spellId2 = 85416, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -54}},
	-- Art of War (Retrobution)
    {spellId = 59578, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
    -- Speed of Light (Holy)
    {spellId = 85497, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
	-- Daybreak (Holy), Holy Shield (Protection)
	{spellId = 88819, spellId2 = 20925, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
	-- Infusion of Light (Holy), Guarded by the light (Protection)
	{spellId = 54149, spellId2 = 88063, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- Denounce (Holy) 
	{spellId = 85509, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
	-- Divine Plea
	{spellId = 54428 , size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
	},
    ["PRIEST"] = {

    },
    ["ROGUE"] = {
	-- Deadly Poison
    {spellId = 67710, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
	-- Wound Poison 
    {spellId = 13218, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
   	-- Crippling Poison 
	{spellId = 3409, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
    -- Mind-numbing Poison
    {spellId = 5760, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},
	-- Slice and Dice
	{spellId = 5171, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
	-- Rupture
	{spellId = 1943, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},	
	},
    ["SHAMAN"] = {
 
    },
    ["WARLOCK"] = {
    -- CoE, Ebon Plague, Earth and Moon
    {spellId = 1490, spellId2 = 65142, spellId3 = 60433, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
    -- CoT, CoEx, CoW
    {spellId = 1714, spellId2 = 18223, spellId3 = 702, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
    -- Molten Core (Demonology), Shadow Trance (Affliction)
    {spellId = 47383, spellId2 = 18095, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
    -- Decimation (Demonology), Backdraft (Destruction), Eradication (Affliction)
    {spellId = 63158, spellId2 = 54277, spellId3 = 47195, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
    -- Immolation, Unstable Affliction (Affliction)
    {spellId = 348, spellId2 = 30108, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
    -- Corruption, SoC
    {spellId = 172, spellId2 = 27243, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
    -- BoA, BoD, BoH (Destruction)
    {spellId = 980, spellId2 = 603, spellId3 = 80240, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
    -- Haunt, Demonic Rebirth (Demonology)
	{spellId = 48181, spellId2 = 88448, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},
	-- Backlash
	{spellId = 34939, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, 54}},
	-- Fear, Nightmare 
	{spellId = 5782, spellId2 = 1714, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

	},
    ["WARRIOR"] = {
    -- Sword and Board (Protection)
    {spellId = 50227, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -54}},
    -- Bloodsurge (Fury), Sudden Death (Arms)
    {spellId = 46916, spellId2 = 52437, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -54}},
	-- Taste of Blood (Arms) 
	{spellId = 60503, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -54}},
    -- Hamstring, Piercing Howl
    {spellId = 1715, spellId2 = 12323, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
    -- Rend
    {spellId = 94009, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
	-- Rude Interruption (Fury), Jaggernaut (Arms) 
    {spellId = 86663, spellId2 = 65156, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
	-- Enrage 
	{spellId = 12880, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
	-- Stuns: Throwdown, Charge, Intercept, Concussion Blow
	{spellId = 85388, spellId2 = 7922, spellId3 = 20253, spellId4 = 12809, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
	-- Last Stand, Die by the Sword
	{spellId = 12975, spellId2 = 85386, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
	-- Shield Wall
	{spellId = 871, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
 
	},
}