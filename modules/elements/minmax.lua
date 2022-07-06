local addon = select(2,...);

-- /* lua lib */
local abs = math.abs
local select = select
local tonumber = tonumber
local min = math.min
local max = math.max
local ceil = math.ceil
local strfind = string.find
local strsub = string.sub
local format = format
local tostring = tostring
local rawset = rawset
local setmetatable = setmetatable

local hooksecurefunc = hooksecurefunc

--[[
/**
 * element: minmax
 * contains string format and math functions
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

local frameNames = setmetatable({}, {__index = function(t,k)
	local v = k:GetName() rawset(t,k,v) return v end
})

hooksecurefunc('TextStatusBar_UpdateTextString', function(statusBar)
	local str, val
	local textString = statusBar.TextString;
	local value = statusBar:GetValue();
	local _, valueMax = statusBar:GetMinMaxValues()
	if (textString) then
		if (value and value > 0) then
			if value >= 1e9 then
				-- 1,000,000,000+ like 8b
				str,val = '%.0fb', value/1e9
			elseif value >= 1e6 then
				-- 1,000,000+ like 14m
				str,val = '%.0fm', value/1e6
			elseif value >= 1e3 then
				-- 1,000+ like 2k
				str,val = '%.0fk', value/1e3
			else
				-- don't shorten numbers under 1,000
				str,val = '%d', value
			end
			if strfind(frameNames[statusBar],'Health') and value < valueMax then
				textString:SetFormattedText(str..' — %i%%', val, ceil(value/valueMax*100));
			else
				textString:SetFormattedText(str, val)
			end
		end
	end
end)
	
-- /* cast time */
hooksecurefunc('CastingBarFrame_OnUpdate', function(self, elapsed)
	if not self.timer then return end
	if self.update and self.update < elapsed then
		if self.casting then
			self.timer:SetFormattedText('%.1f',max(self.maxValue - self.value,0))
		elseif self.channeling then
			self.timer:SetFormattedText('%.1f',max(self.value,0))
		else
			self.timer:SetText('')
		end
		self.update = 0.1
	else
		self.update = self.update - elapsed
	end
end)