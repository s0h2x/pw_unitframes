local addon = select(2,...)

local next = next
local pcall = pcall
local rawset = rawset

--[[
/**
 * event handler
 * usage: E = addon:package()
 * function E:ADDON_LOADED()
 *	 respond to ADDON_LOADED event
 * end
 *
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x, Eve(semlib)
 *
 * This file is provided as is (no warranties).
 */
]]

local frame, callbacks, _, prototype = CreateFrame('Frame'), {}, ...;

local function RegisterEvent(module, event, func)
	if func then
		rawset(module, event, func)
	end
	if (not callbacks[event]) then
		callbacks[event] = {}
	end
	callbacks[event][module] = true
	if strmatch(event, '^[%u_]+$') then
		pcall(function() return frame:RegisterEvent(event) end)
	end
	return module
end

local function UnregisterEvent(module, event)
	if callbacks[event] then callbacks[event][module] = nil
		if (not next(callbacks[event]) and strmatch(event,'^[%u_]+$')) then -- don't unregister unless the event table is empty
			frame:UnregisterEvent(event)
		end
	end
	return module
end

local function FireEvent(_, event, ...)
	if callbacks[event] then
		for module in pairs(callbacks[event]) do
			module[event](module, ...)
		end
	end
end

local event_module = {
	__newindex = RegisterEvent, -- function E:ADDON_LOADED() end
	__call = FireEvent, -- E('CallBack', ...) -- Fire a callback across ALL modules
	__index = {
		RegisterEvent = RegisterEvent, -- E:RegisterEvent('ADDON_LOADED', func)
		UnregisterEvent = UnregisterEvent, -- E:UnregisterEvent('ADDON_LOADED')
		FireEvent = FireEvent, -- E:FireEvent('CallBack', ...)
	},
}

prototype.package = setmetatable({}, {
	__call = function(callback_event)
		local module = setmetatable({}, event_module)
		callback_event[#callback_event+1] = module
		return module
	end,
})

frame:SetScript('OnEvent', FireEvent)

-- setmetatable({}, {__index = function(self, event) self[event] = {} return self[event] end})