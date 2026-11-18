-- Settings window: icons, groups, profile export/import and Cooldown Manager status.
-- Built from stock Blizzard templates; Skin.lua restyles every widget (EllesmereUI's look, or
-- ElvUI's when ElvUI is loaded). With EllesmereUI installed the same pages are shown inside its
-- settings panel instead (Ellesmere.lua); this window then opens only where that panel cannot.

local _, ns = ...
local L = ns.L

local Options = {}
ns.Options = Options

local Skin = ns.Skin
local RT = ns.RT
local Profile = ns.Profile

local WIDTH, HEIGHT = 800, 580
local NAV_WIDTH = 150
local HEADER_HEIGHT = 38
local PAGES = { "icons", "groups", "profile", "cdm" }
-- Size of a page; Ellesmere.lua lays EllesmereUI's tabs out for it.
Options.PAGE_WIDTH, Options.PAGE_HEIGHT = WIDTH - NAV_WIDTH - 26, HEIGHT - 58
Options.PAGES = PAGES
Options.PAGE_TITLES = { icons = L["Icons"], groups = L["Groups"], profile = L["Export / Import"], cdm = L["Cooldown Manager"] }

local UNIT_LABELS = { player = L["Me"], target = L["Target"], pet = L["Pet"], focus = L["Focus"] }
local FILTER_LABELS = { HELPFUL = L["Buff"], HARMFUL = L["Debuff"] }
local DIRECTION_LABELS = { RIGHT = L["Right"], LEFT = L["Left"], UP = L["Up"], DOWN = L["Down"] }

local GREEN, YELLOW, RED, GREY = "|cFF33DD33", "|cFFFFCC33", "|cFFFF4444", "|cFF999999"

------------------------------------------------------------------------
-- Widget helpers
------------------------------------------------------------------------

local function Text(parent, text, size, template)
	local fontString = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
	Skin:FontString(fontString, size or 12)
	fontString:SetJustifyH("LEFT")
	fontString:SetText(text or "")
	return fontString
end

local function Header(parent, text)
	local fontString = Text(parent, text, 14)
	fontString:SetTextColor(Skin:AccentColor())
	return fontString
end

local function Button(parent, text, width, onClick)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width or 110, 22)
	button:SetText(text)
	button:SetScript("OnClick", onClick)
	Skin:Button(button)
	return button
end

local function EditBox(parent, width, onCommit)
	local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	editBox:SetSize(width, 20)
	editBox:SetAutoFocus(false)
	editBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)
	editBox:SetScript("OnEscapePressed", function(self)
		self.revert = true
		self:ClearFocus()
	end)
	editBox:SetScript("OnEditFocusLost", function(self)
		if self.revert then
			self.revert = nil
			Options:Refresh()
			return
		end
		if onCommit then
			onCommit(self:GetText())
		end
	end)
	Skin:EditBox(editBox)
	return editBox
end

-- Label above an edit box, returns the edit box.
local function LabeledEditBox(parent, label, width, onCommit)
	local editBox = EditBox(parent, width, onCommit)
	editBox.label = Text(parent, label, 11, "GameFontNormalSmall")
	editBox.label:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", -4, 2)
	return editBox
end

local function Check(parent, text, onClick)
	local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	check:SetSize(24, 24)
	check.Text:SetText(text)
	Skin:FontString(check.Text, 12)
	check:SetScript("OnClick", function(self)
		onClick(self:GetChecked() and true or false)
	end)
	Skin:CheckBox(check)
	return check
end

-- entries() returns { {text=, value=}, ... }
local function Dropdown(parent, width, entries, isSelected, onSelect)
	local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
	dropdown:SetWidth(width)
	dropdown:SetupMenu(function(_, root)
		for _, entry in ipairs(entries()) do
			root:CreateRadio(entry.text, function()
				return isSelected(entry.value)
			end, function()
				onSelect(entry.value)
			end, entry.value)
		end
	end)
	Skin:Dropdown(dropdown, width)
	return dropdown
end

local function LabeledDropdown(parent, label, width, entries, isSelected, onSelect)
	local dropdown = Dropdown(parent, width, entries, isSelected, onSelect)
	dropdown.label = Text(parent, label, 11, "GameFontNormalSmall")
	dropdown.label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 2)
	return dropdown
end

local function List(parent, width, height, rowHeight, initializer)
	local scrollBox = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
	scrollBox:SetSize(width, height)
	local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
	scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 6, 0)
	scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 6, 0)

	local view = CreateScrollBoxListLinearView()
	view:SetElementExtent(rowHeight)
	view:SetElementInitializer("Button", initializer)
	ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)
	Skin:ScrollBar(scrollBar)

	local background = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	background:SetPoint("TOPLEFT", scrollBox, -3, 3)
	background:SetPoint("BOTTOMRIGHT", scrollBox, 3, -3)
	background:SetFrameLevel(math.max(scrollBox:GetFrameLevel() - 1, 0))
	Skin:Panel(background)

	function scrollBox:SetItems(items)
		self:SetDataProvider(CreateDataProvider(items), ScrollBoxConstants.RetainScrollPosition)
	end
	return scrollBox
end

-- Shared look for list rows: icon, two lines of text, highlight and selection.
local function SetupRow(row, height)
	if row.created then
		return
	end
	row.created = true
	row:SetHeight(height)

	row.selected = row:CreateTexture(nil, "BACKGROUND")
	row.selected:SetAllPoints()
	local r, g, b = Skin:AccentColor()
	row.selected:SetColorTexture(r, g, b, 0.25)

	row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
	row.highlight:SetAllPoints()
	row.highlight:SetColorTexture(1, 1, 1, 0.08)

	row.tex = row:CreateTexture(nil, "ARTWORK")
	row.tex:SetSize(height - 6, height - 6)
	row.tex:SetPoint("LEFT", 4, 0)
	local coords = Skin:GetTexCoord()
	row.tex:SetTexCoord(coords[1], coords[2], coords[3], coords[4])

	row.title = Text(row, "", 12)
	row.title:SetPoint("TOPLEFT", row.tex, "TOPRIGHT", 6, -1)
	row.title:SetPoint("RIGHT", -4, 0)
	row.title:SetWordWrap(false)

	row.sub = Text(row, "", 10, "GameFontNormalSmall")
	row.sub:SetPoint("BOTTOMLEFT", row.tex, "BOTTOMRIGHT", 6, 1)
	row.sub:SetPoint("RIGHT", -4, 0)
	row.sub:SetWordWrap(false)
	row.sub:SetTextColor(0.7, 0.7, 0.7)
end

local function Confirm(text, onAccept)
	StaticPopupDialogs.SFILTER_CONFIRM = StaticPopupDialogs.SFILTER_CONFIRM or {
		text = "%s",
		button1 = YES,
		button2 = NO,
		OnAccept = function(_, data)
			if data then
				data()
			end
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	StaticPopup_Show("SFILTER_CONFIRM", text, nil, onAccept)
end

-- Accepts a spell ID, a spell link or the name of a spell in your spellbook.
local function ParseSpell(text)
	text = strtrim(text or "")
	if text == "" then
		return nil
	end
	local linked = text:match("spell:(%d+)")
	local id = tonumber(text) or (linked and tonumber(linked))
	if id then
		return id
	end
	if C_Spell and C_Spell.GetSpellInfo then
		local info = C_Spell.GetSpellInfo(text)
		if info and info.spellID then
			return info.spellID
		end
	end
end

local function ParseSpellList(text)
	local spells, seen = {}, {}
	for token in (text or ""):gmatch("[^,;]+") do
		local id = ParseSpell(token)
		if id and not seen[id] and #spells < Profile.LIMITS.spellsPerIcon then
			seen[id] = true
			spells[#spells + 1] = id
		end
	end
	return spells
end

local function GroupEntries()
	local entries = {}
	for _, group in ipairs(ns.profile.groups) do
		entries[#entries + 1] = { text = group.name, value = group.key }
	end
	return entries
end

local function ListEntries(list, labels)
	return function()
		local entries = {}
		for _, value in ipairs(list) do
			entries[#entries + 1] = { text = labels[value], value = value }
		end
		return entries
	end
end

local function StatusText(icon)
	local status = ns.Tracker:CombatStatus(icon)
	if status == "native" or status == "cooldown" then
		return GREEN .. L["works in combat"] .. "|r"
	elseif status == "cdm" then
		return GREEN .. L["in combat: via Cooldown Manager"] .. "|r"
	elseif status == "open" then
		return GREEN .. L["in combat: readable"] .. "|r"
	elseif ns.CDM:CanTrack(icon) then
		return YELLOW .. L["out of combat only: add it to Tracked Buffs in /cdm"] .. "|r"
	end
	return YELLOW .. L["out of combat only"] .. "|r"
end

local function StatusTag(icon)
	local status = ns.Tracker:CombatStatus(icon)
	if status == "native" or status == "cooldown" then
		return GREEN .. L["combat"] .. "|r"
	elseif status == "cdm" then
		return GREEN .. "CDM|r"
	elseif status == "open" then
		return GREEN .. L["combat"] .. "|r"
	end
	return YELLOW .. L["no combat"] .. "|r"
end

------------------------------------------------------------------------
-- Window
------------------------------------------------------------------------

function Options:Init()
	self.page = "icons"

	-- Entry in the game's Options > AddOns list that opens this window.
	if Settings and Settings.RegisterCanvasLayoutCategory then
		local panel = CreateFrame("Frame")
		local title = Header(panel, "sFilter")
		title:SetPoint("TOPLEFT", 16, -16)
		local open = Button(panel, L["Open settings"], 180, function()
			if SettingsPanel and SettingsPanel:IsShown() then
				HideUIPanel(SettingsPanel)
			end
			Options:Show()
		end)
		open:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
		local category = Settings.RegisterCanvasLayoutCategory(panel, "sFilter")
		Settings.RegisterAddOnCategory(category)
	end
end

function Options:Create()
	if self.frame then
		return
	end

	local frame = CreateFrame("Frame", "sFilterOptionsFrame", UIParent, "BackdropTemplate")
	frame:SetSize(WIDTH, HEIGHT)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("HIGH")
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:Hide()
	Skin:Window(frame)
	Skin:WindowChrome(frame, HEADER_HEIGHT, NAV_WIDTH)
	tinsert(UISpecialFrames, frame:GetName())
	self.frame = frame

	local title = Header(frame, "sFilter")
	Skin:FontString(title, 16)
	title:SetPoint("TOPLEFT", 14, -12)
	local subtitle = Text(frame, "by Danpiel  " .. GREY .. ns.version .. "  " .. (ns.isForever and "World of Warcraft: Forever" or "Retail") .. "|r", 11)
	subtitle:SetPoint("LEFT", title, "RIGHT", 10, -1)

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -2, -2)
	Skin:CloseButton(close)

	self.unlockButton = self:CreateUnlockButton(frame)
	self.unlockButton:SetPoint("TOPRIGHT", -36, -8)

	-- Navigation: a sidebar of page names, as in EllesmereUI's panel.
	self.navButtons = {}
	local previous
	for _, page in ipairs(PAGES) do
		local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		button:SetSize(NAV_WIDTH - 2, 28)
		button:SetText(Options.PAGE_TITLES[page])
		button:SetScript("OnClick", function()
			Options:ShowStandalone(page)
		end)
		Skin:NavButton(button)
		if previous then
			button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -2)
		else
			button:SetPoint("TOPLEFT", 1, -HEADER_HEIGHT - 8)
		end
		previous = button
		self.navButtons[page] = button
	end

	local classText = self:CreateProfileText(frame)
	classText:SetPoint("BOTTOMLEFT", 14, 12)
	classText:SetWidth(NAV_WIDTH - 14)

	-- Pages.
	self.pages = {}
	for _, page in ipairs(PAGES) do
		local container = CreateFrame("Frame", nil, frame)
		container:Hide()
		self.pages[page] = container
		self:AttachPage(page, frame)
	end

	self:BuildIconsPage(self.pages.icons)
	self:BuildGroupsPage(self.pages.groups)
	self:BuildProfilePage(self.pages.profile)
	self:BuildCDMPage(self.pages.cdm)
end

-- The unlock button and the profile line exist in this window and in every EllesmereUI tab.
function Options:CreateUnlockButton(parent)
	local button = Button(parent, ns.unlocked and L["Lock groups"] or L["Unlock groups"], 150, function()
		ns:ToggleUnlocked()
	end)
	self.unlockButtons = self.unlockButtons or {}
	table.insert(self.unlockButtons, button)
	return button
end

function Options:CreateProfileText(parent)
	local text = Text(parent, "", 11, "GameFontNormalSmall")
	text:SetTextColor(1, 1, 1, 0.55)
	local className = (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[ns.playerClass]) or ns.playerClass
	text:SetText(L["Profile:"] .. " " .. (className or "?"))
	return text
end

-- Moves a page into this window (host = self.frame) or into a tab of EllesmereUI's panel.
function Options:AttachPage(page, host)
	local container = self.pages[page]
	if container:GetParent() ~= host then
		container:SetParent(host)
	end
	container:ClearAllPoints()
	if host == self.frame then
		container:SetPoint("TOPLEFT", NAV_WIDTH + 12, -HEADER_HEIGHT - 8)
		container:SetPoint("BOTTOMRIGHT", -14, 12)
	else
		container:SetAllPoints(host)
	end
end

-- Opens the settings: inside EllesmereUI's panel when it is installed and can open (not in
-- combat), otherwise in this window.
function Options:Show(page, groupKey)
	if page then
		self.page = page
	end
	if groupKey then
		self.selectedGroup = groupKey
	end
	if ns.Ellesmere and ns.Ellesmere:Open(self.page) then
		return
	end
	self:ShowStandalone()
end

function Options:ShowStandalone(page)
	self:Create()
	if page then
		self.page = page
	end
	self.embedded = nil
	for name, container in pairs(self.pages) do
		self:AttachPage(name, self.frame)
		container:SetShown(name == self.page)
	end
	for name, button in pairs(self.navButtons) do
		button:SetEnabled(name ~= self.page)
		Skin:SetNavSelected(button, name == self.page)
	end
	self.frame:Show()
	self:Refresh()
end

-- Shows a page in a tab of EllesmereUI's panel (host is the frame Ellesmere.lua made there).
function Options:ShowEmbedded(page, host)
	self:Create()
	if self.frame:IsShown() then
		self.frame:Hide()
	end
	self.page = page
	self.embedded = host
	self:AttachPage(page, host)
	self.pages[page]:Show()
	self:Refresh()
end

function Options:IsOpen()
	if self.frame and self.frame:IsShown() then
		return true
	end
	return self.embedded ~= nil and self.embedded:IsVisible()
end

function Options:Toggle()
	if self.frame and self.frame:IsShown() then
		self.frame:Hide()
	else
		self:Show()
	end
end

function Options:Refresh()
	if not self:IsOpen() then
		return
	end
	for _, button in ipairs(self.unlockButtons or {}) do
		button:SetText(ns.unlocked and L["Lock groups"] or L["Unlock groups"])
	end
	if self.page == "icons" then
		self:RefreshIcons()
	elseif self.page == "groups" then
		self:RefreshGroups()
	elseif self.page == "cdm" then
		self:RefreshCDM()
	end
end

------------------------------------------------------------------------
-- Icons page
------------------------------------------------------------------------

local function SelectedIconIndex()
	for index, icon in ipairs(ns.profile.icons) do
		if icon == Options.selectedIcon then
			return index
		end
	end
end

-- Rows of the spell list in the icon editor: one per spell name (all of its ranks), with a button
-- that switches whose auras count for it.
local SPELL_ROW_HEIGHT = 20

local function ShowSourceTooltip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:SetText(L["Whose auras count"])
	GameTooltip:AddLine(L["Mine: cast by you or your pet."], 1, 1, 1, true)
	GameTooltip:AddLine(L["Anyone: cast by anyone."], 1, 1, 1, true)
	GameTooltip:AddLine(L["Click to switch."], 0.7, 0.7, 0.7, true)
	GameTooltip:Show()
end

local function HideTooltip()
	GameTooltip:Hide()
end

-- Switches one spell (every listed ID of it) between "yours only" and "anyone's".
function Options:ToggleSpellSource(item)
	local icon = self.selectedIcon
	if not icon or not item.ids then
		return
	end
	local any = {}
	for _, spellID in ipairs(icon.anySource or {}) do
		any[spellID] = true
	end
	for _, spellID in ipairs(item.ids) do
		any[spellID] = not item.any or nil
	end
	local anySource = {}
	for _, spellID in ipairs(icon.spells) do
		if any[spellID] then
			anySource[#anySource + 1] = spellID
		end
	end
	icon.anySource = anySource
	ns:RefreshAll()
end

local function SetupSpellRow(row, item)
	if not row.created then
		row.created = true
		row:SetHeight(SPELL_ROW_HEIGHT)
		row.source = Button(row, "", 64, function(button)
			Options:ToggleSpellSource(button.item)
		end)
		row.source:SetHeight(18)
		row.source:SetPoint("RIGHT", -2, 0)
		row.source:HookScript("OnEnter", ShowSourceTooltip)
		row.source:HookScript("OnLeave", HideTooltip)
		row.text = Text(row, "", 11, "GameFontNormalSmall")
		row.text:SetPoint("LEFT", 4, 0)
		row.text:SetPoint("RIGHT", row.source, "LEFT", -4, 0)
		row.text:SetWordWrap(false)
	end
	row.item = item
	row.source.item = item
	row.text:SetText(item.text)
	row.source:SetShown(item.ids ~= nil)
	if item.ids then
		row.source:SetText(item.any and L["Anyone"] or L["Mine"])
		row.source:SetEnabled(not item.cooldown)
	end
end

function Options:BuildIconsPage(page)
	local addBox = LabeledEditBox(page, L["Spell ID, link or name"], 170)
	addBox:SetPoint("TOPLEFT", 6, -16)
	addBox:SetScript("OnEditFocusLost", nil)
	local function AddIcon()
		local spellID = ParseSpell(addBox:GetText())
		if not spellID or not ns.DoesSpellExist(spellID) then
			ns:Print(L["Spell not found:"], addBox:GetText())
			return
		end
		local selected = Options.selectedIcon
		local groupKey = selected and selected.group or ns.profile.groups[1].key
		local harmful = C_Spell and C_Spell.IsSpellHarmful and C_Spell.IsSpellHarmful(spellID)
		local icon = {
			spells = { spellID },
			track = "aura",
			unit = harmful and "target" or "player",
			filter = harmful and "HARMFUL" or "HELPFUL",
			anySource = {},
			group = groupKey,
			slot = Profile.NextFreeSlot(ns.profile, groupKey),
			disabled = false,
		}
		table.insert(ns.profile.icons, icon)
		Options.selectedIcon = icon
		addBox:SetText("")
		addBox:ClearFocus()
		ns:RefreshAll()
	end
	addBox:SetScript("OnEnterPressed", AddIcon)
	local addButton = Button(page, L["Add"], 80, AddIcon)
	addButton:SetPoint("LEFT", addBox, "RIGHT", 6, 0)

	self.iconList = List(page, 266, 400, 32, function(row, icon)
		SetupRow(row, 32)
		if not row.onClickSet then
			row.onClickSet = true
			row:SetScript("OnClick", function(self)
				Options.selectedIcon = self.icon
				Options:RefreshIcons()
			end)
		end
		row.icon = icon
		local rt = RT[icon] or ns.Tracker:Resolve(icon)
		row.tex:SetTexture(rt.texture)
		row.tex:SetDesaturated(icon.disabled)
		local title = rt.label
		if #rt.order == 0 then
			title = RED .. title .. "|r"
		elseif icon.disabled then
			title = GREY .. title .. "|r"
		end
		row.title:SetText(title)
		local group = Profile.GetGroup(ns.profile, icon.group)
		row.sub:SetText(string.format("%s %s · %s #%d · %s", UNIT_LABELS[icon.unit], FILTER_LABELS[icon.filter]:lower(),
			group and group.name or "?", icon.slot, StatusTag(icon)))
		row.selected:SetShown(icon == Options.selectedIcon)
	end)
	self.iconList:SetPoint("TOPLEFT", 4, -48)

	local up = Button(page, L["Up"], 64, function()
		local index = SelectedIconIndex()
		if index and index > 1 then
			local icons = ns.profile.icons
			icons[index], icons[index - 1] = icons[index - 1], icons[index]
			ns:RefreshAll()
		end
	end)
	up:SetPoint("TOPLEFT", self.iconList, "BOTTOMLEFT", -2, -8)
	local down = Button(page, L["Down"], 64, function()
		local index = SelectedIconIndex()
		local icons = ns.profile.icons
		if index and index < #icons then
			icons[index], icons[index + 1] = icons[index + 1], icons[index]
			ns:RefreshAll()
		end
	end)
	down:SetPoint("LEFT", up, "RIGHT", 4, 0)
	local delete = Button(page, L["Delete"], 90, function()
		local index = SelectedIconIndex()
		if index then
			local rt = RT[ns.profile.icons[index]]
			Confirm(string.format(L["Delete icon \"%s\"?"], rt and rt.label or "?"), function()
				table.remove(ns.profile.icons, index)
				Options.selectedIcon = ns.profile.icons[index] or ns.profile.icons[index - 1]
				ns:RefreshAll()
			end)
		end
	end)
	delete:SetPoint("LEFT", down, "RIGHT", 4, 0)
	local orderHint = Text(page, L["Icons in one slot: the upper one wins."], 10, "GameFontNormalSmall")
	orderHint:SetPoint("TOPLEFT", up, "BOTTOMLEFT", 2, -6)
	orderHint:SetWidth(270)
	orderHint:SetTextColor(0.7, 0.7, 0.7)

	-- Editor.
	local editor = CreateFrame("Frame", nil, page)
	editor:SetPoint("TOPLEFT", 300, -4)
	editor:SetPoint("BOTTOMRIGHT", 0, 0)
	self.iconEditor = editor

	local function Edit(apply)
		local icon = Options.selectedIcon
		if icon then
			apply(icon)
			ns:RefreshAll()
		end
	end

	editor.preview = editor:CreateTexture(nil, "ARTWORK")
	editor.preview:SetSize(40, 40)
	editor.preview:SetPoint("TOPLEFT", 4, -4)
	local coords = Skin:GetTexCoord()
	editor.preview:SetTexCoord(coords[1], coords[2], coords[3], coords[4])

	editor.title = Header(editor, "")
	editor.title:SetPoint("TOPLEFT", editor.preview, "TOPRIGHT", 8, -2)
	editor.title:SetPoint("RIGHT", -4, 0)
	editor.title:SetWordWrap(false)
	editor.status = Text(editor, "", 11, "GameFontNormalSmall")
	editor.status:SetPoint("TOPLEFT", editor.title, "BOTTOMLEFT", 0, -4)
	editor.status:SetPoint("RIGHT", -4, 0)

	editor.spells = LabeledEditBox(editor, L["Spell IDs, comma separated (first found is shown)"], 300, function(text)
		local spells = ParseSpellList(text)
		if #spells > 0 then
			Edit(function(icon)
				icon.spells = spells
			end)
		else
			Options:Refresh()
		end
	end)
	editor.spells:SetPoint("TOPLEFT", 8, -78)

	editor.spellList = List(editor, 284, 5 * SPELL_ROW_HEIGHT, SPELL_ROW_HEIGHT, SetupSpellRow)
	editor.spellList:SetPoint("TOPLEFT", editor.spells, "BOTTOMLEFT", -4, -10)

	editor.unit = LabeledDropdown(editor, L["Whose auras"], 140, ListEntries(ns.UNITS, UNIT_LABELS), function(value)
		return Options.selectedIcon and Options.selectedIcon.unit == value
	end, function(value)
		Edit(function(icon)
			icon.unit = value
		end)
	end)
	editor.unit:SetPoint("TOPLEFT", 4, -238)

	editor.filter = LabeledDropdown(editor, L["Aura type"], 140, ListEntries(ns.FILTERS, FILTER_LABELS), function(value)
		return Options.selectedIcon and Options.selectedIcon.filter == value
	end, function(value)
		Edit(function(icon)
			icon.filter = value
		end)
	end)
	editor.filter:SetPoint("LEFT", editor.unit, "RIGHT", 12, 0)

	editor.group = LabeledDropdown(editor, L["Group"], 180, GroupEntries, function(value)
		return Options.selectedIcon and Options.selectedIcon.group == value
	end, function(value)
		Edit(function(icon)
			if icon.group ~= value then
				icon.group = value
				icon.slot = Profile.NextFreeSlot(ns.profile, value)
			end
		end)
	end)
	editor.group:SetPoint("TOPLEFT", 4, -292)

	editor.slot = LabeledEditBox(editor, L["Slot"], 60, function(text)
		local slot = tonumber(text)
		if slot then
			Edit(function(icon)
				icon.slot = ns.Clamp(math.floor(slot), 1, Profile.LIMITS.slots)
			end)
		else
			Options:Refresh()
		end
	end)
	editor.slot:SetPoint("LEFT", editor.group, "RIGHT", 18, 0)
	editor.slot:SetNumeric(true)

	editor.disabled = Check(editor, L["Disabled"], function(checked)
		Edit(function(icon)
			icon.disabled = checked
		end)
	end)
	editor.disabled:SetPoint("TOPLEFT", 0, -326)
	editor.cooldown = Check(editor, L["Show while the spell is on cooldown (ground effects)"], function(checked)
		Edit(function(icon)
			icon.track = checked and "cooldown" or "aura"
		end)
	end)
	editor.cooldown:SetPoint("TOPLEFT", editor.disabled, "BOTTOMLEFT", 0, -2)

	editor.help = Text(editor, L["ICONS_HELP"], 11, "GameFontNormalSmall")
	editor.help:SetPoint("TOPLEFT", editor.cooldown, "BOTTOMLEFT", 4, -14)
	editor.help:SetPoint("RIGHT", -6, 0)
	editor.help:SetTextColor(0.75, 0.75, 0.75)

	editor.empty = Text(page, L["Select an icon on the left or add a new one."], 12)
	editor.empty:SetPoint("TOPLEFT", editor, "TOPLEFT", 6, -10)
end

function Options:RefreshIcons()
	local icons = ns.profile.icons
	if self.selectedIcon and not SelectedIconIndex() then
		self.selectedIcon = nil
	end
	self.selectedIcon = self.selectedIcon or icons[1]
	self.iconList:SetItems(icons)

	local editor = self.iconEditor
	local icon = self.selectedIcon
	for _, region in ipairs({ editor:GetChildren() }) do
		region:SetShown(icon ~= nil)
	end
	for _, region in ipairs({ editor:GetRegions() }) do
		region:SetShown(icon ~= nil)
	end
	editor.empty:SetShown(icon == nil)
	if not icon then
		return
	end

	local rt = RT[icon] or ns.Tracker:Resolve(icon)
	editor.preview:SetTexture(rt.texture)
	editor.title:SetText(rt.label)
	editor.status:SetText(StatusText(icon))
	if not editor.spells:HasFocus() then
		editor.spells:SetText(table.concat(icon.spells, ", "))
	end

	-- One row per spell name with all of its IDs (ranks), so long rank lists stay readable, and
	-- whose auras count for it. Ranks share the setting (see Tracker:Resolve).
	local items, byName = {}, {}
	for _, entry in ipairs(rt.order) do
		local name = entry.name or "..."
		local item = byName[name]
		if not item then
			item = { name = name, ids = {}, any = false, cooldown = icon.track == "cooldown" }
			byName[name] = item
			items[#items + 1] = item
		end
		table.insert(item.ids, entry.id)
		item.any = item.any or entry.any
	end
	for _, item in ipairs(items) do
		item.text = item.name .. " " .. GREEN .. table.concat(item.ids, ", ") .. "|r"
	end
	for _, spellID in ipairs(rt.invalid) do
		items[#items + 1] = { text = RED .. spellID .. " " .. L["not found in this game version"] .. "|r" }
	end
	editor.spellList:SetItems(items)

	editor.unit:GenerateMenu()
	editor.filter:GenerateMenu()
	editor.group:GenerateMenu()
	if not editor.slot:HasFocus() then
		editor.slot:SetText(icon.slot)
	end
	editor.disabled:SetChecked(icon.disabled)
	editor.cooldown:SetChecked(icon.track == "cooldown")
	-- Unit, aura type and whose auras count do not apply to cooldown icons.
	editor.unit:SetEnabled(icon.track ~= "cooldown")
	editor.filter:SetEnabled(icon.track ~= "cooldown")
end

------------------------------------------------------------------------
-- Groups page
------------------------------------------------------------------------

local function SelectedGroup()
	local group = Options.selectedGroup and Profile.GetGroup(ns.profile, Options.selectedGroup)
	if not group then
		group = ns.profile.groups[1]
		Options.selectedGroup = group and group.key
	end
	return group
end

function Options:BuildGroupsPage(page)
	self.groupList = List(page, 200, 360, 30, function(row, group)
		SetupRow(row, 30)
		if not row.onClickSet then
			row.onClickSet = true
			row:SetScript("OnClick", function(self)
				Options.selectedGroup = self.group.key
				Options:RefreshGroups()
			end)
		end
		row.group = group
		local count, texture = 0, nil
		for _, icon in ipairs(ns.profile.icons) do
			if icon.group == group.key then
				count = count + 1
				texture = texture or (RT[icon] and RT[icon].texture)
			end
		end
		row.tex:SetTexture(texture or 134400)
		row.title:SetText((group.hidden and GREY or "") .. group.name)
		row.sub:SetText(string.format(L["%d icons"], count) .. (group.locked and (" · " .. L["pinned"]) or ""))
		row.selected:SetShown(group.key == Options.selectedGroup)
	end)
	self.groupList:SetPoint("TOPLEFT", 4, -4)

	local add = Button(page, L["New group"], 100, function()
		local group = Profile.AddGroup(ns.profile, L["New group"])
		if group then
			Options.selectedGroup = group.key
			ns:RefreshAll()
		end
	end)
	add:SetPoint("TOPLEFT", self.groupList, "BOTTOMLEFT", -2, -8)
	local delete = Button(page, L["Delete"], 100, function()
		local group = SelectedGroup()
		if group and #ns.profile.groups > 1 then
			Confirm(string.format(L["Delete group \"%s\"? Its icons move to the first group."], group.name), function()
				Profile.DeleteGroup(ns.profile, group.key)
				Options.selectedGroup = nil
				ns:RefreshAll()
			end)
		end
	end)
	delete:SetPoint("LEFT", add, "RIGHT", 4, 0)

	local editor = CreateFrame("Frame", nil, page)
	editor:SetPoint("TOPLEFT", 236, -4)
	editor:SetPoint("BOTTOMRIGHT", 0, 0)
	self.groupEditor = editor

	local function Edit(apply, fullRefresh)
		local group = SelectedGroup()
		if group then
			apply(group)
			if fullRefresh then
				ns:RefreshAll()
			else
				ns:RefreshLayout()
			end
		end
	end

	local function NumberBox(label, width, field, low, high, x, y)
		local box = LabeledEditBox(editor, label, width, function(text)
			local value = tonumber(text)
			if value then
				Edit(function(group)
					group[field] = ns.Round(ns.Clamp(value, low, high))
				end)
			else
				Options:Refresh()
			end
		end)
		box:SetPoint("TOPLEFT", x, y)
		box.field = field
		return box
	end

	editor.name = LabeledEditBox(editor, L["Name"], 200, function(text)
		text = strtrim(text):gsub("[%c|]", "")
		if text ~= "" then
			Edit(function(group)
				group.name = text:sub(1, 40)
			end, true)
		else
			Options:Refresh()
		end
	end)
	editor.name:SetPoint("TOPLEFT", 8, -20)

	editor.numbers = {
		NumberBox("X", 70, "x", -5000, 5000, 8, -66),
		NumberBox("Y", 70, "y", -5000, 5000, 96, -66),
		NumberBox(L["Icon size"], 70, "size", 12, 128, 8, -112),
		NumberBox(L["Spacing"], 70, "spacing", 0, 60, 96, -112),
		NumberBox(L["Icons per row"], 70, "perRow", 1, 40, 184, -112),
		NumberBox(L["Fade out, sec"], 70, "fadeTime", 0, 10, 184, -66),
	}

	editor.alpha = NumberBox(L["Opacity, %"], 70, "alpha", 10, 100, 272, -112)
	editor.alpha:SetScript("OnEditFocusLost", function(self)
		if self.revert then
			self.revert = nil
			Options:Refresh()
			return
		end
		local value = tonumber(self:GetText())
		if value then
			Edit(function(group)
				group.alpha = ns.Clamp(value, 10, 100) / 100
			end)
		else
			Options:Refresh()
		end
	end)

	editor.grow = LabeledDropdown(editor, L["Grow direction"], 140, ListEntries(ns.DIRECTIONS, DIRECTION_LABELS), function(value)
		local group = SelectedGroup()
		return group and group.grow == value
	end, function(value)
		Edit(function(group)
			group.grow = value
			if ns.IsHorizontal(group.wrap) == ns.IsHorizontal(value) then
				group.wrap = ns.IsHorizontal(value) and "DOWN" or "RIGHT"
			end
		end)
	end)
	editor.grow:SetPoint("TOPLEFT", 4, -162)

	editor.wrap = LabeledDropdown(editor, L["New row goes"], 140, function()
		local group = SelectedGroup()
		local list = (group and ns.IsHorizontal(group.grow)) and { "DOWN", "UP" } or { "RIGHT", "LEFT" }
		return ListEntries(list, DIRECTION_LABELS)()
	end, function(value)
		local group = SelectedGroup()
		return group and group.wrap == value
	end, function(value)
		Edit(function(group)
			group.wrap = value
		end)
	end)
	editor.wrap:SetPoint("LEFT", editor.grow, "RIGHT", 14, 0)

	editor.showInactive = Check(editor, L["Show inactive icons (dimmed)"], function(checked)
		Edit(function(group)
			group.showInactive = checked
		end)
		ns.Display:Render()
	end)
	editor.showInactive:SetPoint("TOPLEFT", 0, -196)
	editor.locked = Check(editor, L["Pin this group (cannot be dragged)"], function(checked)
		Edit(function(group)
			group.locked = checked
		end)
	end)
	editor.locked:SetPoint("TOPLEFT", editor.showInactive, "BOTTOMLEFT", 0, -2)
	editor.hidden = Check(editor, L["Hide group"], function(checked)
		Edit(function(group)
			group.hidden = checked
		end, true)
	end)
	editor.hidden:SetPoint("TOPLEFT", editor.locked, "BOTTOMLEFT", 0, -2)
	editor.flash = Check(editor, L["Flash when the timer runs out"], function(checked)
		Edit(function(group)
			group.flashOnExpire = checked
		end)
	end)
	editor.flash:SetPoint("TOPLEFT", editor.hidden, "BOTTOMLEFT", 0, -2)

	local reset = Button(editor, L["Reset position"], 140, function()
		Edit(function(group)
			Profile.ResetGroupPosition(group)
		end)
	end)
	reset:SetPoint("TOPLEFT", editor.flash, "BOTTOMLEFT", 4, -12)

	local help = Text(editor, L["GROUPS_HELP"], 11, "GameFontNormalSmall")
	help:SetPoint("TOPLEFT", reset, "BOTTOMLEFT", 0, -14)
	help:SetPoint("RIGHT", -6, 0)
	help:SetTextColor(0.75, 0.75, 0.75)
end

function Options:RefreshGroups()
	local group = SelectedGroup()
	self.groupList:SetItems(ns.profile.groups)
	local editor = self.groupEditor
	if not group then
		return
	end
	if not editor.name:HasFocus() then
		editor.name:SetText(group.name)
	end
	for _, box in ipairs(editor.numbers) do
		if not box:HasFocus() then
			box:SetText(group[box.field])
		end
	end
	if not editor.alpha:HasFocus() then
		editor.alpha:SetText(ns.Round(group.alpha * 100))
	end
	editor.grow:GenerateMenu()
	editor.wrap:GenerateMenu()
	editor.showInactive:SetChecked(group.showInactive)
	editor.locked:SetChecked(group.locked)
	editor.hidden:SetChecked(group.hidden)
	editor.flash:SetChecked(group.flashOnExpire)
end

------------------------------------------------------------------------
-- Export / import page
------------------------------------------------------------------------

function Options:BuildProfilePage(page)
	local header = Header(page, L["Export / Import"])
	header:SetPoint("TOPLEFT", 4, -4)
	local help = Text(page, L["PROFILE_HELP"], 11, "GameFontNormalSmall")
	help:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
	help:SetPoint("RIGHT", -4, 0)
	help:SetTextColor(0.8, 0.8, 0.8)

	local holder = CreateFrame("Frame", nil, page, "BackdropTemplate")
	holder:SetPoint("TOPLEFT", 4, -78)
	holder:SetPoint("RIGHT", -18, 0)
	holder:SetHeight(270)
	Skin:Panel(holder)

	local box = CreateFrame("Frame", nil, holder, "ScrollingEditBoxTemplate")
	box:SetPoint("TOPLEFT", 6, -6)
	box:SetPoint("BOTTOMRIGHT", -6, 6)
	local scrollBar = CreateFrame("EventFrame", nil, page, "MinimalScrollBar")
	scrollBar:SetPoint("TOPLEFT", holder, "TOPRIGHT", 4, 0)
	scrollBar:SetPoint("BOTTOMLEFT", holder, "BOTTOMRIGHT", 4, 0)
	ScrollUtil.RegisterScrollBoxWithScrollBar(box:GetScrollBox(), scrollBar)
	Skin:ScrollBar(scrollBar)
	self.profileBox = box
	box:GetEditBox():SetScript("OnMouseUp", function(editBox)
		editBox:HighlightText()
	end)

	self.profileStatus = Text(page, "", 12)
	self.profileStatus:SetPoint("TOPLEFT", holder, "BOTTOMLEFT", 0, -8)
	self.profileStatus:SetPoint("RIGHT", -4, 0)

	local exportAll = Button(page, L["Export everything"], 170, function()
		Options:ShowExport("all")
	end)
	exportAll:SetPoint("TOPLEFT", holder, "BOTTOMLEFT", 0, -34)
	local exportLayout = Button(page, L["Export layout only"], 170, function()
		Options:ShowExport("layout")
	end)
	exportLayout:SetPoint("LEFT", exportAll, "RIGHT", 6, 0)
	local clear = Button(page, L["Clear"], 100, function()
		box:SetText("")
		Options:SetProfileStatus("")
	end)
	clear:SetPoint("LEFT", exportLayout, "RIGHT", 6, 0)

	local importAll = Button(page, L["Import everything"], 170, function()
		Options:Import("all")
	end)
	importAll:SetPoint("TOPLEFT", exportAll, "BOTTOMLEFT", 0, -6)
	local importLayout = Button(page, L["Import layout only"], 170, function()
		Options:Import("layout")
	end)
	importLayout:SetPoint("LEFT", importAll, "RIGHT", 6, 0)

	local reset = Button(page, L["Reset to defaults"], 170, function()
		Options:ConfirmResetProfile()
	end)
	reset:SetPoint("TOPLEFT", importAll, "BOTTOMLEFT", 0, -18)
end

function Options:SetProfileStatus(text, isError)
	self.profileStatus:SetText((isError and RED or GREEN) .. (text or "") .. "|r")
end

function Options:ShowExport(scope)
	self:Create()
	local text = Profile.Export(ns.profile, scope or "all")
	self.profileBox:SetText(text)
	local editBox = self.profileBox:GetEditBox()
	editBox:SetFocus()
	editBox:HighlightText()
	self:SetProfileStatus(L["Copy the string with Ctrl+C."])
end

function Options:Import(mode)
	local ok, data = Profile.ParseImport(self.profileBox:GetInputText())
	if not ok then
		self:SetProfileStatus(L["Import failed:"] .. " " .. tostring(data), true)
		return
	end

	local notes = {}
	if data.scope == "layout" or mode == "layout" then
		notes[#notes + 1] = L["Only group positions and look will be replaced, your icons stay."]
	else
		notes[#notes + 1] = L["Groups and icons of this class will be replaced."]
	end
	if data.class and data.class ~= ns.playerClass then
		notes[#notes + 1] = string.format(L["The string was made for another class (%s)."], tostring(data.class))
	end
	if data.game and data.game ~= ns.gameKey then
		notes[#notes + 1] = L["The string was made for another game version, some spells may not exist."]
	end

	Confirm(L["Import sFilter settings?"] .. "\n\n" .. table.concat(notes, "\n"), function()
		local profile, err = Profile.ApplyImport(ns.profile, data, mode)
		if not profile then
			Options:SetProfileStatus(L["Import failed:"] .. " " .. tostring(err), true)
			return
		end
		Options.selectedIcon, Options.selectedGroup = nil, nil
		ns:SetProfile(profile)
		Options:SetProfileStatus(L["Settings imported."])
	end)
end

function Options:ConfirmResetProfile()
	Confirm(L["Reset groups and icons of this class to the defaults?"], function()
		Options.selectedIcon, Options.selectedGroup = nil, nil
		ns:ResetProfile()
		ns:Print(L["Profile reset to defaults."])
	end)
end

------------------------------------------------------------------------
-- Cooldown Manager page
------------------------------------------------------------------------

function Options:BuildCDMPage(page)
	local header = Header(page, L["Combat and the Cooldown Manager"])
	header:SetPoint("TOPLEFT", 4, -4)

	local help = Text(page, L["CDM_HELP"], 11, "GameFontNormalSmall")
	help:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
	help:SetPoint("RIGHT", -4, 0)
	help:SetTextColor(0.85, 0.85, 0.85)

	self.cdmStatus = Text(page, "", 12)
	self.cdmStatus:SetPoint("TOPLEFT", help, "BOTTOMLEFT", 0, -14)
	self.cdmStatus:SetPoint("RIGHT", -4, 0)
	self.cdmStatus:SetSpacing(4)

	local enable = Button(page, L["Enable Cooldown Manager"], 200, function()
		ns.CDM:Enable()
		C_Timer.After(0.6, function()
			Options:Refresh()
		end)
	end)
	enable:SetPoint("TOPLEFT", self.cdmStatus, "BOTTOMLEFT", 0, -12)
	self.cdmEnable = enable

	local open = Button(page, L["Open Cooldown Manager (/cdm)"], 220, function()
		ns.CDM:OpenSettings()
	end)
	open:SetPoint("LEFT", enable, "RIGHT", 6, 0)

	local import = Button(page, L["Add icons from Tracked Buffs"], 220, function()
		local added = ns.CDM:ImportTrackedBuffs(ns.profile)
		ns:Print(string.format(L["Added %d icons."], added))
		ns:RefreshAll()
	end)
	import:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -6)

	local refresh = Button(page, L["Refresh"], 120, function()
		ns.CDM:TryHook()
		ns.CDM:Rebuild()
		Options:Refresh()
	end)
	refresh:SetPoint("LEFT", import, "RIGHT", 6, 0)

	self.cdmMissing = Text(page, "", 11, "GameFontNormalSmall")
	self.cdmMissing:SetPoint("TOPLEFT", import, "BOTTOMLEFT", 0, -14)
	self.cdmMissing:SetPoint("RIGHT", -4, 0)
	self.cdmMissing:SetSpacing(2)
end

local function Line(ok, text, hint)
	local mark = ok and (GREEN .. "+ ") or (RED .. "- ")
	return mark .. text .. "|r" .. (hint and not ok and (GREY .. "  " .. hint .. "|r") or "")
end

function Options:RefreshCDM()
	local status = ns.CDM:GetStatus()
	local lines = {
		Line(status.available, L["Cooldown Manager is available"], status.reason),
		Line(status.enabled, L["Cooldown Manager is enabled"], L["press the button below"]),
		Line(status.viewerShown, L["\"Tracked Buffs\" bar is visible"], L["Edit Mode: Tracked Buffs, visibility \"Always\""]),
		Line(status.hideWhenInactive, L["\"Hide when inactive\" is on"], L["Edit Mode: Tracked Buffs, \"Hide when inactive\""]),
		Line(status.claimed > 0, string.format(L["Icons shown through the Cooldown Manager: %d"], status.claimed)),
	}
	self.cdmStatus:SetText(table.concat(lines, "\n"))
	self.cdmEnable:SetEnabled(not status.enabled)

	local canAdd, outOfCombat = {}, {}
	for _, icon in ipairs(ns.profile.icons) do
		if not icon.disabled and ns.Tracker:CombatStatus(icon) == "ooc" then
			local label = RT[icon] and RT[icon].label or "?"
			if ns.CDM:CanTrack(icon) then
				canAdd[#canAdd + 1] = label
			else
				outOfCombat[#outOfCombat + 1] = label
			end
		end
	end
	local text = {}
	if #canAdd > 0 then
		text[#text + 1] = YELLOW .. L["Add these to Tracked Buffs in /cdm to see them in combat:"] .. "|r\n" .. table.concat(canAdd, ", ")
	end
	if #outOfCombat > 0 then
		text[#text + 1] = GREY .. L["Not available in the Cooldown Manager, shown out of combat only:"] .. "|r\n" .. table.concat(outOfCombat, ", ")
	end
	self.cdmMissing:SetText(table.concat(text, "\n\n"))
end
