-- Look and feel. With ElvUI loaded every widget goes through ElvUI's own skinning API (templates,
-- fonts, icon crop, cooldown text), otherwise a flat dark style close to the original sFilter is used.
-- ElvUI calls are wrapped in pcall so an ElvUI API change can never break sFilter.

local _, ns = ...

local Skin = {}
ns.Skin = Skin

-- The game font differs per locale (ruRU ships FRIZQT___CYR.TTF), so prefer the client's own.
local FALLBACK_FONT = "Fonts\\FRIZQT__.TTF"
local DEFAULT_TEXCOORD = { 0.07, 0.93, 0.07, 0.93 }
local FLAT = "Interface\\Buttons\\WHITE8X8"

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
end

function Skin:GetFont()
	local E = self.E
	if E and E.media and E.media.normFont then
		return E.media.normFont
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
-- Frames and widgets
------------------------------------------------------------------------

local function FlatBackdrop(frame, alpha, borderAlpha)
	if not frame.SetBackdrop then
		Mixin(frame, BackdropTemplateMixin)
	end
	frame:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1 })
	frame:SetBackdropColor(0.06, 0.06, 0.06, alpha or 0.92)
	frame:SetBackdropBorderColor(0.25, 0.25, 0.25, borderAlpha or 1)
end
Skin.FlatBackdrop = FlatBackdrop

-- Main settings window and popups.
function Skin:Window(frame)
	if not (self.E and Call(frame, "SetTemplate", "Transparent")) then
		FlatBackdrop(frame, 0.94)
	end
end

-- Inner panels (lists, editors).
function Skin:Panel(frame)
	if not (self.E and Call(frame, "SetTemplate", "Transparent")) then
		FlatBackdrop(frame, 0.5, 0.8)
	end
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
		local E = self.E
		local color = E and E.media and E.media.rgbvaluecolor
		if type(color) == "table" and color.r then
			r, g, b = color.r, color.g, color.b
		else
			r, g, b = 1, 0.55, 0
		end
	end
	if frame.SetBackdropBorderColor then
		frame:SetBackdropBorderColor(r, g, b, 1)
	end
end

function Skin:Button(button)
	if self.S then
		pcall(self.S.HandleButton, self.S, button)
	end
end

function Skin:CloseButton(button)
	if self.S then
		pcall(self.S.HandleCloseButton, self.S, button)
	end
end

function Skin:EditBox(editBox)
	if self.S then
		pcall(self.S.HandleEditBox, self.S, editBox)
	end
end

function Skin:CheckBox(checkBox)
	if self.S then
		pcall(self.S.HandleCheckBox, self.S, checkBox)
	end
end

function Skin:Dropdown(dropdown, width)
	if self.S then
		pcall(self.S.HandleDropDownBox, self.S, dropdown, width)
	end
end

function Skin:ScrollBar(scrollBar)
	if self.S then
		pcall(self.S.HandleTrimScrollBar, self.S, scrollBar)
	end
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

-- Accent color used for headers and highlights.
function Skin:AccentColor()
	local E = self.E
	local color = E and E.media and E.media.rgbvaluecolor
	if type(color) == "table" and color.r then
		return color.r, color.g, color.b
	end
	return 1, 0.55, 0
end
