-- Minimal World of Warcraft API mock for running sFilter under plain Lua 5.1.
local M = {}
M.events = {}
M.calls = {}

local function log(name, ...)
	M.calls[#M.calls + 1] = { name = name, args = { ... } }
end
M.log = log

------------------------------------------------------------------------
-- Widgets
------------------------------------------------------------------------

local Widget = {}
local WidgetMeta = {
	__index = function(t, k)
		local f = Widget[k]
		if f then
			return f
		end
		return nil
	end,
}

local function newWidget(kind, name, parent, template)
	local w = setmetatable({
		__kind = kind, __name = name, __parent = parent, __template = template,
		__shown = kind ~= "Frame" or true, __points = {}, __scripts = {}, __children = {}, __regions = {},
		__text = "", __width = 0, __height = 0, __level = 1, __alpha = 1, __scale = 1, __events = {},
	}, WidgetMeta)
	if parent then
		if kind == "Texture" or kind == "FontString" then
			table.insert(parent.__regions, w)
		else
			table.insert(parent.__children, w)
			w.__level = (parent.__level or 1) + 1
		end
	end
	return w
end
M.newWidget = newWidget

local function noop() end
for _, name in ipairs({
	"SetFrameStrata", "SetClampedToScreen", "SetMovable", "EnableMouse", "RegisterForDrag", "SetTexCoord",
	"SetDesaturated", "SetColorTexture", "SetAtlas", "SetJustifyH", "SetTextColor", "SetWordWrap",
	"SetReverse", "SetDrawEdge", "SetHideCountdownNumbers", "SetAutoFocus", "SetNumeric", "HighlightText",
	"SetFocus", "ClearFocus", "SetSpacing", "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor",
	"SetEnabled", "AddLine", "SetOwner", "SetTextInsets", "SetVertexColor", "StartMoving",
	"StopMovingOrSizing", "SetElementExtent", "SetDrawBling", "SetBlendMode",
}) do
	Widget[name] = noop
end

function Widget:CreateAnimationGroup()
	local group = { __animations = {}, __scripts = {} }
	function group:CreateAnimation(kind)
		local animation = { kind = kind }
		for _, method in ipairs({ "SetFromAlpha", "SetToAlpha", "SetDuration", "SetScaleFrom", "SetScaleTo" }) do
			animation[method] = function(self, ...) self[method] = { ... } end
		end
		table.insert(self.__animations, animation)
		return animation
	end
	function group:SetScript(name, fn) self.__scripts[name] = fn end
	function group:Play() self.__playing = true; self.__plays = (self.__plays or 0) + 1 end
	function group:Stop() self.__playing = false end
	return group
end

function Widget:SetPoint(...) table.insert(self.__points, { ... }) end
function Widget:ClearAllPoints() self.__points = {} end
function Widget:GetPoint(i) return unpack(self.__points[i or 1] or {}) end
function Widget:SetAllPoints(rel) self.__points = { { "ALL", rel } } end
function Widget:SetSize(w, h) self.__width, self.__height = w, h end
function Widget:SetWidth(w) self.__width = w end
function Widget:SetHeight(h) self.__height = h end
function Widget:GetWidth() return self.__width end
function Widget:GetHeight() return self.__height end
function Widget:GetSize() return self.__width, self.__height end
function Widget:Show() self.__shown = true end
function Widget:Hide() self.__shown = false end
function Widget:SetShown(s) self.__shown = s and true or false end
function Widget:IsShown() return self.__shown end
function Widget:SetAlpha(a) self.__alpha = a end
function Widget:GetAlpha() return self.__alpha end
function Widget:SetScale(s) self.__scale = s end
function Widget:GetScale() return self.__scale end
function Widget:GetEffectiveScale() return 1 end
function Widget:SetScript(n, f) self.__scripts[n] = f end
function Widget:GetScript(n) return self.__scripts[n] end
function Widget:HookScript(n, f) local o = self.__scripts[n]; self.__scripts[n] = function(...) if o then o(...) end f(...) end end
function Widget:CreateTexture() return newWidget("Texture", nil, self) end
-- Fonts behave like the game: SetFont fails for a missing file, SetText needs a font.
M.fonts = { ["Fonts\\FRIZQT___CYR.TTF"] = true, ["ElvFont"] = true }
function Widget:CreateFontString(_, _, template)
	local w = newWidget("FontString", nil, self)
	w.__font = template
	return w
end
function Widget:SetFont(path)
	if M.fonts[path] then
		self.__font = path
		return true
	end
	return false
end
function Widget:GetFont() return self.__font end
function Widget:SetFontObject(object) self.__font = object end
function Widget:SetText(t)
	if self.__kind == "FontString" and not self.__font then
		error("FontString:SetText(): Font not set")
	end
	self.__text = t
end
function Widget:GetText() return self.__text end
function Widget:SetTexture(t) self.__texture = t end
function Widget:GetTexture() return self.__texture end
function Widget:GetFrameLevel() return self.__level end
function Widget:SetFrameLevel(l) self.__level = l end
function Widget:GetParent() return self.__parent end
function Widget:GetName() return self.__name end
function Widget:GetChildren() return unpack(self.__children) end
function Widget:GetRegions() return unpack(self.__regions) end
function Widget:GetLeft() return self.__left or 100 end
function Widget:GetRight() return self.__right or 200 end
function Widget:GetTop() return self.__top or 300 end
function Widget:GetBottom() return self.__bottom or 250 end
function Widget:GetCenter() return 960, 540 end
function Widget:HasFocus() return self.__focus or false end
function Widget:SetChecked(c) self.__checked = c and true or false end
function Widget:GetChecked() return self.__checked end
function Widget:SetCooldown(start, duration) self.__cd = { start, duration } end
function Widget:Clear() self.__cd = nil end
function Widget:RegisterEvent(e)
	if e == "PVP_MATCH_UNKNOWN" then error("unknown event") end
	self.__events[e] = true
	M.events[e] = M.events[e] or {}
	M.events[e][self] = true
end
function Widget:RegisterUnitEvent(e, ...)
	self:RegisterEvent(e)
	self.__unitFilter = self.__unitFilter or {}
	self.__unitFilter[e] = { ... }
end
function Widget:UnregisterEvent(e)
	self.__events[e] = nil
	if M.events[e] then M.events[e][self] = nil end
end
-- Menu dropdowns
function Widget:SetupMenu(gen) self.__menu = gen end
function Widget:GenerateMenu()
	if self.__menu then self.__menu(self, M.FakeMenuRoot()) end
end
-- Scrolling edit box
function Widget:GetEditBox() self.__editBox = self.__editBox or newWidget("EditBox", nil, self); return self.__editBox end
function Widget:GetScrollBox() return self end
function Widget:GetInputText() return self.__text end
-- ScrollBox list
function Widget:SetDataProvider(dp)
	self.__rows = {}
	for _, item in ipairs(dp.items) do
		local row = newWidget("Button", nil, self)
		self.__view.initializer(row, item)
		table.insert(self.__rows, row)
	end
end

function M.FakeMenuRoot()
	local root = {}
	root.items = {}
	function root:CreateTitle(t) table.insert(self.items, { "title", t }) end
	function root:CreateDivider() end
	function root:CreateButton(t, f) table.insert(self.items, { "button", t, f }) end
	function root:CreateCheckbox(t, isSel, f) isSel(); table.insert(self.items, { "check", t, f }) end
	function root:CreateRadio(t, isSel, f, v) isSel(v); table.insert(self.items, { "radio", t, f, v }) end
	return root
end

function M.FireEvent(event, ...)
	for frame in pairs(M.events[event] or {}) do
		local filter = frame.__unitFilter and frame.__unitFilter[event]
		local unit = ...
		local pass = true
		if filter then
			pass = false
			for _, u in ipairs(filter) do
				if u == unit then pass = true end
			end
		end
		if pass and frame.__scripts.OnEvent then
			frame.__scripts.OnEvent(frame, event, ...)
		end
	end
end

------------------------------------------------------------------------
-- Blizzard CustomAuraContainer (trusted code that matches auras by spell ID)
------------------------------------------------------------------------

local function IsDescendant(object, owner)
	local parent = object.__parent
	while parent do
		if parent == owner then return true end
		parent = parent.__parent
	end
	return false
end

-- Aura buttons may only be touched by addons while auras are not secret.
local RESTRICTED = { "SetPoint", "ClearAllPoints", "SetSize", "SetAlpha", "SetScale", "EnableMouse" }

local function MakeAuraButton(container)
	local button = newWidget("AuraButton", nil, container)
	for _, method in ipairs(RESTRICTED) do
		local original = Widget[method]
		button[method] = function(self, ...)
			if M.secret then error("Aura button is restricted while auras are secret") end
			return original(self, ...)
		end
	end
	local function Bind(field)
		return function(self, region)
			if not IsDescendant(region, self) then error("bad object (must be a descendant of owner)") end
			self[field] = region
		end
	end
	button.SetIcon = Bind("__iconRegion")
	button.SetDurationCooldown = Bind("__cooldownRegion")
	button.SetApplicationCount = Bind("__countRegion")
	button.SetDurationText = Bind("__timeRegion")
	button.__shown = false
	return button
end

local function MakeAuraContainer(w)
	w.__slots = {}
	w.__order = {}
	w.SetUnit = function(self, unit) self.__unit = unit end
	w.SetEnabled = function(self, enabled) self.__enabled = enabled end
	w.AddAuraSlot = function(self, key, filterString, options)
		if self.__slots[key] then error("aura slot already exists") end
		local button = MakeAuraButton(self)
		if options and options.initializeFrame then options.initializeFrame(button) end
		self.__slots[key] = { filter = filterString, filters = options and options.candidateFilters, enabled = true, button = button }
		table.insert(self.__order, key)
		self:UpdateAllAuras()
		return button
	end
	w.GetAuraSlotFrame = function(self, key) return self.__slots[key] and self.__slots[key].button end
	w.SetAuraSlotFilterString = function(self, key, f) self.__slots[key].filter = f; self:UpdateAllAuras() end
	w.SetAuraSlotCandidateFilters = function(self, key, f) self.__slots[key].filters = f; self:UpdateAllAuras() end
	w.SetAuraSlotEnabled = function(self, key, e) self.__slots[key].enabled = e; self:UpdateAllAuras() end
	w.UpdateAllAuras = function(self)
		M.containerUpdates = (M.containerUpdates or 0) + 1
		for _, slot in pairs(self.__slots) do
			local found
			if slot.enabled and self.__enabled and self:IsShown() then
				for _, aura in ipairs(M.auras[self.__unit] or {}) do
					local typeOk = (slot.filter:find("HELPFUL") and aura.isHelpful) or (slot.filter:find("HARMFUL") and not aura.isHelpful)
					local idOk = slot.filters and slot.filters.includeSpellIDs and slot.filters.includeSpellIDs[aura.spellId]
					local mineOk = not (slot.filters and slot.filters.isFromPlayerOrPlayerPet) or aura.isFromPlayerOrPlayerPet
					if typeOk and idOk and mineOk then found = aura break end
				end
			end
			slot.button.__aura = found
			slot.button.__shown = found ~= nil
		end
	end
end

M.allFrames = {}
function M.Install(env)
	env = env or _G
	env.UIParent = newWidget("Frame", "UIParent")
	env.UIParent.__width, env.UIParent.__height = 1920, 1080
	env.GameTooltip = newWidget("GameTooltip", "GameTooltip")

	env.CreateFrame = function(kind, name, parent, template)
		if kind == "AuraContainer" and not M.auraContainer then
			error("Unknown frame type 'AuraContainer'")
		end
		local w = newWidget(kind, name, parent, template)
		if kind == "AuraContainer" then
			MakeAuraContainer(w)
			M.containers = M.containers or {}
			table.insert(M.containers, w)
		end
		if template and template:find("UICheckButtonTemplate") then
			w.Text = newWidget("FontString", nil, w)
			w.Text.__font = "GameFontNormalSmall"
		end
		if name then env[name] = w end
		table.insert(M.allFrames, w)
		return w
	end

	env.GetBuildInfo = function() return "1.60.1", "70205", "Oct 3 2026", M.toc or 16001 end
	env.WOW_PROJECT_CAMELOT = 99
	env.WOW_PROJECT_ID = M.toc == 120100 and 1 or 99
	env.GetLocale = function() return M.locale or "ruRU" end
	env.STANDARD_TEXT_FONT = "Fonts\\FRIZQT___CYR.TTF"
	env.GameFontHighlight = "GameFontHighlight"
	env.strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
	env.wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
	env.tinsert = table.insert
	env.tContains = function(t, v) for _, x in ipairs(t) do if x == v then return true end end return false end
	env.UISpecialFrames = {}
	env.YES, env.NO = "Yes", "No"
	env.SlashCmdList = {}
	env.LOCALIZED_CLASS_NAMES_MALE = { WARLOCK = "Чернокнижник" }
	env.InCombatLockdown = function() return M.inCombat or false end
	env.GetTime = function() return M.now or 100 end
	env.IsPlayerSpell = function(id) return M.known and M.known[id] or false end
	env.C_CurveUtil = {
		CreateCurve = function()
			local curve = { points = {} }
			function curve:SetType(t) self.type = t end
			function curve:AddPoint(x, y) table.insert(self.points, { x, y }) end
			function curve:Evaluate(x)
				local p = self.points
				if x <= p[1][1] then return p[1][2] end
				for i = 2, #p do
					if x <= p[i][1] then
						if self.type == 1 then return p[i - 1][2] end
						local a, b = p[i - 1], p[i]
						return a[2] + (b[2] - a[2]) * (x - a[1]) / (b[1] - a[1])
					end
				end
				return p[#p][2]
			end
			return curve
		end,
	}
	env.C_StringUtil = {
		CreateNumericRuleFormatter = function()
			return { SetBreakpoints = function(self, b) self.breakpoints = b end }
		end,
	}
	M.callbacks = {}
	env.EventRegistry = {
		RegisterCallback = function(_, event, fn) M.callbacks[event] = M.callbacks[event] or {}; table.insert(M.callbacks[event], fn) end,
		TriggerEvent = function(_, event, ...) for _, fn in ipairs(M.callbacks[event] or {}) do fn(...) end end,
	}
	env.Mixin = function(o, ...) for _, m in ipairs({ ... }) do for k, v in pairs(m) do o[k] = v end end return o end
	env.BackdropTemplateMixin = {}
	env.C_Timer = { After = function(_, f) f() end }
	env.hooksecurefunc = function(tbl, name, fn)
		if type(tbl) == "string" then tbl, name, fn = env, tbl, name end
		local orig = tbl[name]
		tbl[name] = function(...) local r = { orig(...) }; fn(...); return unpack(r) end
	end
	env.issecretvalue = function(v) return type(v) == "table" and v.__secret == true end
	env.StaticPopupDialogs = {}
	env.StaticPopup_Show = function(which, text, _, data) M.lastPopup = { which = which, text = text, data = data } end
	env.HideUIPanel = noop
	env.Settings = { RegisterCanvasLayoutCategory = function() return {} end, RegisterAddOnCategory = noop }
	env.MenuUtil = { CreateContextMenu = function(owner, gen) local root = M.FakeMenuRoot(); gen(owner, root); M.lastMenu = root end }
	env.CreateScrollBoxListLinearView = function()
		local view = {}
		function view:SetElementExtent() end
		function view:SetElementInitializer(_, fn) self.initializer = fn end
		return view
	end
	env.ScrollUtil = {
		InitScrollBoxListWithScrollBar = function(box, _, view) box.__view = view end,
		RegisterScrollBoxWithScrollBar = noop,
	}
	env.CreateDataProvider = function(items) return { items = items } end
	env.ScrollBoxConstants = { RetainScrollPosition = true }

	env.C_AddOns = {
		GetAddOnMetadata = function() return "10.0.0" end,
		IsAddOnLoaded = function(name) return name == "ElvUI" and env.ElvUI ~= nil end,
		LoadAddOn = noop,
	}

	-- Spells
	M.spells = {}
	env.C_Spell = {
		GetSpellName = function(id) local s = M.spells[id]; return s and s.name end,
		GetSpellTexture = function(id) local s = M.spells[id]; return s and (1000 + id) end,
		DoesSpellExist = function(id) return M.spells[id] ~= nil end,
		RequestLoadSpellData = noop,
		-- By name it returns the highest known rank, like the game.
		GetSpellInfo = function(x)
			local best
			for id, s in pairs(M.spells) do if s.name == x and (not best or id > best) then best = id end end
			return best and { spellID = best, name = x } or nil
		end,
		IsSpellHarmful = function(id) local s = M.spells[id]; return s and s.harmful or false end,
		-- M.cooldowns[spellID] = { start = , duration = , gcd = bool }; times turn secret with M.secret.
		GetSpellCooldown = function(id)
			local cd = M.cooldowns and M.cooldowns[id]
			if not cd then
				return { startTime = 0, duration = 0, isEnabled = true, isActive = false, modRate = 1 }
			end
			local active = (M.now or 100) < cd.start + cd.duration
			local secret = { __secret = true }
			return {
				startTime = M.secret and secret or cd.start,
				duration = M.secret and secret or cd.duration,
				isEnabled = true, isActive = active, isOnGCD = cd.gcd or false, modRate = 1,
			}
		end,
		GetSpellCooldownDuration = function(id)
			local cd = M.cooldowns and M.cooldowns[id]
			if not cd then return nil end
			local object = {}
			local function remaining() return math.max(0, cd.start + cd.duration - (M.now or 100)) end
			function object:EvaluateRemainingDuration(curve) return curve:Evaluate(remaining()) end
			function object:FormatRemainingDuration() return { __secret = true, text = tostring(math.floor(remaining())) } end
			return object
		end,
	}

	-- Auras
	M.auras = { player = {}, target = {}, pet = {}, focus = {} }
	M.secret = false
	M.whitelist = {}
	env.C_Secrets = {
		ShouldAurasBeSecret = function() return M.secret end,
		ShouldSpellAuraBeSecret = function(id) return not M.whitelist[id] end,
	}
	local function secretize(a)
		if not M.secret then return a end
		local s = {}
		for k, v in pairs(a) do s[k] = { __secret = true } end
		return s
	end
	env.C_UnitAuras = {
		GetUnitAuras = function(unit, filter)
			local out = {}
			for _, a in ipairs(M.auras[unit] or {}) do
				if (filter:find("HELPFUL") and a.isHelpful) or (filter:find("HARMFUL") and not a.isHelpful) then
					table.insert(out, secretize(a))
				end
			end
			return out
		end,
		GetAuraDataByIndex = function() return nil end,
		GetUnitAuraBySpellID = function(unit, id)
			if M.secret and not M.whitelist[id] then error("RequiresNonSecretAura") end
			for _, a in ipairs(M.auras[unit] or {}) do
				if a.spellId == id then return a end
			end
		end,
	}
	env.UnitExists = function(unit) return unit == "player" or unit == "target" or (unit == "pet" and M.hasPet) end
	env.UnitClass = function() return "Warlock", "WARLOCK" end

	-- CVars / Cooldown Manager
	M.cvars = { cooldownViewerEnabled = true }
	env.C_CVar = {
		GetCVarBool = function(n) return M.cvars[n] and true or false end,
		SetCVar = function(n, v) M.cvars[n] = v == "1" end,
	}
	M.cdmInfos = {}
	env.Enum = { CooldownViewerCategory = { Essential = 0, Utility = 1, TrackedBuff = 2, TrackedBar = 3 } }
	env.C_CooldownViewer = {
		IsCooldownViewerAvailable = function() return true, "" end,
		GetCooldownViewerCooldownInfo = function(id) return M.cdmInfos[id] end,
		GetCooldownViewerCategorySet = function(cat)
			local out = {}
			for id, info in pairs(M.cdmInfos) do if info.category == cat then table.insert(out, id) end end
			return out
		end,
	}
	return env
end

-- Blizzard BuffIconCooldownViewer with item frames for the given cooldown IDs.
function M.MakeViewer(env, cooldownIDs)
	local viewer = env.CreateFrame("Frame", "BuffIconCooldownViewer", env.UIParent)
	viewer.__items = {}
	for _, id in ipairs(cooldownIDs) do
		local item = newWidget("Frame", nil, viewer)
		item.__width = 40
		item.__cdid = id
		item.GetCooldownID = function(self) return self.__cdid end
		table.insert(viewer.__items, item)
	end
	viewer.itemFramePool = {
		EnumerateActive = function()
			local i = 0
			return function() i = i + 1; return viewer.__items[i] end
		end,
	}
	viewer.layoutCalls = 0
	viewer.Layout = function(self)
		self.layoutCalls = self.layoutCalls + 1
		for i, item in ipairs(self.__items) do item:ClearAllPoints(); item:SetPoint("LEFT", self, "LEFT", i * 40, 0) end
	end
	viewer.RefreshLayout = function(self) self:Layout() end
	viewer.OnCooldownDataChanged = function() end
	viewer.GetHideWhenInactive = function() return true end
	return viewer
end

return M
