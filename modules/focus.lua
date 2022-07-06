local addon = select(2,...);
local config = addon.config.focus;
local mouse, mode = config.mousebutton, config.modbutton;

--[[
/**
 * unit: focus
 * contains style and functions of focus frame
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

local _G = _G
local pairs = pairs
local type = type

-- /* WoW APIs */
local UIParent = UIParent
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

-- /* focus selection frames */ 
local nextframes = {
	TargetFrame,PlayerFrame,PetFrame,PartyMemberFrame1,PartyMemberFrame2,
	PartyMemberFrame3,PartyMemberFrame4,ArenaEnemyFrame1,ArenaEnemyFrame2,
	ArenaEnemyFrame3,ArenaEnemyFrame4,ArenaEnemyFrame5,
}

-- /* create attribute type for hotkey */
local function setfocushk(frame)
	frame:SetAttribute(mode..'-type'..mouse, 'focus')
end

-- /* setup hooks */
local function setup_hook(type, name, parent, template)
	if (template == 'SecureUnitButtonTemplate') and config.fk then
		setfocushk(_G[name])
	end
end

hooksecurefunc('CreateFrame', setup_hook)

-- /* create focus key frame */
local focuser = CreateFrame('CheckButton', 'Focuser', UIParent, 'SecureActionButtonTemplate')
focuser:SetAttribute('type1', 'macro')
focuser:SetAttribute('macrotext', '/focus mouseover')
SetOverrideBindingClick(Focuser, true, mode..'-BUTTON'..mouse, 'Focuser')
	
-- /* set the keybindings */
for _,frame in pairs(nextframes) do setfocushk(frame) end