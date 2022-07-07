local addon = select(2,...);
local event_ = addon:package();
local config = addon.config;
local uconfig, src = config.arena, config.media;
if not uconfig.enable or not uconfig.trinkets then return end;

--[[
/**
 * element: trinkets
 * contains arena enemies cooldown trinket
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

local unpack = unpack
local select = select
local format = string.format
local wipe = wipe

local GetTime = GetTime
local GetSpellInfo = GetSpellInfo
local IsInInstance = IsInInstance
local UnitName = UnitName
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID

local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5
local PVP_TRINKET_FACTION = {
	['Alliance'] = 'Interface\\Icons\\inv_jewelry_trinketpvp_01',
	['Horde'] = 'Interface\\Icons\\inv_jewelry_trinketpvp_02',
}

local trinket_spells = {
	[GetSpellInfo(59752)] = 120,
	[GetSpellInfo(42292)] = 120,
	[GetSpellInfo(7744)] = 45,
}

local trinket_cooldown = {}
function event_:PLAYER_LEAVING_WORLD()
	wipe(trinket_cooldown)
end

local function ArenaTrinkets_OnEvent(self, event, unit, spell)
	local msgtype
	local instanceType = select(2, IsInInstance())
	if instanceType ~= 'arena' then
		self:Hide()
		return;
	else
		self:Show()
	end
	
	if (unit == self.unit) then
		local cooldown = trinket_spells[spell]
		if cooldown then
			local curTime = GetTime()
			trinket_cooldown[UnitGUID(self.unit)] = curTime + cooldown
			self.cooldown:Show()
			self.cooldown:SetCooldown(curTime, cooldown)
			if uconfig.trinket_announce then
				msgtype = trinket_spells[spell] == 120 and uconfig.text_trinket or uconfig.text_wotf
				SendChatMessage(UnitName(self.unit)..' ('..UnitClass(self.unit)..'): '..msgtype,uconfig.announce_chat)
			end
		end
	end
end

local function ArenaTrinkets_OnShow(self, event, ...)
	if (UnitExists(self.unit)) then
		local faction = PVP_TRINKET_FACTION[select(2,UnitFactionGroup(self.unit))]
		if faction then
			self.icon:SetTexture(faction)
		end
		
		local curTime = GetTime()
		local expiration = trinket_cooldown[UnitGUID(self.unit)]
		if (expiration and expiration > curTime) then
			self.cooldown:Show()
			self.cooldown:SetCooldown(curTime, expiration)
		else
			self.cooldown:Hide()
		end
	end
end

local function styletrinkets()
	for i = 1, MAX_ARENA_ENEMIES do
		local parent = _G['ArenaEnemyFrame'..i]
		local trinket = CreateFrame('Frame', '$parentTrinketFrame', parent)
		trinket:SetFrameLevel(parent:GetFrameLevel()+2)
		trinket:SetSize(14, 14)
		trinket:SetPoint('LEFT', parent, 'CENTER', 10, -17)

		local unit = 'arena'..i
		trinket.unit = unit
		
		local faction = PVP_TRINKET_FACTION[select(2,UnitFactionGroup(unit))]
		trinket.icon = trinket:CreateTexture('$parentTexture', 'BORDER')
		trinket.icon:SetAllPoints(trinket)
		trinket.icon:SetTexture(faction)
		
		trinket.border = trinket:CreateTexture('$parentBorder', 'OVERLAY', nil, 7)
		trinket.border:SetPoint('CENTER', trinket)
		trinket.border:SetSize(20, 20)
		trinket.border:SetTexture(src.trinket_border)
		trinket.border:SetVertexColor(unpack(config.global.framecolors))

		trinket.cooldown = CreateFrame('Cooldown', '$parentCooldown', trinket, 'CooldownFrameTemplate')
		trinket.cooldown:SetFrameLevel(trinket:GetFrameLevel())
		trinket.cooldown:SetAllPoints(trinket)
		trinket.cooldown:SetDrawEdge(true)

		trinket:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
		trinket:SetScript('OnShow', ArenaTrinkets_OnShow)
		trinket:SetScript('OnEvent', ArenaTrinkets_OnEvent)
	end
end
if not IsAddOnLoaded('Blizzard_ArenaUI') then LoadAddOn('Blizzard_ArenaUI') end
styletrinkets()
