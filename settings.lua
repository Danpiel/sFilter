-- "true" means enabled, "false" means disabled
sFilter_Settings = {
    configmode = false, -- In this mode all icons are shown and can be moved.
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
Original addon version: http://toxila.googlecode.com/svn/zips/sFilter/
]]

sFilter_Spells = {
  ["DEATHKNIGHT"] = {

  -- Icebond Fortitude
  {spellId = 48792, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Rune Tap
  {spellId = 171049, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Dancing Rune Weapon
  {spellId = 81256, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Vampiric Blood
  {spellId = 55233, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Shadow Infusion (Unholy)
  {spellId = 91342, size = 32, unitId = "pet", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Blood Shield (Blood Mastery)
  {spellId = 77535, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Dark Transformation
  {spellId = 63560, size = 32, unitId = "pet", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Bone Shield
  {spellId = 49222, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},

  -- Scent of Blood (Blood)
  {spellId = 50421, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
  -- Anti-magic Shell and zone
  {spellId = 48707, spellId2 = 50461, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Frost Fever, Necrotic Plague
  {spellId = 55095, spellId2 = 155159, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Blood Plague
  {spellId = 55078, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Breath of Sindragosa
  {spellId = 155166, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Soul Reaper (Frost), Soul Reaper (Unholy)
  {spellId = 130735, spellId2 = 130736, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Killing Machine (Frost), Sudden Doom (Unholy), Crimson Scourge (Blood)
  {spellId = 51124, spellId2 = 81340, spellId3 = 81141, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Rime (Freezing Fog)
  {spellId = 59052, spellId2 = 130735, spellId3 = 130736, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["DRUID"] = {

  -- Survival Instincts
  {spellId = 61336, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Bristling Fur, Pulverize
  {spellId = 155835, spellId2 = 158792, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Barkskin
  {spellId = 22812, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Savage Defence
  {spellId = 132402, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Faerie Fire, Faerie Swarm
  {spellId = 770, spellId2 = 102355, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Savage roar
  {spellId = 52610, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Lunar Peak, Solar Peak, Bloodtalons
  {spellId = 171743, spellId2 = 171744, spellId3 = 145152, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
  -- Dream of Cenarius
  {spellId = 145162, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Moonfire, Lacirate
  {spellId = 8921, spellId2 = 33745, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Rip (Feral), Thrash (Guardian), Stellar Flare (Balance)
  {spellId = 1079, spellId2 = 77758, spellId3 = 152221, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Tooth and Claw (Guardian), Rake
  {spellId = 135286, spellId2 = 155722, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Entangling Roots
  {spellId = 339, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Predator's Swiftness, Lunar Empowerment, Solar Empowerment
  {spellId = 69369, spellId2 = 164547, spellId3 = 164545, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Clearcasting, Empowered Moonkin
  {spellId = 16870, spellId2 = 157228, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["HUNTER"] = {

  -- Focus Fire (Beastmaster)
  {spellId = 82692, size = 32, unitId = "pet", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Bestial Wrath (Beastmaster)
  {spellId = 19574, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Hunter's Mark
  {spellId = 1130, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Steady Focus
  {spellId = 177668, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Sniper Training (Marksman)
  {spellId = 168811, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Freezing Trap, Ice trap
  {spellId = 3355, spellId2 = 71647, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Black Arrow
  {spellId = 3674, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Frenzy Effect (Beastmaster)
  {spellId = 19615, size = 32, unitId = "pet", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Explosive Shot
  {spellId = 53301, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Wyvern Sting
  {spellId = 19386, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Thrill of the Hunt, Lock and Load
  {spellId = 34720, spellId2 = 168980, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},

  },

  ["MAGE"] = {

  -- Ice Block
  {spellId = 45483, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Ice Barrier
  {spellId = 11426, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Blazing Speed, Ice Floes
  {spellId = 108843, spellId2 = 108839, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Polymorph - Sheep, Pig, Turkey
  {spellId = 118, spellId2 = 28272, spellId3 = 61780, size = 32, unitId = "target", isMine = "1", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},
  -- Polymorph - Black Cat, Rabbit, Turtle
  {spellId = 61305, spellId2 = 61721, spellId3 = 28271, size = 32, unitId = "target", isMine = "1", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},
  -- Polymorph - Penguin, Monkey, Polar Bear Cub
  {spellId = 161355, spellId2 = 161354, spellId3 = 161353, size = 32, unitId = "target", isMine = "1", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},
  -- Polymorph - Peacock, Porcupine
  {spellId = 161355, spellId2 = 126819, size = 32, unitId = "target", isMine = "1", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Combustion (Fire)
  {spellId = 83853, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Arcane Charge
  {spellId = 36032, size = 32, unitId = "player", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Arcane Missiles! (Arcane)
  {spellId = 79683, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Incanter's Flow, Rune of Power
  {spellId = 116267, spellId2 = 116014,size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
  -- Deep Freeze (Frost), Slow (Arcane), Frostfire bolt
  {spellId = 44572, spellId2 = 31589, spellId3 = 44614, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Living Bomb, Nether Tempest
  {spellId = 44457, spellId2 = 114923, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Ignite (Fire)
  {spellId = 12654, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Pyroblast debuff (Fire)
  {spellId = 11366, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Meteor (Fire)
  {spellId = 155158, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Fingers of Frost (Frost), Hot Streak (Fire)
  {spellId = 44544, spellId2 = 48108, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Brain Freeze (Frost),  Cauterize (Fire)
  {spellId = 57761, spellId2 = 87023, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["MONK"] = {

  -- Fortifying Brew
  {spellId = 120954, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Dampen Harm, Diffuse Magic
  {spellId = 122278, spellId2 = 122783, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Elusive Brew
  {spellId = 115308, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Guard
  {spellId = 115295, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Light Stagger, Moderate Stagger, Heavy Stagger
  {spellId = 124275, spellId2 = 124274, spellId3 = 124273, size = 32, unitId = "player", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Tigereye Brew, Mana Tea
  {spellId = 125195, spellId2 = 115867, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Shuffle, Tiger Strikes
  {spellId = 115307, spellId2 = 120273, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},

  -- Tiger Power
  {spellId = 125359, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Rising Sun Kick
  {spellId = 130320, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Death Note
  {spellId = 121125, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},

  -- Combo Breaker: Tiger Palm, Combo Breaker: Blackout Kick, Combo Breaker: Chi Explosion
  {spellId = 118864, spellId2 = 116768, spellId3 = 159407, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},

  },

  ["PALADIN"] = {

  -- Guardian of Ancient Kings (Protection)
  {spellId = 86659, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Divine protection
  {spellId = 498, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Ardent Defender
  {spellId = 31850, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Divine Shield, Hand of Protection
  {spellId = 642, spellId2 = 1022, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Daybreak (Holy)
  {spellId = 88819, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Bastion of Glory (Protection)
  {spellId = 114637, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Selfless Healer, Eternal Flame, Sacred Shield
  {spellId = 114250, spellId2 = 156322, spellId3 = 20925, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
  -- Saved by the Light CD
  {spellId = 157131, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Censore (SoT debuff)
  {spellId = 31803, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Supplication
  {spellId = 94686, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Forbearance
  {spellId = 25771, size = 32, unitId = "player", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Divine Purpose (Retribution), Grand Crusader (Protection), Infusion of Light (Holy)
  {spellId = 90174, spellId2 = 85416, spellId3 = 54149, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Art of War (Retribution), Enhanced Holy Shock (Holy), Divine Crusader (Retribution)
  {spellId = 59578, spellId2 = 160002, spellId3 = 144595, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["PRIEST"] = {

  -- Surge of Light, Surge of Darkness
  {spellId = 114255, spellId2 = 87160, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Evangelism
  {spellId = 81661, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Serendipity (Holy), Mind Melt (Shadow)
  {spellId = 63735, spellId2 = 81292, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Worlds of Mending
  {spellId = 155362, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Borrowed Time (Discipline), Mind Spike
  {spellId = 59889, spellId2 = 87178, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Shadow Orb
  {spellId = 77487, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Saving Grace
  {spellId = 155274, size = 32, unitId = "player", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Angelic Feather
  {spellId = 121557, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},

  -- Vampiric Touch, Power Word: Solace, Holy fire
  {spellId = 34914, spellId2 = 129250, spellId3 = 14914,size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Shadow Word:Pain
  {spellId = 589, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Devouring Plague
  {spellId = 2944, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Void Entropy
  {spellId = 155361, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Divine Insight (Holy), Divine Insight (Discipline), Shadowy Insight
  {spellId = 123267, spellId2 = 123266, spellId3 = 124430, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Surge of Light, Spirit of Redemption (Holy), Insanity (Shadow)
  {spellId = 114255, spellId2 = 27827, spellId3 = 132573, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["ROGUE"] = {

  -- Evasion
  {spellId = 5277, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Cloak of Shadows
  {spellId = 31224, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Feint
  {spellId = 1966, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Slice and Dice
  {spellId = 5171, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Revealing Strike (Combat), Vendetta (Assassination)
  {spellId = 84617, spellId2 = 79140, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Cheap Shot, Gouge, Kidney Shot
  {spellId = 1833, spellId2 = 1776, spellId3 = 408, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Recuperate
  {spellId = 73651, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
  -- Shallow Insight, Moderate Insight, Deep Insight
  {spellId = 84745, spellId2 = 84746, spellId3 = 84747, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Deadly Poison, Cripling Poison, Wound Poison
  {spellId = 67710, spellId2 = 3409, spellId3 = 8680, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Rupture
  {spellId = 1943, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Crimson Tempest
  {spellId = 122233, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Garrote
  {spellId = 3409, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Blindside
  {spellId = 121153, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  },

  ["SHAMAN"] = {

  -- Stone Bulwark Totem, Astral Shift
  {spellId = 114893, spellId2 = 108271, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Shamanistic Rage
  {spellId = 30823, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Lightning Shield
  {spellId = 324, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Flame Shock, Frost Shock
  {spellId = 8050, spellId2 = 8056, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Tidal Waves, Maelstrom Weapon, Improved Chain Lightning
  {spellId = 53390, spellId2 = 53817, spellId3 = 157766, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Elemental Fusion
  {spellId = 157174, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
  -- Stormstrike
  {spellId = 17364, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Earth Shield on target
  {spellId = 974, size = 32, unitId = "target", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Riptide
  {spellId = 61295, size = 32, unitId = "target", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Hex
  {spellId = 51514, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Lava Surge
  {spellId = 77762, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Echo of the Elements
  {spellId = 159103, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["WARLOCK"] = {

  -- Unending Resolve
  {spellId = 104773, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Sacrificial Pact
  {spellId = 108416, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Dark Regeneration
  {spellId = 108359, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},

  -- Backdraft (Destruction)
  {spellId = 117828, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Demonbolt
  {spellId = 157695, size = 32, unitId = "player", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Fear, Blood Horror, Howl of Terror
  {spellId = 118699, spellId2 = 137143, spellId3 = 5484, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Life Tap (Glyphed debuff)
  {spellId = 1454, size = 32, unitId = "player", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},

  -- Immolation, Unstable Affliction, Hand of Gul'Dan
  {spellId = 348, spellId2 = 30108, spellId3 = 47960, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Corruption, Havoc (Destruction)
  {spellId = 172, spellId2 = 80240, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Seed of Corruption, Agony, Doom (Demonology)
  {spellId = 27243, spellId2 = 980, spellId3 = 603, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Rain of Fire
  {spellId = 104232, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Haunt
  {spellId = 48181, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},
  -- Fire and Brimstone
  {spellId = 108683, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Kil'Jaeden's Cunning
  {spellId = 137587, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Molten Core (Demonology), Soul Swap
  {spellId = 122355, spellId2 = 86211, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["WARRIOR"] = {

  -- Shield Wall
  {spellId = 871, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Last Stand, Die by the Sword
  {spellId = 12975, spellId2 = 85386, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Die by the Sword
  {spellId = 118038, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Enraged Regeneration
  {spellId = 55694, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Shield Barrier
  {spellId = 112048, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Shield Block
  {spellId = 2565, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Hamstring, Piercing Howl, Charge (root), Warbringer
  {spellId = 1715, spellId2 = 12323, spellId3 = 7922, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Raging Blow! (Fury), Unyielding Strikes (Protection)
  {spellId = 131116, spellId2 = 169686, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Rend (Arms)
  {spellId = 772, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Colossus Smash debuff
  {spellId = 86346, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Bloodsurge (Fury)
  {spellId = 46916, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Meat Cleaver (Fury)
  {spellId = 85739, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Sword and Board (Protection),Sudden Death
  {spellId = 50227, spellId2 = 52437,size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Ultimatum
  {spellId = 122510, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },
}
