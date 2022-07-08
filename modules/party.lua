local addon = select(2,...);
local config = addon.config;
local uconfig, src = config.party, config.media;
if not uconfig.enable then return end

--[[
/**
 * unit: party members
 * contains style and functions of party members frame
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

-- /* WoW APIs */
local UnitChannelInfo = UnitChannelInfo
local UnitCastingInfo = UnitCastingInfo
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS or 4

-- /* consts */
local __PartyMemberFrame_UpdatePvPStatus
local texcoord = addon.texcoord
local noop = addon.noop

-- /* castbar position */
local function PartyCastingBar_OnShow()
	if not uconfig.castbar_show then return end
	for i = 1, MAX_PARTY_MEMBERS do
		local partycastbar = _G['PartyCastingBar'..i]
		partycastbar:SetSize(uconfig.castbar_width, uconfig.castbar_height)
		if (i == 1) then
			partycastbar:SetPoint('TOPLEFT', PartyMemberFrame1, 'TOPRIGHT', -2, -16)
		else
			partycastbar:SetPoint('TOP', _G['PartyCastingBar'..i-1], 'BOTTOM', 0, -67)
		end
	end
end

-- /* handling events  */
local function PartyCastingBar_OnEvent(self, event, ...)
	if not uconfig.castbar_show then return end
	local arg1 = ...
	if (event == 'CVAR_UPDATE') then
		if (self.casting or self.channeling) then
			self:Show()
		else
			self:Hide()
		end
		return
	elseif (event == 'PARTY_MEMBERS_CHANGED' or event == 'PARTY_MEMBER_ENABLE'
		or event == 'PARTY_MEMBER_DISABLE' or event == 'PARTY_LEADER_CHANGED') then
		local nameChannel = UnitChannelInfo(self.unit)
		local nameSpell = UnitCastingInfo(self.unit)
		if (nameChannel) then
			event = 'UNIT_SPELLCAST_CHANNEL_START'
			arg1 = self.unit
		elseif (nameSpell) then
			event = 'UNIT_SPELLCAST_START'
			arg1 = self.unit
		else
			self.casting = nil
			self.channeling = nil
			self:SetMinMaxValues(0,0)
			self:SetValue(0)
			self:Hide()
			return
		end
		PartyCastingBar_OnShow(self)
	end
	CastingBarFrame_OnEvent(self, event, arg1, select(2,...))
end

local function SetPartySpellbarAspect(self)
	local spellbar = self:GetName();

	local castborder = _G[spellbar..'Border'];
	if (castborder) then
		castborder:SetTexture(src.castborder);
		castborder:SetWidth(165);
		castborder:SetHeight(49);
		castborder:ClearAllPoints();
		castborder:SetPoint('TOP', self, 'TOP', 0, 20);
	end

	local castflash = _G[spellbar..'Flash'];
	if (castflash) then
		castflash:SetTexture(src.castflash);
		castflash:SetWidth(165);
		castflash:SetHeight(49);
		castflash:ClearAllPoints();
		castflash:SetPoint('TOP', self, 'TOP', 0, 20);
	end
	
	local casticon = _G[spellbar..'Icon'];
	if (casticon) then
		casticon:SetSize(22, 22)
		casticon:ClearAllPoints()
		casticon:SetPoint('LEFT', spellbar, 'RIGHT', 5, 0)
		casticon:SetTexCoord(unpack(texcoord))
		casticon:Show();
	
		casticon.border = casticon:GetParent():CreateTexture(nil,'OVERLAY')
		casticon.border:SetPoint('TOPRIGHT', casticon, 3, 3)
		casticon.border:SetPoint('BOTTOMLEFT', casticon, -3, -3)
		casticon.border:SetTexture(src.border)
		casticon.border:SetVertexColor(unpack(config.global.castbar_icon_color))
	end
end

-- /* create party style */
local function frame_style_party()
	if not addon:taint() then
		local castbar
		for i = 1, MAX_PARTY_MEMBERS do
			local frame = _G['PartyMemberFrame'..i]
			local parent = frame or UIParent
			
			-- main style setup:
			frame:SetScale(uconfig.scale)
			
			frame.texture = _G[frame:GetName()..'Texture']
			frame.texture:SetTexture(src.partyFrame)
			frame.texture:SetVertexColor(unpack(config.global.framecolors))
			
			frame.pettexture = _G[frame:GetName()..'PetFrameTexture']
			frame.pettexture:SetVertexColor(unpack(config.global.framecolors))
			
			frame.healthbar = _G[frame:GetName()..'HealthBar']
			frame.healthbar:SetHeight(12)
			frame.healthbar:SetPoint('TOPLEFT', 46, -13)
			
			frame.manabar = _G[frame:GetName()..'ManaBar']
			frame.manabar:SetPoint('TOPLEFT', 46, -25)
			
			frame.name = _G[frame:GetName()..'Name']
			frame.name:SetFont(src.font, src.font_size -1)
			frame.name:SetShadowColor(0, 0, 0, 1)
			frame.name:SetShadowOffset(1, -1)
			
			frame.flash = _G[frame:GetName()..'Flash']
			frame.flash:SetAlpha(0)
			
			frame.healthbar.text = _G[frame.healthbar:GetName()..'Text']
			frame.healthbar.text:ClearAllPoints()
			frame.healthbar.text:SetPoint('CENTER', frame, 'CENTER', 18, 9)
			
			frame.manabar.text = _G[frame.manabar:GetName()..'Text']
			frame.manabar.text:ClearAllPoints()
			frame.manabar.text:SetPoint('CENTER', frame, 'CENTER', 18, -1)

			-- castbar setup:
			castbar = CreateFrame('STATUSBAR', 'PartyCastingBar'..i, parent, 'CastingBarFrameTemplate')
			castbar.partyID = i
			castbar:SetScale(uconfig.castbar_scale)
			
			castbar:SetScript('OnShow', PartyCastingBar_OnShow)
			castbar:SetScript('OnEvent', PartyCastingBar_OnEvent)
			
			castbar:RegisterEvent('PARTY_MEMBERS_CHANGED')
			castbar:RegisterEvent('PARTY_MEMBER_ENABLE')
			castbar:RegisterEvent('PARTY_MEMBER_DISABLE')
			castbar:RegisterEvent('PARTY_LEADER_CHANGED')
			castbar:RegisterEvent('CVAR_UPDATE')
			
			CastingBarFrame_OnLoad(castbar, 'party'..i, false, false)
			
			-- style castbar:
			SetPartySpellbarAspect(castbar);
			
			local previous = _G['PartyMemberFrame'..(i-1)..'PetFrame']
			if previous then frame:SetPoint('TOPLEFT', previous, 'BOTTOMLEFT', -23, -30) end
		end
	end
end

-- /* FFA for partymembers */
function __PartyMemberFrame_UpdatePvPStatus(self)
	local id = self:GetID()
	local pvpicon = _G['PartyMemberFrame'..id..'PVPIcon']
	pvpicon:SetTexture('Interface\\TargetingFrame\\UI-PVP-FFA')
end

-- /* setup module */
if config.global.FFA then hooksecurefunc('PartyMemberFrame_UpdatePvPStatus',__PartyMemberFrame_UpdatePvPStatus) end
frame_style_party()