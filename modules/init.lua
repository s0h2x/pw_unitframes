local addonName, addon = ...;
local event_ = addon:package();

local table = addon.table
local unpack = unpack
local select = select
local pairs = pairs
local print = print
local collectgarbage = collectgarbage

--[[
/**
 * initialize addon
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

local default_config = {
	signin = false,
	elements_anchor = {},
}

function event_:ADDON_LOADED()
	self:UnregisterEvent(event)
	if (addonName ~= 'pw_unitframes') then
		return print('[debug]: initialization |cfff12c60error|r, report to s0high')
	end
	
	-- create save data table:
	_appdata['signin'] = true
	table.assign_over(default_config, _appdata)
	
	addon:setup_anchor()
	
	collectgarbage('collect')
	
	self.ADDON_LOADED = nil
end