local addon = select(2,...);
local config = addon.config;
local own, src, tot = config.global, config.media, config.targettarget;

-- /* lua lib */
local unpack = unpack
local select = select

-- /* WoW APIs */
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local hooksecurefunc = hooksecurefunc
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local squareicn = [[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]]

--[[
/**
 * element: portraits
 * contains unit class portrait textures
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

hooksecurefunc('UnitFramePortrait_Update',function(self)
	if self.portrait and own.classportraits then
		if UnitIsPlayer(self.unit) then
			local class = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
			if class then
				-- checking targetoftargets and set square icons if config is squarestyle:
				if (tot.squarestyle and self.unit == 'targettarget' and self.unit == 'focus-target') then
					self.portrait:SetTexture(squareicn)
				else
					if own.prettyportraits then self.portrait:SetTexture(src.portraits)
					else self.portrait:SetTexture('Interface\\TargetingFrame\\UI-Classes-Circles') end
				end
				self.portrait:SetTexCoord(unpack(class))
			end
		else
			if (tot.squarestyle and self.unit == 'targettarget' and self.unit == 'focus-target') then
				self.portrait:SetTexCoord(.08,.92,.08,.92)
			else
				self.portrait:SetTexCoord(0, 1, 0, 1)
			end
		end
	end
end);