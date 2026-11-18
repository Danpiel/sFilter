-- EllesmereUI integration. With EllesmereUI installed, sFilter's settings get a section of their own
-- in EllesmereUI's settings panel through its plugin API (EllesmereUI/PLUGINS_API.md): one module
-- with a tab per sFilter page. A tab shows the same page frame as sFilter's own window; the frame
-- moves into the tab when the tab is shown and back when sFilter's window opens. EllesmereUI's
-- panel does not open in combat, so /sf falls back to sFilter's window there.

local _, ns = ...
local L = ns.L

local Ellesmere = {}
ns.Ellesmere = Ellesmere

local PLUGIN_ID = "sFilter"
local MODULE_KEY = "settings"
local TOOLBAR_HEIGHT = 34
-- EllesmereUI's panel draws one unit per screen pixel and sizes its text for that; sFilter's pages
-- are laid out for the normal UI scale, so a tab shows them enlarged to match EllesmereUI's text.
local SCALE = 1.25

local function GetAPI()
	local eui = _G.EllesmereUI
	if type(eui) == "table" and type(eui.RegisterPlugin) == "function" then
		return eui
	end
end

function Ellesmere:IsActive()
	return self.api ~= nil
end

-- Shows the page of a tab, called whenever EllesmereUI shows the tab.
function Ellesmere:ShowHost(host)
	if host:IsVisible() then
		ns.Options:ShowEmbedded(host.page, host.body)
	end
end

-- Builds one tab: a toolbar (unlock button, profile) above the page, scaled and centered.
function Ellesmere:BuildPage(pageName, parent, yOffset)
	local page = self.pageByTitle[pageName]
	local Options = ns.Options
	yOffset = yOffset or 0
	local height = (Options.PAGE_HEIGHT + TOOLBAR_HEIGHT) * SCALE - yOffset + 12
	local api = self.api
	if not page or (api and type(api.IsSearchPrebuild) == "function" and api.IsSearchPrebuild()) then
		return height
	end

	local host = CreateFrame("Frame", nil, parent)
	host:SetScale(SCALE)
	host:SetSize(Options.PAGE_WIDTH, Options.PAGE_HEIGHT + TOOLBAR_HEIGHT)
	host:SetPoint("TOP", parent, "TOP", 0, yOffset / SCALE)
	host.page = page

	local profile = Options:CreateProfileText(host)
	profile:SetPoint("TOPLEFT", 6, -10)
	local unlock = Options:CreateUnlockButton(host)
	unlock:SetPoint("TOPRIGHT", -2, -4)

	host.body = CreateFrame("Frame", nil, host)
	host.body:SetPoint("TOPLEFT", 0, -TOOLBAR_HEIGHT)
	host.body:SetPoint("BOTTOMRIGHT")
	host:SetScript("OnShow", function(frame)
		Ellesmere:ShowHost(frame)
	end)
	self.hosts[page] = host
	self:ShowHost(host)
	return height
end

function Ellesmere:Init()
	self.hosts = {}
	self.pageByTitle = {}
	self.api = nil
	local api = GetAPI()
	if not api then
		return
	end

	local Options = ns.Options
	local titles = {}
	for _, page in ipairs(Options.PAGES) do
		local title = Options.PAGE_TITLES[page]
		titles[#titles + 1] = title
		self.pageByTitle[title] = page
	end

	local ok, registered = pcall(api.RegisterPlugin, PLUGIN_ID, {
		label = "sFilter",
		modules = {
			{
				key = MODULE_KEY,
				title = L["Buffs and debuffs"],
				description = L["Debuffs on your target and buffs on you and your pet that matter for your rotation."]
					.. "  |cFF999999" .. ns.version .. "|r",
				pages = titles,
				buildPage = function(pageName, parent, yOffset)
					return Ellesmere:BuildPage(pageName, parent, yOffset)
				end,
				onPageCacheRestore = function(pageName)
					local host = Ellesmere.hosts[Ellesmere.pageByTitle[pageName]]
					if host then
						Ellesmere:ShowHost(host)
					end
				end,
				onModuleLeave = function()
					Options.embedded = nil
				end,
				-- The pages are sFilter's own frames, not EllesmereUI widgets: nothing to index.
				searchPrebuild = false,
			},
		},
	})
	if ok and registered then
		self.api = api
	end
end

-- Opens EllesmereUI's panel on a page; false when it is not there or cannot open (combat).
function Ellesmere:Open(page)
	local api = self.api
	if not api or type(api.OpenPlugin) ~= "function" or InCombatLockdown() then
		return false
	end
	local ok, opened = pcall(api.OpenPlugin, PLUGIN_ID, MODULE_KEY, ns.Options.PAGE_TITLES[page])
	return ok and opened == true
end
