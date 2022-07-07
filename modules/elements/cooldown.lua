local addon = select(2,...);
local config = addon.config.auras;
if not config.cooldown_module then return end;

-- /* lua lib */
local getmetatable = getmetatable
local unpack = unpack
local format = string.format
local floor = math.floor
local min, max = math.min, math.max

-- /* WoW APIs */
local UIParent = UIParent
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

--[[
/**
 * element: cooldowns
 * contains duration and cooldown time of auras
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x. credit: nightcracker
 *
 * This file is provided as is (no warranties).
 */
]]

local day, hour, minute = 86400, 3600, 60
local function formattime(s)
	if s >= day then
		return format('%dd',floor(s/day + .5)),s%day
	elseif s >= hour then
		return format('%dh',floor(s/hour + .5)),s%hour
	elseif s >= minute then
		return format('%dm',floor(s/minute + .5)),s%minute
	elseif s <= config.threshold then
		return format('%.1f',s), s - format('%.1f',s)
	end
	return floor(s + .5), s - floor(s)
end

local function update(self, elapsed)
	if (not self:GetParent().unit) then return end -- for auras
	if (not self.text:IsShown()) then return end
	if self.nextupdate > 0 then
		self.nextupdate = self.nextupdate - elapsed
	elseif (self:GetEffectiveScale()/UIParent:GetEffectiveScale()) < config.minscale then
		self.text:SetText''
		self.nextupdate = 1
	else
		self.nextupdate = 1
		local remaining = self.duration - (GetTime() - self.start)
		if remaining > 0 then
			local ftime, nextupdate = formattime(remaining)
			self.text:SetText(ftime)
			self.nextupdate = nextupdate
			if remaining > config.threshold then
				self.text:SetTextColor(unpack(config.duration_color))
			else
				self.text:SetTextColor(unpack(config.threshold_color))
			end
		else
			self.text:SetText''
			self.text:Hide()
		end
	end
end

local function createtext(self)
	local scale = min(self:GetParent():GetWidth()/config.aura_size, 1)
	if not config.cooldown_show then
		self.noOCC = true
	else
		local text = self:GetParent():CreateFontString(nil, 'OVERLAY', 'pUiFont_Auras')
		text:SetPoint('TOP', 0, config.timer_y)
		self:SetScript('OnUpdate', update)
		self:SetAlpha(1)
		self.text = text
		return text
	end
end

local function startcd(self, start, duration)
	if start > 0 and duration > config.minduration then
		self.start = start
		self.duration = duration
		self.nextupdate = 0
		local height = self:GetHeight()
		self.height = height
		
		local text = self.text or createtext(self)
		if text then
			text:Show()
		end
	end
end

local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
hooksecurefunc(cooldownIndex, 'SetCooldown', startcd)