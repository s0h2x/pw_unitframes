local addon = select(2,...);
local config = addon.config;
local uconfig, src = config.targettarget, config.media;

local unpack = unpack
local select = select

--[[
/**
 * unit: target of target/focus
 * contains style and functions of target of target frames
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

-- /* define style */
local styleconfig = {
	square = {
		siz = {w=70, h=75, x=-20, y=87},
		tex = {w=64, h=64, x=0,   y=-2,  t=src.targetTargetSquare, c={0,1,0,1}},
		hpb = {w=30, h=10, x=0,   y=-10},
		hpt = {			x=0,   y=-3,  j='CENTER', s=12},
		mpb = {w=30, h=10, x=0,   y=0},
		nam = {w=65, h=10, x=0,   y=46,  j='CENTER', s=13},
		por = {w=32, h=32, x=0,   y=9,   t={.08,.92,.08,.92}},
	},
	normal = {
		siz = {w=85, h=20, x=-98, y=10},
		tex = {w=128,h=64, x=16,  y=-10, t=src.targetTargetNormal, c={0,1,0,1}},
		hpb = {w=43, h=6,  x=2,   y=14},
		hpt = {			   x=-4,  y=-3,  j='CENTER', s=12},
		mpb = {w=37, h=7,  x=-1,  y=0},
		nam = {w=65, h=10, x=11,  y=-18, j='LEFT',   s=13},
		por = {w=40, h=40, x=-40, y=10,  t={0,1,0,1}},
	},
}

local function get_data_style()
	if uconfig.squarestyle then
		return styleconfig.square
	end
	return styleconfig.normal
end

-- /* create ToT & ToF style */
local function frame_style_tot(self)
	local data = get_data_style()
	local texture = _G[self:GetName()..'TextureFrameTexture']
	self:SetScale(uconfig.scale)
	self:ClearAllPoints()
	self:SetSize(data.siz.w, data.siz.h)

	texture:SetTexture(data.tex.t)
	texture:SetSize(data.tex.w, data.tex.h)
	texture:ClearAllPoints()
	texture:SetPoint('CENTER', data.tex.x, data.tex.y)
	texture:SetTexCoord(unpack(data.tex.c))
	
	self.portrait:ClearAllPoints()
	self.portrait:SetSize(data.por.w, data.por.h)
	self.portrait:SetPoint('CENTER', texture, data.por.x, data.por.y)
	self.portrait:SetTexCoord(unpack(data.por.t))
	
	self.healthbar:ClearAllPoints()
	self.healthbar:SetSize(data.hpb.w, data.hpb.h)
	self.healthbar:SetPoint('CENTER', texture, data.hpb.x, data.hpb.y)
	
	self.manabar:ClearAllPoints()
	self.manabar:SetSize(data.mpb.w, data.mpb.h)
	self.manabar:SetPoint('TOPLEFT', self.healthbar, 'BOTTOMLEFT', data.mpb.x, data.mpb.y)
	
	self.deadText:ClearAllPoints()
	self.deadText:SetPoint('CENTER', self:GetName()..'HealthBar', 'CENTER', 1, 0)
	
	self.name:ClearAllPoints()
	self.name:SetSize(data.nam.w, data.nam.h)
	self.name:SetPoint('TOP', self:GetName()..'HealthBar', data.nam.x, data.nam.y)
	self.name:SetFont(src.font, src.font_size-1)
	self.name:SetShadowColor(0, 0, 0, 1)
	self.name:SetShadowOffset(1, -1)
	self.name:SetJustifyH(data.nam.j)
	
	self.background:ClearAllPoints()
	self.background:SetAllPoints(self.healthbar)
end

-- /* setup module */
for _,frame in pairs({TargetFrameToT, FocusFrameToT}) do frame_style_tot(frame) end