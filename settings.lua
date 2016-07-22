-- "true" means enabled, "false" means disabled
sFilter_Settings = {
    configmode = false -- In this mode all icons are shown and can be moved.
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
  ["DEMONHUNTER"] = {

  -- Fiery Brand, Blur
  {spellId = 207744, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  {spellId = 212800, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Empower Wards, Netherwalk
  {spellId = 218256, spellId2 = 196555, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Metamorphosis (Vengeance)
  {spellId = 187827, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Darkness
  {spellId = 809426, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Soul Fragments
  {spellId = 203981, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Demon Spikes
  {spellId = 203819, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Painbringer (Artifact)
  {spellId = 207387, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},

  -- Bloodlet
  {spellId = 207690, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},

  },

  ["DEATHKNIGHT"] = {

  -- Icebond Fortitude
  {spellId = 48792, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Dancing Rune Weapon
  {spellId = 81256, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Vampiric Blood,  Corpse Shield
  {spellId = 55233, spellId2 = 207319, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Anti-magic Shell
  {spellId = 48707, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Death and Decay, Icy Talons, Bone Shield
  {spellId = 188290, spellId2 = 194879, spellId3 = 195181, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Necrosis, Blood Shield
  {spellId = 63560, spellId2 = 77535, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Rune Tap
  {spellId = 194679, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Soul Reaper (buff), Blood Mirror, Bonestorm
  {spellId = 215711, spellId2 = 206977, spellId3 = 194844, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Frost Fever, Festering Wound, Blood Plague
  {spellId = 55095, spellId2 = 194310, spellId3 = 55078, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Virulent Plague, Mark of Blood
  {spellId = 191587, spellId2 = 206940, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Scourge of Worlds
  {spellId = 191748, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Soul Reaper (target)
  {spellId = 130736, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Killing Machine (Frost), Sudden Doom (Unholy), Crimson Scourge (Blood)
  {spellId = 51124, spellId2 = 81340, spellId3 = 81141, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Rime (Freezing Fog)
  {spellId = 59052, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["DRUID"] = {

  -- Barkskin
  {spellId = 22812, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Mark of Ursol
  {spellId = 192083, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Survival Instincts
  {spellId = 61336, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Ironbark, Rage of the Sleeper
  {spellId = 102342, spellId2 = 200851, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Abundance, Ironfur
  {spellId = 207640, spellId2 = 192081, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Savage roar, Solar Peak, Frenzied Regeneration
  {spellId = 52610, spellId2 = 171744, spellId3 = 22842, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Lunar Empowerment, Pulverize, Bloodtalons
  {spellId = 164547, spellId2 = 158792, spellId3 = 145152, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
  -- Solar Empowerment, Predator's Swiftness, Guardian of Elune
  {spellId = 164545, spellId2 = 69369, spellId3 = 213680, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Moonfire
  {spellId = 8921, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Rip, Sunfire
  {spellId = 1079, spellId2 = 152221, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Rake, Stellar Flare
  {spellId = 155722, spellId2 = 202347, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Entangling Roots, Thrash
  {spellId = 339, spellId2 = 77758, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Soul of the Forest, Innervate, Galactic Guardian
  {spellId = 114108, spellId2 = 29166, spellId3 = 213708, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Clearcasting, Empowered Moonkin, Mangle!
  {spellId = 16870, spellId2 = 157228, spellId3 = 93622, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["HUNTER"] = {

  -- Making Targets, Mongoose Fury
  {spellId = 223138, spellId2 = 190931, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Bestial Wrath, Mok'Nathal Tactics
  {spellId = 19574, spellId2 = 201081, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Steady Focus, Instincts of the Mongoose, Instincts of the Cheetah, Instincts of the Raptor
  {spellId = 193534, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  {spellId = 204333, spellId2 = 204324, spellId3 = 204321, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Volley
  {spellId = 194386, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Hunter's Mark,
  {spellId = 185365, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  {spellId = 227272, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Trick Shot
  {spellId = 227272, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Freezing Trap, Ice trap
  {spellId = 3355, spellId2 = 71647, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Vulnerable, Lacerate
  {spellId = 187131, spellId2 = 185855, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Black Arrow, True Aim, On the Trail
  {spellId = 194599, spellId2 = 199803, spellId3 = 204081, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Serpent Sting
  {spellId = 118253, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Wyvern Sting
  {spellId = 19386, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- One wtih the Pack, Lock and Load
  {spellId = 185791, spellId2 = 194594, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},

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

  -- Arcane Missiles!, Heating Up, Ray of Frost (Damage Multiplier), Bone Chilling
  {spellId = 79683, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  {spellId = 48107, spellId2 = 208141, spellId3 = 205766, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Chain Reaction, Mark of Aluneth
  {spellId = 195418, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  {spellId = 224968, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Icecles, Quickening
  {spellId = 205473, spellId2 = 198924, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
  -- Incanter's Flow, Rune of Power
  {spellId = 116267, spellId2 = 116040, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Living Bomb, Nether Tempest, Frost Bomb
  {spellId = 217694, spellId2 = 114923, spellId3 = 112948, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Enhanced Pyrotechnics, Slow
  {spellId = 157644, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  {spellId = 31589, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Pyretic Incantation, Touch of Magi
  {spellId = 210824,  size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  {spellId = 194329,  size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Meteor (Fire), Erosion
  {spellId = 155158, spellId2 = 210134, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Fingers of Frost, Hot Streak
  {spellId = 44544, spellId2 = 48108, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Brain Freeze
  {spellId = 190446, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

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
  -- Innervate
  {spellId = 29166, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["PALADIN"] = {

  -- Guardian of Ancient Kings (Protection)
  {spellId = 86659, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Ardent Defender
  {spellId = 31850, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Divine Steed
  {spellId = 221885, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Divine Shield, Hand of Protection
  {spellId = 642, spellId2 = 1022, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Fervent Martyr, Shield of the Righteous
  {spellId = 223316, spellId2 = 132403, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Infusion of Light, Bulwark of Order
  {spellId = 54149, spellId2 = 209388, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Eye of Tyr
  {spellId = 209202, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Judgment of the Light, Zeal
  {spellId = 196941, spellId2 = 217020, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Consecration (Protection), Execution Sentence, Judgment
  {spellId = 188370, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  {spellId = 213757, spellId2 = 197277, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Seal of Light
  {spellId = 202273, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Forbearance
  {spellId = 25771, size = 32, unitId = "player", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Divine Purpose
  {spellId = 216411, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Innervate
  {spellId = 29166, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["PRIEST"] = {

  -- Surge of Light, Surge of Darkness
  {spellId = 114255, spellId2 = 87160, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Symbol of Hope
  {spellId = 64901, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Borrowed Time, Void Ray
  {spellId = 197763, spellId2 = 205372, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Rapture
  {spellId = 47536, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Twist of Fate
  {spellId = 123254, size = 32, unitId = "player", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Angelic Feather
  {spellId = 121557, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},

  -- Vampiric Touch, Schism
  {spellId = 34914, spellId2 = 214621, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Shadow Word:Pain, Purge the Wicked
  {spellId = 589, spellId2 = 204213, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Shadow Word: Void
  {spellId = 205351, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Voidform, Lingering Insanity
  {spellId = 194249, spellId2 = 197937, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Shadowy Insight, Innervate
  {spellId = 124430, spellId2 = 29166, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},

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

  -- Astral Shift, E
  {spellId = 108271,  size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Earthshield totem
  {spellId = 201633, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},

  -- Flame Shock, Flametongue
  {spellId = 188838, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  {spellId = 194084, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Tidal Waves, Stormlash, Power of the Maelstrom
  {spellId = 53390, spellId2 = 195222, spellId3 = 191877, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Spiritwalker's Grace, Frostband
  {spellId = 79206, spellId2 = 196834, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
  -- Earthen Spike, Lightning Rod, Landslide
  {spellId = 188089, spellId2 = 197209, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},
  {spellId = 202004, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Unleashed life, Rainfall
  {spellId = 73685, spellId2 = 215864, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Cloudburst totem
  {spellId = 157504, size = 32, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Hex
  {spellId = 51514, size = 32, unitId = "target", isMine = "all", filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Lava Surge, Hot hand
  {spellId = 77762, spellId2 = 215785, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Stormbringer, Innervate
  {spellId = 201846, spellId2 = 29166, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["WARLOCK"] = {

  -- Unending Resolve
  {spellId = 104773, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Sacrificial Pact
  {spellId = 108416, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Dark Regeneration
  {spellId = 108359, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Seed of Corruption
  {spellId = 27243, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Backdraft (Destruction), Compounding Horror
  {spellId = 117828, spellId2 = 199281, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Demonbolt
  {spellId = 157695, size = 32, unitId = "player", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Fear, Blood Horror, Howl of Terror
  {spellId = 118699, spellId2 = 137143, spellId3 = 5484, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
  -- Mana Tap
  {spellId = 196104, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 0}},
  -- Deadwind Harvester, Tormented Souls
  {spellId = 216708, spellId2 = 216695, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 0}},

  -- Immolation, Unstable Affliction, Doom
  {spellId = 348, spellId2 = 30108, spellId3 = 603, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, -37}},
  -- Corruption, Havoc (Destruction)
  {spellId = 172, spellId2 = 80240, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, -37}},
  -- Demonic Empowerment
  {spellId = 193396, size = 32, unitId = "pet", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Agony, Eradication
  {spellId = 980, spellId2 = 196414, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, -37}},
  -- Siphon Life
  {spellId = 63106, size = 32, unitId = "target", isMine = 1, filter = "HARMFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},
  -- Conflagration of Chaos
  {spellId = 196546, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, -37}},

  -- Shadowy Inspiration
  {spellId = 196606, size = 64, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 148, -91}},
  -- Molten Core (Demonology), Soul Swap
  --{spellId = 122355, spellId2 = 86211, size = 64, unitId = "player", isMine = "all", filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 222, -91}},

  },

  ["WARRIOR"] = {

  -- Shield Wall
  {spellId = 871, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 37}},
  -- Last Stand, Die by the Sword
  {spellId = 12975, spellId2 = 118038, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 37}},
  -- Ravager (Protection)
  {spellId = 152277, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 206, 37}},
  -- Enraged Regeneration
  {spellId = 55694, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 243, 37}},

  -- Shield Barrier
  {spellId = 112048, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 132, 0}},
  -- Shield Block, Shield Charge
  {spellId = 2565, spellId2 = 169667, size = 32, unitId = "player", isMine = 1, filter = "HELPFUL", setPoint = {"CENTER", UIParent, "CENTER", 169, 0}},
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
