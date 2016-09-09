--[[
	sFilter
	Copyright (c) 2009, Nils Ruesch
	All rights reserved.
	Edited by ALZA, Danpiel.
]]

local s = sFilter_Settings

local MyUnits = {
    player = true,
    vehicle = true,
    pet = true,
}

local function sFilter_CreateFrame(data)
    local spellName, _, spellIcon = GetSpellInfo(data.spellId)
    local frame = CreateFrame("Frame", "sFilter_" .. data.unitId .. "_" .. data.spellId, UIParent)
    frame:SetWidth(data.size)
    frame:SetHeight(data.size)
    frame:SetPoint(unpack(data.setPoint))
    frame:RegisterEvent("UNIT_AURA")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(self, event, ...)
        local unit = ...
        if(data.unitId==unit or event=="PLAYER_TARGET_CHANGED" or event=="PLAYER_ENTERING_WORLD") then
            self.found = false
            self:SetAlpha(1)
            for i=1, 40 do
                local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitAura(data.unitId, i, data.filter)
                if((data.isMine~=1 or MyUnits[caster]) and (name==GetSpellInfo(data.spellId) or (data.spellId2 and name==GetSpellInfo(data.spellId2)) or (data.spellId3 and name==GetSpellInfo(data.spellId3)))) then
                    self.found = true
                    self.icon:SetTexture(icon)
                    self.count:SetText(count>1 and count or "")
					if (duration) then
                    if(duration>=0) then
                        self.cooldown:Show()
                        CooldownFrame_Set(self.cooldown, expirationTime-duration, duration, 1)
                    else
                        self.cooldown:Hide()
                    end
				else
				self.cooldown:Hide()
				end
                    break
                end
            end

            if(not self.found) then
                self:SetAlpha(0)
                self.icon:SetTexture(spellIcon)
                self.count:SetText("")
                self.cooldown:Hide()
            end
        end

        if(s.configmode==true) then
            self:SetAlpha(1)
            self.count:SetText(9)
        end
    end)

    if(s.configmode==true) then
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton", "RightButton")
        frame:SetScript("OnMouseDown", function(self,arg1)
            if(arg1=="LeftButton") then
                if(IsShiftKeyDown() or IsAltKeyDown()) then
                    self:StartMoving()
                end
            else
                self:ClearAllPoints()
                self:SetPoint(unpack(data.setPoint))
            end
        end)
        frame:SetScript("OnMouseUp", function(self,arg1)
            self:StopMovingOrSizing()
            if(arg1=="LeftButton") then
                local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(index)
                print(format("s|cFFFF8C00F|r|cFFFFFFFFfilter|r: setPoint for %s (%s): {\"%s\", UIParent, \"%s\", %s, %s}", data.spellId, spellName, point, relativePoint, floor(xOffset + 0.5), floor(yOffset + 0.5)))
            end
        end)
    end

    frame.icon = frame:CreateTexture("$parentIcon", "BACKGROUND")
    frame.icon:SetAllPoints(frame)
    frame.icon:SetTexture(spellIcon)
    frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    frame.count = frame:CreateFontString(nil, "OVERLAY")
    frame.count:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    frame.count:SetTextColor(0.8, 0.8, 0.8)
    frame.count:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.count:SetJustifyH("CENTER")

    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetReverse(true)
    frame.cooldown:SetAllPoints(frame.icon)

    local _, _, _, enabled = GetAddOnInfo("ElvUI")
    if enabled then
      local E = unpack(ElvUI);
      E:RegisterCooldown(frame.cooldown)
    end
    enabled = nil

    frame.overlay = frame:CreateTexture(nil, "OVERLAY")
    frame.overlay:SetTexture("Interface\\AddOns\\sFilter\\Textures\\gloss")
    frame.overlay:SetAllPoints(frame)
end

local class = select(2, UnitClass("player"))
if(sFilter_Spells and sFilter_Spells[class]) then
    for index in pairs(sFilter_Spells) do
        if(index~=class) then
            sFilter_Spells[index] = nil
        end
    end
    for i=1, #sFilter_Spells[class], 1 do
        sFilter_CreateFrame(sFilter_Spells[class][i])
    end
end
