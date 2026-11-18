-- Look and feel. With ElvUI loaded every widget goes through ElvUI's own skinning API (templates,
-- fonts, icon crop, cooldown text). Otherwise sFilter draws its settings in the style of
-- EllesmereUI: flat warm-dark panels with thin light borders, quiet white text and one accent
-- color. With EllesmereUI installed its accent color and font are used, so sFilter matches it.
-- ElvUI and EllesmereUI calls are wrapped in pcall so an API change there can never break sFilter.

local _, ns = ...

local Skin = {}
ns.Skin = Skin

-- The game font differs per locale (ruRU ships FRIZQT___CYR.TTF), so prefer the client's own.
local FALLBACK_FONT = "Fonts\\FRIZQT__.TTF"
local DEFAULT_TEXCOORD = { 0.07, 0.93, 0.07, 0.93 }
local FLAT = "Interface\\Buttons\\WHITE8X8"

-- EllesmereUI's look, from its STYLE constants: near-black warm panels, white borders and text at
-- low alpha. Colors are { r, g, b, a }.
local STYLE = {
	window = { 0.069, 0.058, 0.047, 0.96 },
	windowBorder = { 1, 1, 1, 0.08 },
	panel = { 0, 0, 0, 0.2 },
	panelBorder = { 1, 1, 1, 0.06 },
	band = { 0, 0, 0, 0.15 },
	divider = { 1, 1, 1, 0.06 },
	button = { 0.089, 0.080, 0.072, 0.6 },
	buttonHover = { 0.089, 0.080, 0.072, 0.75 },
	buttonBorder = { 1, 1, 1, 0.3 },
	buttonBorderHover = { 1, 1, 1, 0.45 },
	input = { 0.030, 0.023, 0.018, 0.5 },
	inputBorder = { 1, 1, 1, 0.12 },
	dropdown = { 0.103, 0.095, 0.088, 0.9 },
	dropdownHover = { 0.103, 0.095, 0.088, 0.98 },
	dropdownBorder = { 1, 1, 1, 0.2 },
	dropdownBorderHover = { 1, 1, 1, 0.3 },
	check = { 0.112, 0.105, 0.098, 1 },
	checkBorder = { 1, 1, 1, 0.12 },
	track = { 1, 1, 1, 0.1 },
	thumb = { 1, 1, 1, 0.25 },
	selected = { 1, 1, 1, 0.05 },
}

-- Text alpha per button state; the game swaps a button's font object on hover and when it is
-- disabled, so the colors live in font objects. A selected sidebar entry is a disabled button.
local TEXT_ALPHA = {
	button = { normal = 0.7, highlight = 0.95, disabled = 0.3 },
	nav = { normal = 0.6, highlight = 0.86, disabled = 1 },
}

-- EllesmereUI's default accent: teal, or soft bronze on the Forever client.
local ACCENT_TEAL = { 12 / 255, 210 / 255, 157 / 255 }
local ACCENT_BRONZE = { 220 / 255, 167 / 255, 127 / 255 }

-- EllesmereUI's own font (Expressway by default) has no Cyrillic or CJK letters; EllesmereUI uses
-- the game font for these client languages, and so does sFilter.
local GAME_FONT_LOCALES = { ruRU = true, koKR = true, zhCN = true, zhTW = true }

local TEXTURE_GETTERS = { "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }

local function Call(object, method, ...)
	local func = object and object[method]
	if type(func) == "function" then
		local ok = pcall(func, object, ...)
		return ok
	end
	return false
end

function Skin:Init()
	self.E, self.S = nil, nil
	local loaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("ElvUI")
	if loaded and type(_G.ElvUI) == "table" then
		local E = _G.ElvUI[1]
		if type(E) == "table" then
			self.E = E
			local ok, S = pcall(E.GetModule, E, "Skins")
			if ok then
				self.S = S
			end
		end
	end
	self.elvui = self.E ~= nil
	-- EllesmereUI only lends its accent color and font; with ElvUI loaded ElvUI's look wins.
	self.eui = type(_G.EllesmereUI) == "table" and _G.EllesmereUI or nil
	self.flat = not self.elvui
	self.fonts = {}
end

function Skin:GetFont()
	local E = self.E
	if E and E.media and E.media.normFont then
		return E.media.normFont
	end
	local eui = self.eui
	if eui and type(eui.GetFontPath) == "function" and not GAME_FONT_LOCALES[GetLocale()] then
		local ok, path = pcall(eui.GetFontPath)
		if ok and type(path) == "string" and path ~= "" then
			return path
		end
	end
	return STANDARD_TEXT_FONT or FALLBACK_FONT
end

-- SetFont returns false when the font file is missing; then try the client font and finally keep
-- the font object the FontString was created with, so SetText never runs on a font-less string.
function Skin:SetFont(fontString, size, outline)
	if fontString:SetFont(self:GetFont(), size, outline) then
		return
	end
	if STANDARD_TEXT_FONT and fontString:SetFont(STANDARD_TEXT_FONT, size, outline) then
		return
	end
	if not fontString:GetFont() then
		fontString:SetFontObject(GameFontHighlight)
	end
end

function Skin:GetTexCoord()
	local E = self.E
	if E and type(E.TexCoords) == "table" then
		return E.TexCoords
	end
	return DEFAULT_TEXCOORD
end

-- Accent color used for headers, selections and highlights.
function Skin:AccentColor()
	local E = self.E
	local color = E and E.media and E.media.rgbvaluecolor
	if type(color) == "table" and color.r then
		return color.r, color.g, color.b
	end
	local eui = self.eui
	if eui and type(eui.GetAccentColor) == "function" then
		local ok, r, g, b = pcall(eui.GetAccentColor)
		if ok and type(r) == "number" and type(g) == "number" and type(b) == "number" then
			return r, g, b
		end
	end
	local accent = ns.isForever and ACCENT_BRONZE or ACCENT_TEAL
	return accent[1], accent[2], accent[3]
end

------------------------------------------------------------------------
-- Aura icons
------------------------------------------------------------------------

-- parts has .icon, .cooldown, .count, .gloss and .border, optionally .slotText and .timeText.
-- frame is the frame that owns them (defaults to parts itself, as for Display's slots).
-- noCooldownText skips ElvUI's cooldown text, for Blizzard aura buttons that draw their own timer.
function Skin:StyleIcon(parts, frame, noCooldownText)
	frame = frame or parts
	local E = self.E
	local coords = self:GetTexCoord()
	parts.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])

	if E and Call(frame, "SetTemplate") then
		parts.border:Hide()
		parts.gloss:Hide()
		if parts.icon.SetInside then
			parts.icon:ClearAllPoints()
			Call(parts.icon, "SetInside", frame)
		end
		if E.RegisterCooldown and not noCooldownText then
			pcall(E.RegisterCooldown, E, parts.cooldown, "auras")
		end
		parts.elvui = true
	else
		parts.border:Show()
		parts.gloss:Show()
		parts.elvui = false
	end
end

local function IconFont(self, fontString, elvui, size)
	if fontString and not (elvui and Call(fontString, "FontTemplate", nil, size, "OUTLINE")) then
		self:SetFont(fontString, size, "OUTLINE")
	end
end

function Skin:UpdateIconFonts(parts, size)
	IconFont(self, parts.count, parts.elvui, math.max(9, math.floor(size * 0.38 + 0.5)))
	IconFont(self, parts.slotText, parts.elvui, math.max(8, math.floor(size * 0.3 + 0.5)))
	IconFont(self, parts.timeText, parts.elvui, math.max(9, math.floor(size * 0.42 + 0.5)))
end

------------------------------------------------------------------------
-- Building blocks of the flat style
------------------------------------------------------------------------

local function SetColor(texture, color)
	texture:SetColorTexture(color[1], color[2], color[3], color[4])
end

-- Background and 1px border through the backdrop API, which any frame can take on.
local function Backdrop(frame, color, borderColor)
	if not frame.SetBackdrop then
		Mixin(frame, BackdropTemplateMixin)
		if frame.OnBackdropSizeChanged then
			frame:HookScript("OnSizeChanged", frame.OnBackdropSizeChanged)
		end
	end
	frame:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 })
	frame:SetBackdropColor(color[1], color[2], color[3], color[4])
	frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
end

local function SetBackdropColors(frame, color, borderColor)
	frame:SetBackdropColor(color[1], color[2], color[3], color[4])
	frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
end

-- Hides a template's own art (it keeps setting atlases on these, so alpha, not Hide).
local function Strip(frame, keys)
	for _, key in ipairs(keys or { "Left", "Middle", "Right" }) do
		local region = frame[key]
		if type(region) == "table" and region.SetAlpha then
			region:SetAlpha(0)
		end
	end
	for _, getter in ipairs(TEXTURE_GETTERS) do
		if type(frame[getter]) == "function" then
			local texture = frame[getter](frame)
			if texture then
				texture:SetAlpha(0)
			end
		end
	end
end

local function FadeRegions(frame)
	for _, region in ipairs({ frame:GetRegions() }) do
		if region.SetAlpha then
			region:SetAlpha(0)
		end
	end
end

local function Enabled(frame)
	return not frame.IsEnabled or frame:IsEnabled()
end

-- Font objects per size and state set ("button" or "nav").
function Skin:ButtonFonts(size, kind)
	local key = kind .. size
	local fonts = self.fonts[key]
	if fonts then
		return fonts
	end
	fonts = {}
	for state, alpha in pairs(TEXT_ALPHA[kind]) do
		local font = CreateFont("sFilterFont_" .. key .. "_" .. state)
		if not font:SetFont(self:GetFont(), size, "") then
			font:SetFont(STANDARD_TEXT_FONT or FALLBACK_FONT, size, "")
		end
		font:SetTextColor(1, 1, 1, alpha)
		fonts[state] = font
	end
	self.fonts[key] = fonts
	return fonts
end

local function SetButtonFonts(button, fonts)
	Call(button, "SetNormalFontObject", fonts.normal)
	Call(button, "SetHighlightFontObject", fonts.highlight)
	Call(button, "SetDisabledFontObject", fonts.disabled)
end

------------------------------------------------------------------------
-- Frames and widgets
------------------------------------------------------------------------

local function FlatBackdrop(frame, alpha, borderAlpha)
	Backdrop(frame, { 0.06, 0.06, 0.06, alpha or 0.92 }, { 0.25, 0.25, 0.25, borderAlpha or 1 })
end
Skin.FlatBackdrop = FlatBackdrop

-- Main settings window and popups.
function Skin:Window(frame)
	if self.E and Call(frame, "SetTemplate", "Transparent") then
		return
	end
	Backdrop(frame, STYLE.window, STYLE.windowBorder)
end

-- Header band and sidebar of the settings window, as in EllesmereUI's panel.
function Skin:WindowChrome(frame, headerHeight, sidebarWidth)
	if not self.flat then
		return
	end
	local band = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	band:SetPoint("TOPLEFT", 1, -1)
	band:SetPoint("TOPRIGHT", -1, -1)
	band:SetHeight(headerHeight - 1)
	SetColor(band, STYLE.band)
	local line = frame:CreateTexture(nil, "BORDER")
	line:SetPoint("TOPLEFT", 1, -headerHeight)
	line:SetPoint("TOPRIGHT", -1, -headerHeight)
	line:SetHeight(1)
	SetColor(line, STYLE.divider)

	local sidebar = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	sidebar:SetPoint("TOPLEFT", 1, -headerHeight - 1)
	sidebar:SetPoint("BOTTOMLEFT", 1, 1)
	sidebar:SetWidth(sidebarWidth - 1)
	SetColor(sidebar, STYLE.band)
	local edge = frame:CreateTexture(nil, "BORDER")
	edge:SetPoint("TOPLEFT", sidebarWidth, -headerHeight - 1)
	edge:SetPoint("BOTTOMLEFT", sidebarWidth, 1)
	edge:SetWidth(1)
	SetColor(edge, STYLE.divider)
end

-- Inner panels (lists, editors).
function Skin:Panel(frame)
	if self.E and Call(frame, "SetTemplate", "Transparent") then
		return
	end
	Backdrop(frame, STYLE.panel, STYLE.panelBorder)
end

-- Movers shown while groups are unlocked.
function Skin:Mover(frame)
	if not (self.E and Call(frame, "SetTemplate", "Transparent")) then
		FlatBackdrop(frame, 0.55)
	end
end

function Skin:SetMoverHighlight(frame, highlighted)
	local r, g, b = 0.25, 0.25, 0.25
	if highlighted then
		r, g, b = self:AccentColor()
	end
	if frame.SetBackdropBorderColor then
		frame:SetBackdropBorderColor(r, g, b, 1)
	end
end

function Skin:Button(button)
	if self.S then
		pcall(self.S.HandleButton, self.S, button)
		return
	end
	if not self.flat then
		return
	end
	Strip(button)
	Backdrop(button, STYLE.button, STYLE.buttonBorder)
	SetButtonFonts(button, self:ButtonFonts(12, "button"))
	button:HookScript("OnEnter", function(self)
		if Enabled(self) then
			SetBackdropColors(self, STYLE.buttonHover, STYLE.buttonBorderHover)
		end
	end)
	button:HookScript("OnLeave", function(self)
		SetBackdropColors(self, STYLE.button, STYLE.buttonBorder)
	end)
	button.sfFlat = true
end

-- Sidebar entry of the settings window: text only, an accent mark on the selected page.
function Skin:NavButton(button)
	if not self.flat then
		self:Button(button)
		return
	end
	Strip(button)
	SetButtonFonts(button, self:ButtonFonts(13, "nav"))
	local text = button.GetFontString and button:GetFontString()
	if text then
		text:ClearAllPoints()
		text:SetPoint("LEFT", 14, 0)
		text:SetJustifyH("LEFT")
	end
	button.navSelected = button:CreateTexture(nil, "BACKGROUND")
	button.navSelected:SetAllPoints()
	SetColor(button.navSelected, STYLE.selected)
	button.navMark = button:CreateTexture(nil, "ARTWORK")
	button.navMark:SetPoint("TOPLEFT", 0, -4)
	button.navMark:SetPoint("BOTTOMLEFT", 0, 4)
	button.navMark:SetWidth(2)
	button.navMark:SetColorTexture(self:AccentColor())
	self:SetNavSelected(button, false)
	button.sfFlat = true
end

function Skin:SetNavSelected(button, selected)
	if button.navMark then
		button.navMark:SetShown(selected)
		button.navSelected:SetShown(selected)
	end
end

-- A thin cross drawn with lines, like EllesmereUI's close icon.
function Skin:CloseButton(button)
	if self.S then
		pcall(self.S.HandleCloseButton, self.S, button)
		return
	end
	if not (self.flat and button.CreateLine) then
		return
	end
	Strip(button)
	local lines = {}
	for i, corners in ipairs({ { "TOPLEFT", "BOTTOMRIGHT", 9, -9, -9, 9 }, { "TOPRIGHT", "BOTTOMLEFT", -9, -9, 9, 9 } }) do
		local line = button:CreateLine(nil, "ARTWORK")
		line:SetThickness(1.5)
		line:SetColorTexture(1, 1, 1, 0.55)
		line:SetStartPoint(corners[1], button, corners[3], corners[4])
		line:SetEndPoint(corners[2], button, corners[5], corners[6])
		lines[i] = line
	end
	button:HookScript("OnEnter", function()
		for _, line in ipairs(lines) do
			line:SetColorTexture(1, 1, 1, 0.95)
		end
	end)
	button:HookScript("OnLeave", function()
		for _, line in ipairs(lines) do
			line:SetColorTexture(1, 1, 1, 0.55)
		end
	end)
	button.sfFlat = true
end

function Skin:EditBox(editBox)
	if self.S then
		pcall(self.S.HandleEditBox, self.S, editBox)
		return
	end
	if not self.flat then
		return
	end
	Strip(editBox)
	Backdrop(editBox, STYLE.input, STYLE.inputBorder)
	Call(editBox, "SetTextInsets", 6, 6, 0, 0)
	if editBox.SetFont and editBox:SetFont(self:GetFont(), 12, "") then
		editBox:SetTextColor(1, 1, 1, 0.9)
	end
	editBox.sfFlat = true
end

-- A square box with an accent square inside when checked, like EllesmereUI's checkbox.
function Skin:CheckBox(check)
	if self.S then
		pcall(self.S.HandleCheckBox, self.S, check)
		return
	end
	if not self.flat then
		return
	end
	Strip(check)
	local box = check:CreateTexture(nil, "BACKGROUND", nil, 2)
	box:SetSize(16, 16)
	box:SetPoint("CENTER")
	SetColor(box, STYLE.check)
	local edge = check:CreateTexture(nil, "BACKGROUND", nil, 1)
	edge:SetPoint("TOPLEFT", box, "TOPLEFT", -1, 1)
	edge:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", 1, -1)
	SetColor(edge, STYLE.checkBorder)
	local r, g, b = self:AccentColor()
	for setter, color in pairs({ SetCheckedTexture = { r, g, b, 1 }, SetDisabledCheckedTexture = { 1, 1, 1, 0.3 } }) do
		if Call(check, setter, FLAT) then
			local getter = setter:gsub("^Set", "Get")
			local mark = check[getter] and check[getter](check)
			if mark then
				mark:ClearAllPoints()
				mark:SetPoint("TOPLEFT", box, "TOPLEFT", 3, -3)
				mark:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -3, 3)
				mark:SetVertexColor(color[1], color[2], color[3], color[4])
			end
		end
	end
	if check.Text then
		check.Text:SetTextColor(1, 1, 1, 0.85)
	end
	check.sfFlat = true
end

function Skin:Dropdown(dropdown, width)
	if self.S then
		pcall(self.S.HandleDropDownBox, self.S, dropdown, width)
		return
	end
	if not self.flat then
		return
	end
	if dropdown.Background then
		dropdown.Background:SetAlpha(0)
	end
	Backdrop(dropdown, STYLE.dropdown, STYLE.dropdownBorder)
	if dropdown.Arrow then
		dropdown.Arrow:SetDesaturated(true)
		dropdown.Arrow:SetVertexColor(1, 1, 1, 0.6)
	end
	if dropdown.Text then
		self:SetFont(dropdown.Text, 12, "")
		dropdown.Text:SetTextColor(1, 1, 1, 0.8)
	end
	dropdown:HookScript("OnEnter", function(self)
		SetBackdropColors(self, STYLE.dropdownHover, STYLE.dropdownBorderHover)
	end)
	dropdown:HookScript("OnLeave", function(self)
		SetBackdropColors(self, STYLE.dropdown, STYLE.dropdownBorder)
	end)
	dropdown.sfFlat = true
end

-- A thin track with a light thumb; the template's arrows stay, toned down.
function Skin:ScrollBar(scrollBar)
	if self.S then
		pcall(self.S.HandleTrimScrollBar, self.S, scrollBar)
		return
	end
	if not self.flat then
		return
	end
	local track = scrollBar.Track
	if track then
		FadeRegions(track)
		local line = track:CreateTexture(nil, "BACKGROUND")
		line:SetPoint("TOP")
		line:SetPoint("BOTTOM")
		line:SetWidth(4)
		SetColor(line, STYLE.track)
		local thumb = track.Thumb
		if thumb then
			FadeRegions(thumb)
			local fill = thumb:CreateTexture(nil, "ARTWORK")
			fill:SetPoint("TOP")
			fill:SetPoint("BOTTOM")
			fill:SetWidth(4)
			SetColor(fill, STYLE.thumb)
		end
	end
	for _, key in ipairs({ "Back", "Forward" }) do
		local stepper = scrollBar[key]
		if type(stepper) == "table" and stepper.GetRegions then
			for _, region in ipairs({ stepper:GetRegions() }) do
				if region.SetDesaturated then
					region:SetDesaturated(true)
					region:SetVertexColor(1, 1, 1, 0.5)
				end
			end
		end
	end
	scrollBar.sfFlat = true
end

function Skin:Slider(slider)
	if self.S then
		pcall(self.S.HandleSliderFrame, self.S, slider)
	end
end

function Skin:FontString(fontString, size, outline)
	if not (self.E and Call(fontString, "FontTemplate", nil, size, outline)) then
		self:SetFont(fontString, size or 12, outline or "")
	end
end
