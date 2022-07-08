local addon = select(2,...);
local config = addon.config;
local uconfig, src = config.arena, config.media;
if not uconfig.enable then return end;

--[[
/**
 * unit: arena
 * contains style and functions of arena frame
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

local _G = _G
local unpack = unpack

-- /* WoW APIs */
local hooksecurefunc = hooksecurefunc

-- /* consts */
local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5
local texcoord = addon.texcoord
local noop = addon.noop

-- /* create arena style */
local function frame_style_arena()
	local castbar;
	for i = 1, MAX_ARENA_ENEMIES do
		local frame = _G['ArenaEnemyFrame'..i];
		ArenaEnemyFrames:SetScale(uconfig.scale*1.3)
		
		-- main style setup:
		frame.texture = _G[frame:GetName()..'Texture']
		frame.texture:ClearAllPoints();
		frame.texture:SetSize(120, 52);
		frame.texture:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 5);
		frame.texture:SetTexture(src.targetFrame);
		frame.texture:SetVertexColor(unpack(config.global.framecolors))
		frame.texture:SetTexCoord(0.09375, 1.0, 0, 0.78125)
		
		-- pet setup:
		frame.pet = _G[frame:GetName()..'PetFrame']
		frame.pet:SetScale(.74)
		frame.pet:ClearAllPoints();
		frame.pet:SetPoint('TOPLEFT', frame, 'TOPLEFT', 2, -38)
		frame.pettexture = _G[frame.pet:GetName()..'Texture']
		frame.pettexture:SetVertexColor(unpack(config.global.framecolors))
		frame.petportrait = _G[frame.pet:GetName()..'Portrait']
		frame.petportrait:SetAllPoints()
		
		frame.bg = _G[frame:GetName()..'Background']
		frame.bg:SetSize(62, 20)
		frame.bg:SetPoint('TOPLEFT', 3, -8)
		
		frame.healthbar:SetSize(62, 14);
		frame.healthbar:SetPoint('TOPLEFT', frame, 'TOPLEFT', 3, -8);
		frame.manabar:SetSize(62, 6);
		frame.manabar:SetPoint('TOPLEFT', frame.healthbar, 'TOPLEFT', 0, -14);
		
		frame.name:ClearAllPoints();
		frame.name:SetPoint('BOTTOM', frame.healthbar, 'TOP', 0, 4);
		frame.name:SetFont(src.font, src.font_size -6)
		frame.name:SetShadowColor(0, 0, 0, 1)
		frame.name:SetShadowOffset(.6, -.6)
		if not uconfig.name then frame.name:SetAlpha(0) end
		
		frame.flash = _G[frame:GetName()..'Flash']
		frame.flash:Hide()
		
		frame.healthbar.TextString:ClearAllPoints()
		frame.healthbar.TextString:SetPoint('CENTER', frame.healthbar)
		frame.healthbar.TextString.SetPoint = noop
		frame.healthbar.TextString:SetFont(src.font, uconfig.textstring_size)
		frame.healthbar.TextString:SetShadowColor(0, 0, 0, 1)
		frame.healthbar.TextString:SetShadowOffset(.6, -.6)
		
		frame.manabar.TextString:ClearAllPoints()
		frame.manabar.TextString:SetPoint('CENTER', frame.manabar)
		frame.manabar.TextString.SetPoint = noop
		frame.manabar.TextString:SetFont(src.font, uconfig.textstring_size)
		frame.manabar.TextString:SetShadowColor(0, 0, 0, 1)
		frame.manabar.TextString:SetShadowOffset(.6, -.6)
		
		frame.classPortrait:SetSize(34, 34);
		frame.classPortrait:ClearAllPoints();
		frame.classPortrait:SetPoint('RIGHT', frame, 'RIGHT', -4, -2);

		if config.global.prettyportraits then
			frame.classPortrait:SetTexture(src.portraits);
		end
		
		-- castbar setup:
		castbar = _G[frame:GetName()..'CastingBar']
		castbar:SetSize(74, 6)
		castbar.border = castbar:CreateTexture(nil,'OVERLAY')
		castbar.border:SetSize(98, 28)
		castbar.border:SetPoint('CENTER', castbar)
		castbar.border:SetTexture(src.castborder)
		
		castbar.flash = _G[castbar:GetName()..'Flash']
		castbar.flash:SetSize(98, 28)
		castbar.flash:ClearAllPoints()
		castbar.flash:SetPoint('CENTER', castbar)
		castbar.flash:SetTexture(src.castflash)
		
		castbar.spark = _G[castbar:GetName()..'Spark']
		castbar.spark:SetSize(14, 14)
		
		castbar.icon = _G[castbar:GetName()..'Icon']
		castbar.icon:SetSize(10, 10)
		castbar.icon:SetTexCoord(unpack(texcoord))
		
		castbar.icon.border = castbar:CreateTexture(nil,'OVERLAY')
		castbar.icon.border:SetPoint('TOPRIGHT', castbar.icon, 2, 2)
		castbar.icon.border:SetPoint('BOTTOMLEFT', castbar.icon, -2, -2)
		castbar.icon.border:SetTexture(src.border)
		castbar.icon.border:SetVertexColor(unpack(config.global.castbar_icon_color))
		
		castbar.text = _G[castbar:GetName()..'Text']
		castbar.text:ClearAllPoints()
		castbar.text:SetPoint('CENTER', castbar, 0, 1)
		castbar.text:SetFont(src.font, uconfig.textcast_size)
		castbar.text:SetShadowColor(0, 0, 0, 1)
		castbar.text:SetShadowOffset(.6, -.6)
		
		castbar.timer = castbar:CreateFontString(nil,'OVERLAY')
		castbar.timer:SetPoint('RIGHT', castbar, 'RIGHT', -2, 0)
		castbar.timer:SetFont(src.font, uconfig.textcast_size -1)
		castbar.timer:SetShadowColor(0, 0, 0, 1)
		castbar.timer:SetShadowOffset(.6, -.6)
		castbar.update = 0.1
	end
end
frame_style_arena()
-- hooksecurefunc('Arena_LoadUI',frame_style_arena);