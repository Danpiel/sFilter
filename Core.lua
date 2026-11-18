--[[
	sFilter
	Based on sFilter (c) 2009 Nils Ruesch, edited by ALZA and Danpiel.
]]

local ADDON, ns = ...
_G.sFilter = ns

local L = ns.L

local tocversion = select(4, GetBuildInfo())
ns.tocversion = tocversion
ns.isForever = (WOW_PROJECT_CAMELOT ~= nil and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT)
	or (tocversion >= 16000 and tocversion < 20000)
ns.gameKey = ns.isForever and "forever" or "retail"
ns.version = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(ADDON, "Version")) or "dev"
ns.mediaPath = "Interface\\AddOns\\" .. ADDON .. "\\Textures\\"

ns.UNITS = { "player", "target", "pet", "focus" }
ns.FILTERS = { "HELPFUL", "HARMFUL" }
ns.TRACKS = { "aura", "cooldown" }
ns.DIRECTIONS = { "RIGHT", "LEFT", "UP", "DOWN" }

ns.unlocked = false

------------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------------

function ns:Print(...)
	print("|cFFFF8C00sFilter|r:", ...)
end

function ns.CopyTable(src)
	if type(src) ~= "table" then
		return src
	end
	local dst = {}
	for k, v in pairs(src) do
		dst[k] = ns.CopyTable(v)
	end
	return dst
end

function ns.Clamp(value, low, high)
	if value < low then
		return low
	end
	if value > high then
		return high
	end
	return value
end

function ns.Round(value)
	return math.floor(value + 0.5)
end

-- Timer text without leading zeros: seconds below a minute ("5", "45"), m:ss from a minute on
-- ("1:05", "12:30").
local SECONDS_FORMAT = "%d"
local MINUTES_FORMAT = "%d:%02d"

function ns.FormatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	if seconds < 60 then
		return string.format(SECONDS_FORMAT, seconds)
	end
	return string.format(MINUTES_FORMAT, math.floor(seconds / 60), seconds % 60)
end

-- The same format for Blizzard's aura buttons, which format their (secret) timers themselves
-- with a numeric rule formatter. Returns nil if the client has no such formatter.
function ns.GetTimerFormatter()
	if ns.timerFormatter == nil then
		ns.timerFormatter = false
		if C_StringUtil and C_StringUtil.CreateNumericRuleFormatter then
			local down = Enum.NumericRuleFormatRounding and Enum.NumericRuleFormatRounding.Down or 2
			local ok, formatter = pcall(C_StringUtil.CreateNumericRuleFormatter)
			if ok and formatter and pcall(formatter.SetBreakpoints, formatter, {
				{
					threshold = 0,
					step = 1,
					rounding = down,
					format = SECONDS_FORMAT,
				},
				{
					threshold = 60,
					format = MINUTES_FORMAT,
					components = {
						{ div = 60, step = 1, rounding = down },
						{ mod = 60, step = 1, rounding = down },
					},
				},
			}) then
				ns.timerFormatter = formatter
			end
		end
	end
	return ns.timerFormatter or nil
end

function ns.IsHorizontal(direction)
	return direction == "RIGHT" or direction == "LEFT"
end

-- Returns the spell name and icon for a spell ID, or nil while the spell data is not cached yet.
function ns.GetSpellNameAndIcon(spellID)
	if C_Spell and C_Spell.GetSpellName then
		return C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
	end
	if GetSpellInfo then
		local name, _, icon = GetSpellInfo(spellID)
		return name, icon
	end
end

function ns.DoesSpellExist(spellID)
	if C_Spell and C_Spell.DoesSpellExist then
		return C_Spell.DoesSpellExist(spellID)
	end
	return ns.GetSpellNameAndIcon(spellID) ~= nil
end

-- Aura data is "secret" for addons in combat, encounters, M+ and PvP matches (Midnight / Forever).
function ns.AreAurasSecret()
	if C_Secrets and C_Secrets.ShouldAurasBeSecret then
		return C_Secrets.ShouldAurasBeSecret() and true or false
	end
	return false
end

function ns.IsSecret(value)
	return issecretvalue ~= nil and issecretvalue(value) or false
end

------------------------------------------------------------------------
-- Refresh pipeline
------------------------------------------------------------------------

-- Rebuilds everything after the profile (icons or groups) changed.
function ns:RefreshAll()
	if not self.profile then
		return
	end
	self.Tracker:Rebuild()
	self.Display:Rebuild()
	self.Native:Rebuild()
	self.CDM:Rebuild()
	self.Tracker:ScanAll()
	if self.Options then
		self.Options:Refresh()
	end
end

-- Repositions groups and slots without rebuilding trackers.
function ns:RefreshLayout()
	if not self.profile then
		return
	end
	self.Display:Layout()
	self.Native:Reanchor()
	self.CDM:Reanchor()
	if self.Options then
		self.Options:Refresh()
	end
end

function ns:SetUnlocked(unlocked)
	unlocked = unlocked and true or false
	if self.unlocked == unlocked then
		return
	end
	self.unlocked = unlocked
	self.Display:UpdateUnlocked()
	if self.Options then
		self.Options:Refresh()
	end
end

function ns:ToggleUnlocked()
	self:SetUnlocked(not self.unlocked)
	if self.unlocked then
		self:Print(L["Movers unlocked: drag groups with the left mouse button, right-click for options."])
	else
		self:Print(L["Groups locked."])
	end
end

------------------------------------------------------------------------
-- Slash commands and addon compartment
------------------------------------------------------------------------

local function HandleSlash(msg)
	local command = strtrim((msg or ""):lower())
	if command == "" or command == "config" or command == "options" then
		ns.Options:Toggle()
	elseif command == "unlock" or command == "move" then
		ns:SetUnlocked(true)
	elseif command == "lock" then
		ns:SetUnlocked(false)
	elseif command == "toggle" then
		ns:ToggleUnlocked()
	elseif command == "export" then
		ns.Options:Show("profile")
		ns.Options:ShowExport()
	elseif command == "import" then
		ns.Options:Show("profile")
	elseif command == "cdm" then
		ns.Options:Show("cdm")
	elseif command == "reset" then
		ns.Options:ConfirmResetProfile()
	else
		ns:Print(L["Commands:"])
		print("  /sf - " .. L["open settings"])
		print("  /sf unlock | lock | toggle - " .. L["move or lock icon groups"])
		print("  /sf export | import - " .. L["share settings"])
		print("  /sf cdm - " .. L["Cooldown Manager status"])
		print("  /sf reset - " .. L["reset the profile of this class"])
	end
end

SLASH_SFILTER1 = "/sf"
SLASH_SFILTER2 = "/sfilter"
SlashCmdList.SFILTER = HandleSlash

function sFilter_OnAddonCompartmentClick(_, button)
	if button == "RightButton" then
		ns:ToggleUnlocked()
	else
		ns.Options:Toggle()
	end
end

function sFilter_OnAddonCompartmentEnter(_, menuButtonFrame)
	GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_LEFT")
	GameTooltip:SetText("sFilter")
	GameTooltip:AddLine(L["Left click: settings"], 1, 1, 1)
	GameTooltip:AddLine(L["Right click: unlock / lock groups"], 1, 1, 1)
	GameTooltip:Show()
end

function sFilter_OnAddonCompartmentLeave()
	GameTooltip:Hide()
end

------------------------------------------------------------------------
-- Startup
------------------------------------------------------------------------

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self, event, name)
	if event == "ADDON_LOADED" then
		if name == ADDON then
			ns:InitDB()
		elseif ns.CDM then
			ns.CDM:OnAddonLoaded(name)
		end
	elseif event == "PLAYER_LOGIN" then
		ns.playerClass = select(2, UnitClass("player"))
		ns:LoadProfile()
		ns.Skin:Init()
		ns.Display:Init()
		ns.Tracker:Init()
		ns.Native:Init()
		ns.CDM:Init()
		ns.Options:Init()
		ns.Ellesmere:Init()
		ns:RefreshAll()
		self:UnregisterEvent("PLAYER_LOGIN")
	end
end)
