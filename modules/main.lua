local addon = select(2,...);
local config, c_anchor = addon.config, addon.c_anchor;
local src, position = config.media, config.position;

--[[
/**
 * create units style
 * contains anchor and functions for all units
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

-- /* lua lib */
local unpack = unpack
local pairs = pairs
local setmetatable = setmetatable
local ipairs = ipairs

-- /* WoW APIs */
local UnitClass = UnitClass
local UnitAffectingCombat = UnitAffectingCombat
local UIParent = UIParent
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

-- /* consts */
local noop = addon.noop
local sqr = config.targettarget.squarestyle
local xofs,yofs = config.auras.start_x,config.auras.start_y

-- /* anchor table */
local config_anchor = setmetatable({
	PlayerFrame = {pos={a='CENTER', p=UIParent, a2='CENTER', x=-290, y=-100},siz={w=140, h=40},par=true},
	TargetFrame = {pos={a='CENTER', p=UIParent, a2='CENTER', x=290, y=-100},siz={w=140, h=40},par=true},
	FocusFrame = {pos={a='CENTER', p=UIParent, a2='CENTER', x=-305, y=89},siz={w=140, h=40},par=true},
	PetFrame = {pos={a='TOPLEFT', p=PlayerFrame, a2='TOPLEFT', x=98, y=-84},siz={w=124, h=46}},
	PartyMemberFrame1 = {pos={a='LEFT', p=UIParent, a2='LEFT', x=120, y=125},siz={w=150, h=144},par=true},
	ArenaEnemyFrame1 = {pos={a='RIGHT', p=UIParent, a2='RIGHT', x=-120, y=125},siz={w=150, h=144},par=true},
	PartyTargetFrame1 = {pos={a='TOPLEFT', p=PartyMemberFrame1, a2='TOPLEFT', x=-62, y=0},siz={w=50, h=70}},
	ArenaTargetFrame1 = {pos={a='TOPRIGHT', p=ArenaEnemyFrame1, a2='TOPRIGHT',x=62, y=0},siz={w=50, h=70}},
	TargetFrameToT = {pos={a='TOPLEFT', p=TargetFrame, a2='BOTTOMRIGHT', x=sqr and -20 or -116, y=sqr and 87 or 20},siz={w=90, h=40}},
	FocusFrameToT = {pos={a='TOPLEFT', p=FocusFrame, a2='BOTTOMRIGHT', x=sqr and -20 or -116, y=sqr and 87 or 20},siz={w=90, h=40}},
	CastingBarFrame = {pos={a='CENTER', p=UIParent, a2='CENTER', x=0, y=-160},siz={w=220, h=24}},
	TargetFrameSpellBar = {pos={a='CENTER', p=TargetFrame, a2='TOPRIGHT', x=-142, y=50},siz={w=184, h=22}},
	FocusFrameSpellBar = {pos={a='CENTER', p=FocusFrame, a2='TOPLEFT', x=100, y=15},siz={w=184, h=22}},
	PartyCastingBar1 = {pos={a='TOPLEFT', p=PartyMemberFrame1, a2='TOPRIGHT', x=6, y=-10},siz={w =174, h=42}},
	TargetBuffs = {pos={a='TOPLEFT', p=TargetFrame, a2='BOTTOMLEFT', x=xofs, y=yofs},siz={w=124, h=30},apos='TOPLEFT'},
	TargetDebuffs = {pos={a='LEFT', p=TargetFrame, a2='LEFT', x=xofs, y=yofs +6},siz={w=124, h=30},apos='TOPLEFT'},
	FocusBuffs = {pos={a='TOPLEFT', p=FocusFrame, a2='BOTTOMLEFT', x=xofs, y=yofs},siz={w=124, h=30},apos='TOPLEFT'},
	FocusDebuffs = {pos={a='LEFT', p=FocusFrame, a2='LEFT', x=xofs, y=yofs +6},siz={w=124, h=30},apos='TOPLEFT'},
},{
	__index = function(t,k)
		local _,_,v = k:GetName()
		t[k] = v
		return v
	end,
})

-- /* string table */
local strings = {
	own = {
		PlayerFrameHealthBarText,
		PlayerFrameManaBarText,
		TargetFrameTextureFrameHealthBarText,
		TargetFrameTextureFrameManaBarText,
		FocusFrameTextureFrameHealthBarText,
		FocusFrameTextureFrameManaBarText,
		PetFrameHealthBarText,
		PetFrameManaBarText
	},
	party = {
		PartyMemberFrame1HealthBarText,
		PartyMemberFrame1ManaBarText,
		PartyMemberFrame2HealthBarText,
		PartyMemberFrame2ManaBarText,
		PartyMemberFrame3HealthBarText,
		PartyMemberFrame3ManaBarText,
		PartyMemberFrame4HealthBarText,
		PartyMemberFrame4ManaBarText
	},
}

local nextframes = {
	PlayerFrame,TargetFrame,PartyMemberFrame1,ArenaEnemyFrame1,PartyTargetFrame1,TargetFrameToT,FocusFrameToT,
	CastingBarFrame,TargetFrameSpellBar,FocusFrameSpellBar,PartyCastingBar1,TargetBuffs,TargetDebuffs,
	ArenaTargetFrame1,PetFrame,FocusFrame,FocusBuffs,FocusDebuffs
}

-- /* make frames cleaner */
for _,objname in ipairs({
	'PlayerAttackBackground','PlayerAttackGlow',
	'PlayerFrameFlash','PlayerRestGlow',
	'PlayerStatusGlow','PlayerStatusTexture',
	'TargetFrameNameBackground','FocusFrameNameBackground',
}) do
	local obj = _G[objname]
	if obj then
		obj:Hide()
		obj.Show = noop
	end
end

-- /* setup anchor */
function addon:setup_anchor()
	if addon:taint() then return end
	PlayerFrame:SetScale(config.player.scale)
	PlayerFrame:SetMovable(false)
	TargetFrame:SetScale(config.target.scale)
	FocusFrame:SetScale(config.focus.scale)
	FocusFrame:SetMovable(false)
	-- create anchor:
	for _,frame in pairs(nextframes) do
		local data = config_anchor[frame:GetName()]
		local position = {data.pos.a, data.pos.p, data.pos.a2, data.pos.x, data.pos.y}
		local name = frame:GetName()
		local apos = data.apos or 'CENTER'
		local color = data.par or false
		frame:ClearAllPoints()
		frame.anchor = c_anchor(frame,name,name,position,data.siz.w,data.siz.h,color,apos)
		frame.SetPoint = noop
	end
end

-- /* create combat indicator */
local ct = CreateFrame('Frame', nil, TargetFrame)
ct:SetPoint('RIGHT', TargetFrame, 2, 5)
local cf = CreateFrame('Frame', nil, FocusFrame)
cf:SetPoint('RIGHT', FocusFrame, 2, 5)

local frames = {target = {ct,'PLAYER_TARGET_CHANGED'},focus = {cf,'PLAYER_FOCUS_CHANGED'},}
if config.global.combaticon then
	for k,v in pairs(frames) do
		local f = v[1]
		f:SetSize(30, 30)
		f.t = f:CreateTexture(nil, 'BORDER')
		f.t:SetAllPoints()
		f.t:SetTexture(src.dualweild)
		f:Hide()

		f:SetScript('OnEvent', function(self, event, unit)
			if (unit == k or event == v[2]) then
				self[UnitAffectingCombat(k) and 'Show' or 'Hide'](self)
			end
		end)
	 
		f:RegisterEvent('UNIT_FLAGS')
		f:RegisterEvent('PLAYER_TARGET_CHANGED')
		f:RegisterEvent('PLAYER_FOCUS_CHANGED')
	end
end

-- /* create string style */
local function style_string()
	for _,text in pairs(strings.own) do
		text:SetFont(src.font, src.font_size)
		text:SetShadowColor(0, 0, 0, 1)
		text:SetShadowOffset(src.font_offset*1.2, -src.font_offset*1.2)
	end
	for _,text in pairs(strings.party) do
		text:SetFont(src.font, src.font_size -2)
		text:SetShadowColor(0, 0, 0, 1)
		text:SetShadowOffset(src.font_offset, -src.font_offset)
	end
end
style_string()