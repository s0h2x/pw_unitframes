local addon = select(2,...);
local config = addon.config;
local own, src = config.global, config.media;
if not own.castbar_show then return end;

--[[
/**
 * element: castbar
 * contains castbars for player, target, focus
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

-- /* lua lib */
local _G = _G
local unpack = unpack
local pairs = pairs
local setmetatable = setmetatable

-- /* WoW APIs */
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

-- /* consts */
local noop = addon.noop
local texcoord = addon.texcoord

-- /* config */
local config_dimension = setmetatable({
	CastingBarFrame = {siz = {w=30, h=30},},
	TargetFrameSpellBar = {siz = {w=22, h=22},},
	FocusFrameSpellBar = {siz = {w=22, h=22},},
},{
	__index = function(t,k)
		local _,_,v = k:GetName()
		t[k] = v
		return v
	end,
})

-- /* create castbars style */
local function stylecastbar()
	for _,frame in pairs({CastingBarFrame,TargetFrameSpellBar,FocusFrameSpellBar}) do
		frame:SetScale(own.castbar_scale)
		
		frame.border = _G[frame:GetName()..'Border']
		frame.border:SetTexture(src.castborder)
		frame.border:SetVertexColor(unpack(own.framecolors))
		
		frame.flash = _G[frame:GetName()..'Flash']
		frame.flash:SetTexture(src.castflash)
		
		frame.shield = _G[frame:GetName()..'BorderShield']
		frame.shield:SetTexture(src.castshield)
		
		frame.text = _G[frame:GetName()..'Text']
		frame.text:SetFontObject('pUiFont')
		
		frame.timer = frame:CreateFontString(nil,'OVERLAY','pUiFont')
		frame.timer:SetPoint('RIGHT', frame, 'RIGHT', -2, 1)
		frame.update = 0.1
	end
	
	for _,frame in pairs({CastingBarFrameIcon,TargetFrameSpellBarIcon,FocusFrameSpellBarIcon}) do
		local data = config_dimension[frame:GetParent():GetName()]
		frame:Show()
		frame:SetSize(data.siz.w, data.siz.h)
		frame:SetTexCoord(unpack(texcoord))
		
		frame.border = frame:GetParent():CreateTexture(nil,'OVERLAY')
		frame.border:SetPoint('TOPRIGHT', frame, 3, 3)
		frame.border:SetPoint('BOTTOMLEFT', frame, -3, -3)
		frame.border:SetTexture(src.border)
	end
	
	-- set some elements to top bar, its special for player:
	CastingBarFrameBorder:SetPoint('TOP', 0, 26)
	CastingBarFrameFlash:SetPoint('TOP', 0, 26)
	CastingBarFrameIcon:ClearAllPoints()
	CastingBarFrameIcon:SetPoint('CENTER', CastingBarFrame, 'TOP', 0, 24)
	CastingBarFrameText:ClearAllPoints()
	CastingBarFrameText:SetPoint('CENTER', 0, 1)
end
stylecastbar()