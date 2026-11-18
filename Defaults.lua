-- Default groups and per-class spell presets.
--
-- Each icon lists one or more spell IDs; the first aura found in that order is shown. Auras are
-- matched by spell ID and by spell name, so a single ID covers every rank of a spell (Forever
-- keeps Classic ranks). IDs that do not exist in the running client are flagged in the settings
-- window and ignored.

local _, ns = ...
local L = ns.L

local Defaults = {}
ns.Defaults = Defaults

-- Group positions reproduce the original sFilter layout: three rows of 32px icons to the right
-- of the character and a row of large 64px proc icons below them.
function Defaults.Groups()
	return {
		{ key = "def",    name = L["Defensives"],     x = 116, y = 53,  size = 32, spacing = 5,  perRow = 6, grow = "RIGHT", wrap = "DOWN" },
		{ key = "buff",   name = L["Buffs"],          x = 116, y = 16,  size = 32, spacing = 5,  perRow = 6, grow = "RIGHT", wrap = "DOWN" },
		{ key = "debuff", name = L["Target debuffs"], x = 116, y = -21, size = 32, spacing = 5,  perRow = 6, grow = "RIGHT", wrap = "DOWN" },
		{ key = "proc",   name = L["Procs"],          x = 116, y = -59, size = 64, spacing = 10, perRow = 4, grow = "RIGHT", wrap = "DOWN" },
	}
end

-- Whose auras count is set per spell and can be switched in the icon editor. By default a spell
-- counts only when you or your pet cast it. ANY{ ... } marks spells whose auras count from anyone;
-- it wraps the whole list or a part of it, e.g. { 2818, ANY{ 13218 } }.
--
-- Target debuffs follow one rule: damage over time, and effects that only help their own caster
-- (Hemorrhage, Mind Spike, Vampiric Embrace, Haunt...), are yours; everything else (armor and
-- curse debuffs, marks, judgements, slows, stuns and other crowd control) counts from anyone.
local function ANY(spells)
	return { any = spells }
end

local function Icon(group, slot, unit, filter, list, allAny)
	local icon = { group = group, slot = slot, unit = unit, filter = filter, spells = {}, anySource = {} }
	local function Add(items, any)
		if items.any then
			return Add(items.any, true)
		end
		for _, item in ipairs(items) do
			if type(item) == "table" then
				Add(item, any)
			else
				icon.spells[#icon.spells + 1] = item
				if any then
					icon.anySource[#icon.anySource + 1] = item
				end
			end
		end
	end
	Add(list, allAny)
	return icon
end

-- Shorthands: buff on me, debuff on my target, buff on my pet, debuff on me (from anyone).
local function B(group, slot, spells)
	return Icon(group, slot, "player", "HELPFUL", spells)
end

local function D(group, slot, spells)
	return Icon(group, slot, "target", "HARMFUL", spells)
end

local function P(group, slot, spells)
	return Icon(group, slot, "pet", "HELPFUL", spells)
end

local function PD(group, slot, spells)
	return Icon(group, slot, "player", "HARMFUL", spells, true)
end

-- Shown while the spell's cooldown runs: for effects without any aura whose cooldown equals
-- their duration.
local function CD(group, slot, spells)
	local icon = Icon(group, slot, "player", "HELPFUL", spells)
	icon.track = "cooldown"
	return icon
end

------------------------------------------------------------------------
-- World of Warcraft: Forever (Classic spell IDs)
------------------------------------------------------------------------

-- Generated from Wowhead's Forever database (wowhead.com/forever): every aura ID of each
-- spell, all ranks included, because Blizzard's aura container matches spell IDs only.
local forever = {}

forever.WARRIOR = {
	B("def", 1, { 871, 15062, 29061, 1277424 }),                -- Shield Wall
	B("def", 2, { 12976 }),                                     -- Last Stand
	B("def", 3, { 2565 }),                                      -- Shield Block
	B("def", 4, { 20230 }),                                     -- Retaliation
	B("def", 5, { 402913 }),                                    -- Enraged Regeneration
	B("def", 6, ANY{ 426490 }),                                 -- Rallying Cry
	B("buff", 1, { 12292, 12723, 1230702, 1230704, 1230712 }),  -- Sweeping Strikes
	B("buff", 2, { 12328 }),                                    -- Death Wish
	B("buff", 3, { 1719, 13847 }),                              -- Recklessness
	B("buff", 4, { 426940 }),                                   -- Rampage
	B("buff", 5, { 29131 }),                                    -- Bloodrage
	B("buff", 5, { 18499 }),                                    -- Berserker Rage
	D("debuff", 1, { 772, 6546, 6547, 6548, 11572, 11573, 11574 }), -- Rend
	D("debuff", 2, ANY{ 7386, 7405, 8380, 11596, 11597 }),      -- Sunder Armor
	D("debuff", 3, ANY{ 12294, 21551, 21552, 21553, 27580 }),   -- Mortal Strike
	D("debuff", 4, ANY{ 6343, 8198, 8204, 8205, 11580, 11581, 413589, 461810, 461826, 461827, 461828, 461829, 461830 }), -- Thunder Clap
	D("debuff", 4, ANY{ 1715, 7372, 7373, 27584, 1236177, 12323, 23600 }), -- Hamstring, Piercing Howl
	D("debuff", 5, ANY{ 1160, 6190, 11554, 11555, 11556, 13730, 16244, 19778, 27579 }), -- Demoralizing Shout
	B("proc", 1, { 12880, 427066, 462885 }),                    -- Enrage
	B("proc", 2, { 413399 }),                                   -- Blood Surge
	B("proc", 3, { 440114 }),                                   -- Sudden Death
	B("proc", 3, { 426969, 426979, 402975 }),                   -- Taste for Blood, Sword and Board, Victorious
}

forever.ROGUE = {
	B("def", 1, { 5277, 15087 }),                               -- Evasion
	B("def", 2, { 2983, 8696, 11305 }),                         -- Sprint
	B("def", 3, { 1856, 1857, 11327, 11329, 27617, 457437, 1285372 }), -- Vanish
	B("buff", 1, { 5171, 6434, 6774 }),                         -- Slice and Dice
	B("buff", 2, { 13877 }),                                    -- Blade Flurry
	B("buff", 3, { 13750 }),                                    -- Adrenaline Rush
	B("buff", 4, { 400012 }),                                   -- Blade Dance
	D("debuff", 1, { 1943, 8639, 8640, 11273, 11274, 11275, 14874, 14903, 15583, 1271514 }), -- Rupture
	D("debuff", 2, { 703, 8631, 8632, 8633, 8818, 11289, 11290, 462724, 462726, 462727, 462728, 462729, 462730, 1213442, 412096 }), -- Garrote, Crimson Tempest
	D("debuff", 3, { 424785, 16511 }),                          -- Saber Slash, Hemorrhage
	D("debuff", 4, ANY{ 8647, 8649, 8650, 11197, 11198, 439471 }), -- Expose Armor, Sebacious Poison
	D("debuff", 5, { 2818, 434312, 2819, 434313, 11353, 434314, 11354, 434315, 25349, 434316, ANY{ 13218, 13222, 13223, 13224, 439472, 439473 } }), -- Deadly Poison, Deadly Poison II, Deadly Poison III, Deadly Poison IV, Deadly Poison V; anyone's: Wound Poison, Wound Poison II, Wound Poison III, Wound Poison IV, Numbing Poison, Atrophic Poison
	D("debuff", 6, ANY{ 408, 8643, 27615, 1833, 6409, 14902, 1776, 1777, 8629, 11285, 11286, 400009 }), -- Kidney Shot, Cheap Shot, Gouge, Between the Eyes
	B("proc", 1, { 14177 }),                                    -- Cold Blood
	B("proc", 2, { 462707, 1241810 }),                          -- Cutthroat
	B("proc", 3, { 424919, 462752 }),                           -- Main Gauche
}

forever.MAGE = {
	B("def", 1, { 11958, 27619 }),                              -- Ice Block
	B("def", 2, { 11426, 13031, 13032, 13033, 1213278 }),       -- Ice Barrier
	B("def", 3, { 1463, 8494, 8495, 10191, 10192, 10193, 17740, 17741, 412116, 412118, 412120, 412121, 412122, 412123 }), -- Mana Shield
	B("def", 4, { 6143, 8461, 8462, 10177, 15044, 28609, 412202, 412205, 412207, 412209, 412210, 543, 8457, 8458, 10223, 10225, 15041, 412214, 412218, 412230, 412231, 412232 }), -- Frost Ward, Fire Ward
	B("buff", 1, { 12042 }),                                    -- Arcane Power
	B("buff", 2, { 28682 }),                                    -- Combustion
	B("buff", 3, { 425121, 429125 }),                           -- Icy Veins
	B("buff", 4, { 400573, 400586, 1300176, 1300177 }),         -- Arcane Blast
	B("buff", 5, { 12051, 456397 }),                            -- Evocation
	B("buff", 6, { 428878 }),                                   -- Balefire Bolt
	D("debuff", 1, ANY{ 22959 }),                               -- Fire Vulnerability
	D("debuff", 2, { 400613 }),                                 -- Living Bomb
	D("debuff", 3, { 11366, 12505, 12522, 12523, 12524, 12525, 12526, 17273, 17274, 18809, 20228, 434443, 460858, 460860, 1236173, 1236291, 401502, 1237312, 1237313 }), -- Pyroblast, Frostfire Bolt
	D("debuff", 4, ANY{ 122, 865, 6131, 9915, 10230, 12494, 428739 }), -- Frost Nova, Frostbite, Deep Freeze
	D("debuff", 5, ANY{ 118, 12824, 12825, 12826, 28271, 28272, 29124 }), -- Polymorph
	B("proc", 1, { 48108, 400669, 400670, 12536 }),             -- Hot Streak, Fingers of Frost, Clearcasting
	B("proc", 2, { 400589, 400730 }),                           -- Brain Freeze, Missile Barrage
	B("proc", 3, { 12043 }),                                    -- Presence of Mind
	B("proc", 4, { 425124 }),                                   -- Arcane Surge
}

forever.WARLOCK = {
	B("def", 1, { 6229, 11739, 11740, 28610 }),                 -- Shadow Ward
	B("def", 2, { 7812, 19438, 19440, 19441, 19442, 19443 }),   -- Sacrifice
	B("def", 3, { 425463, 430025 }),                            -- Demonic Grace
	B("buff", 1, { 18288 }),                                    -- Amplify Curse
	B("buff", 2, { 18708 }),                                    -- Fel Domination
	B("buff", 3, { 403789, 403816 }),                           -- Metamorphosis
	D("debuff", 1, { 172, 6222, 6223, 7648, 11671, 11672, 18376, 21068, 25311, 1213450, 1223963 }), -- Corruption
	D("debuff", 2, { 980, 1014, 6217, 11711, 11712, 11713, 603 }), -- Bane of Agony, Bane of Doom
	D("debuff", 3, { 348, 707, 1094, 2941, 11665, 11667, 11668, 25309, 426320, 426325, 1228049 }), -- Immolate, Shadowflame
	D("debuff", 4, { 18265, 18879, 18880, 18881, 427717, 427719, 1242971, 1242972, 403501, 1293693, 1293694 }), -- Siphon Life, Unstable Affliction, Haunt
	D("debuff", 5, ANY{ 440892, 1311676, 1311677, 1311680, 704, 7658, 7659, 11717, 1225841, 702, 1108, 6205, 7646, 11707, 11708, 1714, 11719 }), -- Curse of the Elements, Curse of Recklessness, Curse of Weakness, Curse of Tongues
	D("debuff", 6, ANY{ 5782, 6213, 6215, 710, 18647, 457569, 465352 }), -- Fear, Banish
	B("proc", 1, { 17941 }),                                    -- Shadow Trance
	B("proc", 2, { 440873 }),                                   -- Decimation
	P("proc", 3, { 755, 3698, 3699, 3700, 11693, 11694, 11695 }), -- Health Funnel
	B("proc", 4, { 440895 }),                                   -- Mark of Chaos (buff)
}

forever.HUNTER = {
	B("def", 1, { 19263 }),                                     -- Deterrence
	B("def", 2, { 5384 }),                                      -- Feign Death
	P("def", 3, { 136, 3111, 3661, 3662, 13542, 13543, 13544 }), -- Mend Pet
	B("buff", 1, { 3045 }),                                     -- Rapid Fire
	P("buff", 2, { 19574 }),                                    -- Bestial Wrath
	D("debuff", 1, ANY{ 1130, 14323, 14324, 14325, 1213268 }), -- Hunter's Mark
	D("debuff", 2, { 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295, 425728, 425729, 425730, 425732, 425733, 425734, 425735, 425736, 425737, 1232979, 1232980, 1232981, 1232982 }), -- Serpent Sting
	D("debuff", 3, ANY{ 3043, 3034, 14279, 14280 }),            -- Scorpid Sting, Viper Sting
	D("debuff", 4, { 458436, 458481, 458482, 24118, 24119, 24120, 414644, 1235826, 1235827, 1299332 }), -- Wyvern Strike, Lacerate
	D("debuff", 5, ANY{ 2974, 14267, 14268, 27633, 1310180, 5116, 19503, 23601 }), -- Wing Clip, Concussive Shot, Scatter Shot
	D("debuff", 6, { ANY{ 3355, 14308, 14309 }, 13797, 14298, 14299, 14300, 14301, 13812, 14314, 14315 }), -- anyone's: Freezing Trap Effect; Immolation Trap Effect, Explosive Trap Effect
	B("proc", 1, { 415414 }),                                   -- Lock and Load
}

forever.PRIEST = {
	B("def", 1, ANY{ 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, 27607, 1236154 }), -- Power Word: Shield
	PD("def", 2, { 6788 }),                                     -- Weakened Soul
	B("def", 3, { 586, 9578, 9579, 9592, 10941, 10942 }),       -- Fade
	B("def", 4, ANY{ 425294, 402004 }),                         -- Dispersion, Pain Suppression
	B("buff", 1, ANY{ 10060 }),                                 -- Power Infusion
	B("buff", 2, { 14751 }),                                    -- Inner Focus
	B("buff", 3, ANY{ 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315, 27606, 425268, 425269, 425270, 425271, 425272, 425273, 425274, 425275, 425276, 425277, 1236151, 1289450 }), -- Renew
	B("buff", 4, ANY{ 401877, 1240848, 1240849 }),              -- Prayer of Mending
	D("debuff", 1, { 589, 594, 970, 992, 2767, 10892, 10893, 10894, 27605 }), -- Shadow Word: Pain
	D("debuff", 2, { 402668, 15286, 15290, 461966, 1237618 }),  -- Vampiric Touch, Vampiric Embrace
	D("debuff", 3, { 2944, 19276, 19277, 19278, 19279, 19280, 425204 }), -- Devouring Plague, Void Plague
	D("debuff", 4, { 431655, 14914, 15261, 15262, 15263, 15264, 15265, 15266, 15267, 17140, 17141, 17142, 18165, 23860 }), -- Mind Spike, Holy Fire
	D("debuff", 5, ANY{ 8122, 8124, 10888, 10890, 15398, 27610, 9484, 9485, 10955 }), -- Psychic Scream, Shackle Undead
	B("proc", 1, { 431666, 413247 }),                           -- Surge of Light, Serendipity
}

forever.DRUID = {
	B("def", 1, { 22812, 428713 }),                             -- Barkskin
	B("def", 2, { 408024, 22842, 428708 }),                     -- Survival Instincts, Frenzied Regeneration
	B("def", 3, { 1850, 9821, 23099, 23109, 23110 }),           -- Dash
	B("def", 4, { 16689, 16810, 16811, 16812, 16813, 17329 }),  -- Nature's Grasp
	B("buff", 1, { 5217 }),                                     -- Tiger's Fury
	B("buff", 2, { 407988, 407989 }),                           -- Savage Roar
	B("buff", 3, { 417141, 442211 }),                           -- Berserk
	B("buff", 4, ANY{ 774, 1058, 1430, 2090, 2091, 3627, 8070, 8910, 9839, 9840, 9841, 25299, 417057, 417058, 417059, 417060, 417061, 417062, 417063, 417064, 417065, 417066, 417068, 408124 }), -- Rejuvenation, Lifebloom
	B("buff", 5, ANY{ 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858, 436937, 436938, 436939, 436940, 436942, 436943, 436944, 436945, 436946, 408120, 1238214, 1238215 }), -- Regrowth, Wild Growth
	B("buff", 6, ANY{ 29166, 456195 }),                         -- Innervate
	D("debuff", 1, { 8921, 8924, 8925, 8926, 8927, 8928, 8929, 9833, 9834, 9835, 20690, 21669, 429823 }), -- Moonfire
	D("debuff", 2, { 414684, 414687, 414689, 5570, 24974, 24975, 24976, 24977 }), -- Sunfire, Insect Swarm
	D("debuff", 3, ANY{ 770, 778, 9749, 9907, 13424, 13752 }), -- Faerie Fire
	D("debuff", 4, { 1822, 1823, 1824, 9904, 24331, 24332, 27556, 27638, 9007, 9824, 9826, 24118, 24119, 24120, 414644, 1235826, 1235827, 1299332 }), -- Rake, Pounce Bleed, Lacerate
	D("debuff", 5, { 1079, 9492, 9493, 9752, 9894, 9896 }),     -- Rip
	D("debuff", 6, ANY{ 99, 1735, 9490, 9747, 9898, 339, 1062, 5195, 5196, 9852, 9853, 19970, 19971, 19972, 19973, 19974, 19975, 2637, 18657, 18658, 5211, 6798, 8983 }), -- Demoralizing Roar, Entangling Roots, Hibernate, Bash
	B("proc", 1, { 16870 }),                                    -- Clearcasting
	B("proc", 2, { 17116 }),                                    -- Nature's Swiftness
	B("proc", 3, { 408255, 414800 }),                           -- Eclipse, Fury of Stormrage
	B("proc", 4, { 5229, 25503 }),                              -- Enrage
}

forever.SHAMAN = {
	B("def", 1, ANY{ 408521, 1239242, 1239243 }),               -- Riptide
	B("buff", 1, ANY{ 16191, 17355, 17360 }),                   -- Mana Tide
	B("proc", 2, { 415105, 440285, 468526 }),                   -- Power Surge
	B("buff", 2, { 409324 }),                                   -- Ancestral Guidance
	D("debuff", 1, { 8050, 8052, 8053, 10447, 10448, 29228 }),  -- Flame Shock
	D("debuff", 2, ANY{ 8056, 8058, 10472, 10473, 3600 }),      -- Frost Shock, Earthbind
	D("debuff", 3, ANY{ 17364 }),                               -- Stormstrike
	B("proc", 1, { 408505 }),                                   -- Maelstrom Weapon
	B("proc", 3, { 16188, 432041 }),                            -- Nature's Swiftness, Tidal Waves
}

forever.PALADIN = {
	B("def", 1, { 642, 1020, 498, 5573, 458312, 458371 }),      -- Divine Shield, Divine Protection
	B("def", 2, ANY{ 1022, 5599, 10278, 442948 }),              -- Blessing of Protection
	PD("def", 3, { 25771 }),                                    -- Forbearance
	B("def", 4, { 20925, 20927, 20928 }),                       -- Holy Shield
	B("def", 5, { 53601, 58597, 412018, 412019, 440651 }),      -- Sacred Shield
	B("def", 6, ANY{ 1044 }),                                   -- Blessing of Freedom
	B("buff", 1, { 20154, 20287, 20288, 20289, 20290, 20291, 20292, 20293, 21084 }), -- Seal of Righteousness
	B("buff", 1, { 20375, 20915, 20918, 20919, 20920 }),        -- Seal of Command
	B("buff", 1, { 20162, 20305, 20306, 20307, 20308, 21082 }), -- Seal of the Crusader
	B("buff", 1, { 20163, 20419, 20421, 20422, 20423, 1311649, 1311656 }), -- Seal of Fury
	B("buff", 1, { 407798 }),                                   -- Seal of Martyrdom
	B("buff", 1, { 20166, 20356, 20357, 20165, 20347, 20348, 20349, 20164 }), -- Seal of Wisdom, Seal of Light, Seal of Justice
	B("buff", 2, { 407788 }),                                   -- Avenging Wrath
	B("buff", 3, { 20216 }),                                    -- Divine Favor
	D("debuff", 1, ANY{ 20188, 20300, 20301, 20302, 20303, 21183, 456496 }), -- Judgement of the Crusader
	D("debuff", 2, ANY{ 20185, 20344, 20345, 20346, 20186, 20354, 20355 }), -- Judgement of Light, Judgement of Wisdom
	D("debuff", 3, ANY{ 20184 }),                               -- Judgement of Justice
	D("debuff", 4, ANY{ 853, 5588, 5589, 10308 }),              -- Hammer of Justice
	D("debuff", 5, { 1280345, 1280346, 1280347, 1280348, 1280349, 1280353 }), -- Consecration (debuff while the target stands in it)
	B("proc", 1, { 53489 }),                                    -- The Art of War
	B("proc", 2, { 53672, 437063 }),                            -- Infusion of Light
}

------------------------------------------------------------------------
-- Retail (Midnight)
------------------------------------------------------------------------

local retail = {}

retail.DEATHKNIGHT = {
	B("def", 1, { 48792 }),              -- Icebound Fortitude
	B("def", 2, { 48707 }),              -- Anti-Magic Shell
	B("def", 3, { 55233 }),              -- Vampiric Blood
	B("def", 4, { 81256 }),              -- Dancing Rune Weapon
	B("buff", 1, { 195181 }),            -- Bone Shield
	B("buff", 2, { 188290 }),            -- Death and Decay
	P("buff", 3, { 63560 }),             -- Dark Transformation
	B("buff", 4, { 51271 }),             -- Pillar of Frost
	D("debuff", 1, { 55095, 55078, 191587 }), -- Frost Fever, Blood Plague, Virulent Plague
	D("debuff", 2, { 194310 }),          -- Festering Wound
	D("debuff", 3, { 343294 }),          -- Soul Reaper
	B("proc", 1, { 51124, 81340, 81141 }), -- Killing Machine, Sudden Doom, Crimson Scourge
	B("proc", 2, { 59052 }),             -- Rime
}

retail.DEMONHUNTER = {
	B("def", 1, { 212800 }),             -- Blur
	B("def", 2, { 203819 }),             -- Demon Spikes
	B("def", 3, { 196555 }),             -- Netherwalk
	B("def", 4, ANY{ 209426 }),          -- Darkness
	B("buff", 1, { 162264, 187827 }),    -- Metamorphosis
	B("buff", 2, { 208628 }),            -- Momentum
	B("buff", 3, { 258920 }),            -- Immolation Aura
	B("buff", 4, { 203981 }),            -- Soul Fragments
	D("debuff", 1, { 207771 }),          -- Fiery Brand
	D("debuff", 2, { 247456 }),          -- Frailty
	D("debuff", 3, { 320338 }),          -- Essence Break
	D("debuff", 4, { 204598 }),          -- Sigil of Flame
	B("proc", 1, { 347462 }),            -- Unbound Chaos
}

retail.DRUID = {
	B("def", 1, { 22812 }),              -- Barkskin
	B("def", 2, { 61336 }),              -- Survival Instincts
	B("def", 3, { 192081 }),             -- Ironfur
	B("def", 4, { 22842 }),              -- Frenzied Regeneration
	B("buff", 1, { 5217 }),              -- Tiger's Fury
	B("buff", 2, { 145152 }),            -- Bloodtalons
	B("buff", 3, { 48517, 48518 }),      -- Eclipse (Solar, Lunar)
	B("buff", 4, { 106951, 102543, 102560, 102558 }), -- Berserk / Incarnations
	B("buff", 5, { 69369 }),             -- Predatory Swiftness
	D("debuff", 1, { 164812 }),          -- Moonfire
	D("debuff", 2, { 164815 }),          -- Sunfire
	D("debuff", 3, { 155722 }),          -- Rake
	D("debuff", 4, { 1079 }),            -- Rip
	D("debuff", 5, { 405233, 192090, 106830 }), -- Thrash
	D("debuff", 6, { 202347 }),          -- Stellar Flare
	B("proc", 1, { 135700, 16870 }),     -- Clearcasting
	B("proc", 2, { 93622, 157228 }),     -- Gore, Owlkin Frenzy
}

retail.EVOKER = {
	B("def", 1, { 363916 }),             -- Obsidian Scales
	B("def", 2, { 374348 }),             -- Renewing Blaze
	B("def", 3, { 358267 }),             -- Hover
	B("buff", 1, { 375087 }),            -- Dragonrage
	B("buff", 2, { 395296 }),            -- Ebon Might
	B("buff", 3, { 370553 }),            -- Tip the Scales
	D("debuff", 1, { 357209 }),          -- Fire Breath
	D("debuff", 2, { 370452 }),          -- Shattering Star
	B("proc", 1, { 359618, 392268 }),    -- Essence Burst
	B("proc", 2, { 375802 }),            -- Burnout
}

retail.HUNTER = {
	B("def", 1, { 186265 }),             -- Aspect of the Turtle
	B("def", 2, { 264735 }),             -- Survival of the Fittest
	B("def", 3, { 186257 }),             -- Aspect of the Cheetah
	B("buff", 1, { 19574 }),             -- Bestial Wrath
	P("buff", 2, { 272790 }),            -- Frenzy (pet)
	P("buff", 3, { 118455 }),            -- Beast Cleave (pet)
	B("buff", 4, { 288613 }),            -- Trueshot
	B("buff", 5, { 257622 }),            -- Trick Shots
	B("buff", 6, { 260286 }),            -- Tip of the Spear
	D("debuff", 1, ANY{ 257284 }),       -- Hunter's Mark
	D("debuff", 2, { 271788 }),          -- Serpent Sting
	D("debuff", 3, { 217200 }),          -- Barbed Shot
	D("debuff", 4, { 212431 }),          -- Explosive Shot
	B("proc", 1, { 260242, 194594 }),    -- Precise Shots, Lock and Load
	B("proc", 2, { 259388 }),            -- Mongoose Fury
}

retail.MAGE = {
	B("def", 1, { 45438 }),              -- Ice Block
	B("def", 2, { 11426, 235313, 235450 }), -- Ice / Blazing / Prismatic Barrier
	B("def", 3, { 342246 }),             -- Alter Time
	B("def", 4, { 55342 }),              -- Mirror Image
	B("buff", 1, { 190319, 12472, 365362 }), -- Combustion, Icy Veins, Arcane Surge
	B("buff", 2, { 48107 }),             -- Heating Up
	D("debuff", 1, ANY{ 228358 }),       -- Winter's Chill
	D("debuff", 2, { 210824 }),          -- Touch of the Magi
	D("debuff", 3, { 217694 }),          -- Living Bomb
	B("proc", 1, { 48108, 44544, 263725 }), -- Hot Streak, Fingers of Frost, Clearcasting
	B("proc", 2, { 190446 }),            -- Brain Freeze
}

retail.MONK = {
	B("def", 1, { 120954 }),             -- Fortifying Brew
	B("def", 2, { 122783, 122278 }),     -- Diffuse Magic, Dampen Harm
	B("def", 3, { 125174 }),             -- Touch of Karma
	B("def", 4, { 322507 }),             -- Celestial Brew
	PD("buff", 1, { 124273, 124274, 124275 }), -- Heavy, Moderate, Light Stagger
	B("buff", 2, { 215479 }),            -- Shuffle
	B("buff", 3, { 202090 }),            -- Teachings of the Monastery
	D("debuff", 1, { 228287 }),          -- Mark of the Crane
	D("debuff", 2, { 121253 }),          -- Keg Smash
	B("proc", 1, { 116768 }),            -- Blackout Kick!
	B("proc", 2, { 325202 }),            -- Dance of Chi-Ji
}

retail.PALADIN = {
	B("def", 1, ANY{ 642, 1022 }),       -- Divine Shield, Blessing of Protection
	B("def", 2, { 31850 }),              -- Ardent Defender
	B("def", 3, { 86659, 212641 }),      -- Guardian of Ancient Kings
	B("def", 4, { 498, 403876 }),        -- Divine Protection
	B("buff", 1, { 132403 }),            -- Shield of the Righteous
	B("buff", 2, { 188370 }),            -- Consecration
	B("buff", 3, { 31884 }),             -- Avenging Wrath
	B("buff", 4, { 223819 }),            -- Divine Purpose
	PD("buff", 5, { 25771 }),            -- Forbearance
	D("debuff", 1, { 197277 }),          -- Judgment
	D("debuff", 2, { 343721 }),          -- Final Reckoning
	D("debuff", 3, { 383346 }),          -- Expurgation
	B("proc", 1, { 54149 }),             -- Infusion of Light
	B("proc", 2, { 327510 }),            -- Shining Light
}

retail.PRIEST = {
	B("def", 1, { 47585 }),              -- Dispersion
	B("def", 2, ANY{ 17 }),              -- Power Word: Shield
	B("def", 3, { 19236 }),              -- Desperate Prayer
	B("def", 4, { 586 }),                -- Fade
	B("buff", 1, { 194249 }),            -- Voidform
	B("buff", 2, ANY{ 10060 }),          -- Power Infusion
	B("buff", 3, { 194384 }),            -- Atonement
	B("buff", 4, { 391109 }),            -- Dark Ascension
	D("debuff", 1, { 34914 }),           -- Vampiric Touch
	D("debuff", 2, { 589, 204213 }),     -- Shadow Word: Pain, Purge the Wicked
	D("debuff", 3, { 335467 }),          -- Devouring Plague
	B("proc", 1, { 114255, 373204 }),    -- Surge of Light, Mind Devourer
	B("proc", 2, { 392511 }),            -- Deathspeaker
}

retail.ROGUE = {
	B("def", 1, { 5277 }),               -- Evasion
	B("def", 2, { 31224 }),              -- Cloak of Shadows
	B("def", 3, { 1966 }),               -- Feint
	B("def", 4, { 185311 }),             -- Crimson Vial
	B("buff", 1, { 315496 }),            -- Slice and Dice
	B("buff", 2, { 185422 }),            -- Shadow Dance
	B("buff", 3, { 212283 }),            -- Symbols of Death
	B("buff", 4, { 13750 }),             -- Adrenaline Rush
	B("buff", 5, { 193356, 193359, 193357, 199603, 199600, 193358 }), -- Roll the Bones
	B("buff", 6, { 13877 }),             -- Blade Flurry
	D("debuff", 1, { 1943 }),            -- Rupture
	D("debuff", 2, { 703 }),             -- Garrote
	D("debuff", 3, { 2818 }),            -- Deadly Poison
	D("debuff", 4, { 121411 }),          -- Crimson Tempest
	D("debuff", 5, ANY{ 408 }),          -- Kidney Shot
	B("proc", 1, { 195627 }),            -- Opportunity
	B("proc", 2, { 386270 }),            -- Audacity
}

retail.SHAMAN = {
	B("def", 1, { 108271 }),             -- Astral Shift
	B("def", 2, { 79206 }),              -- Spiritwalker's Grace
	B("buff", 1, { 114050, 114051 }),    -- Ascendance
	B("buff", 2, { 384352 }),            -- Doom Winds
	B("buff", 3, { 187878 }),            -- Crash Lightning
	B("buff", 4, { 260734 }),            -- Master of the Elements
	B("buff", 5, { 53390 }),             -- Tidal Waves
	D("debuff", 1, { 188389 }),          -- Flame Shock
	D("debuff", 2, { 334168 }),          -- Lashing Flames
	B("proc", 1, { 77762, 215785 }),     -- Lava Surge, Hot Hand
	B("proc", 2, { 344179, 201846 }),    -- Maelstrom Weapon, Stormbringer
}

retail.WARLOCK = {
	B("def", 1, { 104773 }),             -- Unending Resolve
	B("def", 2, { 108416 }),             -- Dark Pact
	B("buff", 1, { 117828 }),            -- Backdraft
	B("buff", 2, { 264173 }),            -- Demonic Core
	B("buff", 3, { 264571 }),            -- Nightfall
	B("buff", 4, { 387079 }),            -- Tormented Crescendo
	D("debuff", 1, { 980 }),             -- Agony
	D("debuff", 2, { 146739 }),          -- Corruption
	D("debuff", 3, { 316099 }),          -- Unstable Affliction
	D("debuff", 4, { 157736, 445474 }),  -- Immolate, Wither
	D("debuff", 5, { 48181, 80240 }),    -- Haunt, Havoc
	D("debuff", 6, { 63106 }),           -- Siphon Life
	B("proc", 1, { 205146 }),            -- Demonic Calling
	B("proc", 2, { 387157 }),            -- Ritual of Ruin
}

retail.WARRIOR = {
	B("def", 1, { 871 }),                -- Shield Wall
	B("def", 2, { 12975, 118038 }),      -- Last Stand, Die by the Sword
	B("def", 3, { 184364 }),             -- Enraged Regeneration
	B("def", 4, { 23920 }),              -- Spell Reflection
	B("buff", 1, { 132404 }),            -- Shield Block
	B("buff", 2, { 190456 }),            -- Ignore Pain
	B("buff", 3, { 1719, 107574 }),      -- Recklessness, Avatar
	B("buff", 4, { 85739 }),             -- Whirlwind (Meat Cleaver)
	B("buff", 5, { 260708 }),            -- Sweeping Strikes
	D("debuff", 1, { 388539 }),          -- Rend
	D("debuff", 2, { 208086 }),          -- Colossus Smash
	D("debuff", 3, ANY{ 6343 }),         -- Thunder Clap
	B("proc", 1, { 184362 }),            -- Enrage
	B("proc", 2, { 52437, 280776 }),     -- Sudden Death
}

Defaults.presets = {
	forever = forever,
	retail = retail,
}

function Defaults.Icons(gameKey, class)
	local preset = Defaults.presets[gameKey] and Defaults.presets[gameKey][class]
	return preset and ns.CopyTable(preset) or {}
end
