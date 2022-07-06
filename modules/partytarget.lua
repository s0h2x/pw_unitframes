local addon = select(2,...);
local config = addon.config;
local uconfig, src = config.targettarget, config.media;
local e_party, e_arena = config.party.enable, config.arena.enable;

--[[
/**
 * unit: party target
 * contains style and functions of party target and arena target frames
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

-- /* lua lib */
local _G = _G
local unpack = unpack
local select = select
local floor = math.floor
local max = math.max

-- /* WoW APIs */
local UnitClass = UnitClass
local UnitIsConnected = UnitIsConnected
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsTappedByAllThreatList = UnitIsTappedByAllThreatList
local UnitReaction = UnitReaction
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitName = UnitName
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local PowerBarColor = PowerBarColor
local UnitIsPlayer = UnitIsPlayer
local UnitInRange = UnitInRange
local UnitIsUnit = UnitIsUnit
local UnitExists = UnitExists
local UIParent = UIParent
local hooksecurefunc = hooksecurefunc

-- /* consts */
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS or 4
local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5

-- /* locals */
local __PartyTarget_OnUpdate

-- /* define style */
local styleconfig = {
	square = {
		siz = {w=70, h=75, x=-62, y=8},
		tex = {w=64, h=64, x=0,   y=-2,  t=src.targetTargetSquare, c={0,1,0,1}},
		hpb = {w=30, h=10, x=0,   y=-10},
		hpt = {			x=0,   y=-3,  j='CENTER', s=12},
		mpb = {w=30, h=10, x=0,   y=0},
		nam = {w=55, h=10, x=0,   y=46,  j='CENTER', s=13},
		por = {w=32, h=32, x=0,   y=9,   t={.08,.92,.08,.92}},
	},
}
local data = styleconfig.square
local squareicn = [[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]]

-- /* update name */
local function PartyTarget_UpdateName(self, unit)
	local getname = UnitName(unit)
	self.name:SetText(getname)
	self.name:SetFontObject('pUiFont')
end

-- /* update healthbar */
local function PartyTarget_UpdateHealth(self, unit)
    if (UnitIsGhost(unit)) then
		self.healthbar:SetValue(0)
		self.healthbar.text:SetText('|cffeed200Ghost|r')
		return
	end
    if (UnitIsDead(unit)) then
        self.healthbar:SetValue(0)
        self.healthbar.text:SetText('|cffeed200Dead|r')
        return 
    end
    
	local hp = UnitHealth(unit)
    local perc = floor(hp/max((UnitHealthMax(unit) or 1),1)*100)
    self.healthbar:SetValue(perc)
	
	if UnitIsPlayer(unit) and unit == self.unit and UnitClass(unit) then
		if (not UnitIsConnected(unit)) then
			self.healthbar:SetStatusBarColor(.6, .6, .6, .5)
			return
		end
		local class = select(2,UnitClass(unit))
		local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
		if class then
			self.healthbar:SetStatusBarColor(color.r*1.18, color.g*1.18, color.b*1.18)
		end
	elseif UnitExists(unit) and not UnitIsPlayer(unit) and unit == self.unit then
		local reaction = FACTION_BAR_COLORS[UnitReaction(unit, 'player')]
		if reaction then
			self.healthbar:SetStatusBarColor(reaction.r*1.42, reaction.g*1.42, reaction.b*1.42)
		else
			self.healthbar:SetStatusBarColor(0, .6, .1)
		end
		if (not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit)) then
			self.healthbar:SetStatusBarColor(.5, .5, .5) -- gray if npc is tapped by other player
		end
	end
end

-- /* update manabar */
local function PartyTarget_UpdatePower(self, unit)
	local powerType = UnitPowerType(unit)
	local color = PowerBarColor[powerType] or PowerBarColor['MANA']
	self.manabar:SetStatusBarColor(color.r, color.g, color.b)
	self.manabar:SetValue(floor(UnitPower(unit,powerType)/UnitPowerMax(unit,powerType) * 100))
end

-- /* update fade */
local function PartyTarget_UpdateAlpha(self, unit)
	if (not UnitIsPlayer(unit)) then
		self:SetAlpha(1)
	elseif (UnitInRange(unit)) then
		self:SetAlpha(1)
	else
		self:SetAlpha(0.7)
	end
end

-- /* update portraits */
local function PartyTarget_UpdatePortrait(self, unit)
	if UnitIsPlayer(self.unit) and config.global.classportraits then
		local class = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
		self.portrait:SetTexture(squareicn)
		self.portrait:SetTexCoord(unpack(class))
	else
		self.portrait:SetTexCoord(.08,.92,.08,.92)
	end
end

-- /* update party target frame */
function __PartyTarget_OnUpdate(self)
	local unit = 'party'..self:GetID()..'target'
	local frame = _G['PartyTargetFrame'..self:GetID()]
	if UnitExists(unit) then
		SetPortraitTexture(frame.portrait, unit)
		PartyTarget_UpdateName(frame, unit)
		PartyTarget_UpdateHealth(frame, unit)
		PartyTarget_UpdatePower(frame, unit)
		PartyTarget_UpdateAlpha(frame, unit)
		PartyTarget_UpdatePortrait(frame, unit)
	else
		frame:SetAlpha(0)
	end
end

-- /* update arena target frame */
local function ArenaTarget_OnUpdate(self)
	local unit = 'arena'..self:GetID()..'target'
	local frame = _G['ArenaTargetFrame'..self:GetID()]
	if UnitExists(unit) then
		SetPortraitTexture(frame.portrait, unit)
		PartyTarget_UpdateName(frame, unit)
		PartyTarget_UpdateHealth(frame, unit)
		PartyTarget_UpdatePower(frame, unit)
		PartyTarget_UpdateAlpha(frame, unit)
		PartyTarget_UpdatePortrait(frame, unit)
	else
		frame:SetAlpha(0)
	end
end

-- /* create group target frame */
local function c_target(i, ptype, utype, ftype)
	local parent = _G[ptype..i] or UIParent
	local frame = CreateFrame('Button', ftype..i, parent, 'SecureUnitButtonTemplate')
	frame.unit = utype..i..'target'
	frame:SetID(i)
	frame:SetFrameStrata('LOW')
	frame:SetSize(data.siz.w, data.siz.h)
	frame:SetAttribute('unit', utype..i..'target')
	frame:SetAttribute('type1', 'target')
	
	frame.texture = CreateFrame('Frame', nil, frame)
	frame.texture:SetSize(128, 64)
	frame.texture:SetPoint('CENTER', data.tex.x, data.tex.y)
	frame.texture:SetFrameLevel(8)
	frame.texture.border = frame.texture:CreateTexture(nil, 'BORDER')
	frame.texture.border:SetSize(data.tex.w, data.tex.h)
	frame.texture.border:SetPoint('CENTER')
	frame.texture.border:SetTexture(data.tex.t)
	frame.texture.border:SetVertexColor(unpack(config.global.framecolors))

	frame.portrait = frame:CreateTexture(nil, 'BACKGROUND')
	frame.portrait:SetSize(data.por.w, data.por.h)
	frame.portrait:SetPoint('CENTER', frame.texture.border, data.por.x, data.por.y)
	frame.portrait:SetTexture('Interface\\TargetingFrame\\TargetDead')
	frame.portrait:SetTexCoord(unpack(data.por.t))

	frame.healthbar = CreateFrame('STATUSBAR', nil, frame, 'TextStatusBar')
	frame.healthbar:SetStatusBarTexture(src.statusbar)
	frame.healthbar:SetSize(data.hpb.w, data.hpb.h)
	frame.healthbar:SetPoint('CENTER', frame.texture.border, data.hpb.x, data.hpb.y)
	frame.healthbar:SetFrameLevel(1)
	frame.healthbar:SetMinMaxValues(0, 100)

    frame.healthbar.text = frame.texture:CreateFontString(nil, 'ARTWORK')
	frame.healthbar.text:SetPoint('CENTER', frame.healthbar, 'CENTER')
	frame.healthbar.text:SetFont(src.font, src.font_size -1)
	frame.healthbar.text:SetTextColor(1, 1, 1)

	frame.manabar = CreateFrame('STATUSBAR', nil, frame, 'TextStatusBar')
	frame.manabar:SetStatusBarTexture(src.statusbar)
	frame.manabar:SetSize(data.mpb.w, data.mpb.h)
	frame.manabar:SetPoint('TOPLEFT', frame.healthbar, 'BOTTOMLEFT', data.mpb.x, data.mpb.y)
	frame.manabar:SetFrameLevel(1)
	frame.manabar:SetMinMaxValues(0, 100)
	
	frame.name = frame:CreateFontString(nil, 'ARTWORK')
	frame.name:SetSize(data.nam.w, data.nam.h)
	frame.name:SetPoint('TOP', frame.healthbar, data.nam.x, data.nam.y)
	frame.name:SetFont(src.font, src.font_size -1)
	frame.name:SetShadowColor(0, 0, 0, 1)
	frame.name:SetShadowOffset(1, -1)
	frame.name:SetTextColor(1, 0.82, 0)
	frame.name:SetJustifyH(data.nam.j)

	frame:SetAlpha(0)
	
	hooksecurefunc('Arena_LoadUI', function()
		frame:RegisterEvent('ARENA_OPPONENT_UPDATE')
		frame:SetScript('OnUpdate', ArenaTarget_OnUpdate)
	end);

	return frame
end

-- /* setup arena target */
if uconfig.arenatargets and e_arena then
	if not IsAddOnLoaded('Blizzard_ArenaUI') then LoadAddOn('Blizzard_ArenaUI') end
	for i=1, MAX_ARENA_ENEMIES do
		c_target(i, 'ArenaEnemyFrame', 'arena', 'ArenaTargetFrame')
		local arenatarget = _G['ArenaTargetFrame'..i]
		arenatarget:SetScale(uconfig.arenatarget_scale)
		if i==1 then
			arenatarget:SetPoint('TOPRIGHT', ArenaEnemyFrame1, 'TOPRIGHT', -data.siz.x, data.siz.y);
		else
			arenatarget:SetPoint('TOP', _G['ArenaTargetFrame'..i-1], 'BOTTOM', 0, -10);
		end;
	end
end

-- /* setup party target */
if uconfig.partytargets and e_party then
	for i=1, MAX_PARTY_MEMBERS do
		c_target(i, 'PartyMemberFrame', 'party', 'PartyTargetFrame')
		local partytarget = _G['PartyTargetFrame'..i]
		partytarget:SetScale(uconfig.partytarget_scale)
		if i==1 then
			partytarget:SetPoint('TOPLEFT', PartyMemberFrame1, 'TOPLEFT', data.siz.x, data.siz.y);
		else
			partytarget:SetPoint('TOP', _G['PartyTargetFrame'..i-1], 'BOTTOM', 0, -16);
		end;
	end
	hooksecurefunc('PartyMemberFrame_OnUpdate',__PartyTarget_OnUpdate)
end