--[[
/**
 * compatibility core functions
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

local select = select
local addon = select(2,...);

local UnitAffectingCombat = UnitAffectingCombat
local InCombatLockdown = InCombatLockdown

-- /* init SavedVariables */
local addon_config = {}
_appdata = addon_config

-- /* implicit compatibility */
local texcoord = {.08, .92, .08, .92}
local backdrop = {bgFile = [[Interface\Buttons\WHITE8x8]],
edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 14,
insets = {left = 2.6, right = 2.6, top = 2.6, bottom = 2.6}}
local noop = function() return end
local eject = function(obj)
    if obj.UnregisterAllEvents then
        obj:UnregisterAllEvents()
    end
    obj.Show = noop
    obj:Hide()
end

-- /* for avoid taint */
local function taintable()
    return (InCombatLockdown() or (UnitAffectingCombat('player') or UnitAffectingCombat('pet')))
end

-- /* checks if the texture we are trying to set it */
local function check_texture(arg1, arg2)
	if arg1:GetTexture() ~= arg2 then arg1:SetTexture(arg2) end
end	

-- /* create movable frame */
local function console_anchor(parent, saved, shifthk)
	local frame = parent or self
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag('LeftButton')
	frame:SetScript('OnDragStart', function()
		if shifthk and not IsShiftKeyDown() then return end
		frame:StartMoving()
	end)
	frame:SetScript('OnDragStop', function()
		frame:StopMovingOrSizing()
		if saved then
			local orig, _, tar, x, y = frame:GetPoint()
			_appdata['elements_anchor'][frame:GetName()] = {orig, 'UIParent', tar, x, y}
		end
	end)
end

-- /* create main font */
local pUiFont = CreateFont('pUiFont')
pUiFont:SetFont([[Interface\AddOns\pw_unitframes\assets\PTSans-Bold.ttf]], 14)
pUiFont:SetShadowColor(0, 0, 0, 1)
pUiFont:SetShadowOffset(1,-1)
local pUiFont_Auras = CreateFont('pUiFont_Auras')
pUiFont_Auras:SetFont(pUiFont:GetFont(), 10, 'OUTLINE')

-- /* callback */
addon.texcoord = texcoord
addon.noop = noop
addon.taint = taintable
addon.eject = eject
addon.backdrop = backdrop
addon.check_texture = check_texture
addon.console_anchor = console_anchor