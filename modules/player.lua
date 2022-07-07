local addon = select(2,...);
local config = addon.config;
local uconfig, src = config.player, config.media;

--[[
/**
 * unit: player
 * contains style and functions of player frame
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

local select = select

local UnitClass = UnitClass
local get_unitclass = select(2, UnitClass('player'))

local __PlayerFrame_ToPlayerArt
local __PlayerFrame_UpdatePvPStatus

-- /* create player style */
function __PlayerFrame_ToPlayerArt(self)
	if uconfig.elite then PlayerFrameTexture:SetTexture(src.targetElite)
	else PlayerFrameTexture:SetTexture(src.targetFrame) end
	
	-- style combat icon:
	PlayerAttackIcon:ClearAllPoints()
	PlayerAttackIcon:SetPoint('TOPLEFT', PlayerRestIcon, -30, 20)
	PlayerAttackIcon:SetSize(28, 28)
	PlayerAttackIcon:SetTexture(src.dualweild)
	PlayerAttackIcon:SetTexCoord(0, 1, 0, 1);

	PlayerFrameVehicleTexture:Hide()
	PlayerFrameGroupIndicator:Hide()
	
	-- style resources:
	self.healthbar:SetWidth(119);
	self.healthbar:SetHeight(27);
	self.healthbar:SetPoint('TOPLEFT', 106, -24);
	self.manabar:SetWidth(119);
	self.manabar:SetPoint('TOPLEFT', 106, -52);
	
	-- reanchor portrait:
	self.portrait:ClearAllPoints()
	self.portrait:SetPoint('TOPLEFT', 44, -12)

	-- style string format:
	self.healthbar.TextString:SetPoint('CENTER', PlayerFrame, 'CENTER', 50, 12)
	self.manabar.TextString:SetPoint('CENTER', PlayerFrame, 'CENTER', 48, -7)
	
	self.name:SetPoint('CENTER', 50, 37)
	self.name:SetFont(src.font, src.font_size+1)
	self.name:SetShadowColor(0, 0, 0, 1)
	self.name:SetShadowOffset(1, -1)
	
	-- style frame background:	
	PlayerFrameBackground:ClearAllPoints()
	PlayerFrameBackground:SetPoint('TOPLEFT', 106, -24)
	
	-- style pet frame:
	PetName:SetFont(src.font, src.font_size -2)
	PetName:SetShadowColor(0, 0, 0, 1)
	PetName:SetShadowOffset(1, -1)
	
	PlayerFrameAlternateManaBar:ClearAllPoints()
	PlayerFrameAlternateManaBar:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 128, 23)
	
	-- tweak player elements with config:
	if not uconfig.name then PlayerName:SetAlpha(0) end
	if not uconfig.leadericon then PlayerLeaderIcon:SetAlpha(0) end
	if not uconfig.level then PlayerLevelText:SetAlpha(0) end
	if not uconfig.petname then PetName:SetAlpha(0) end
	-- style rune orbs:
	if (get_unitclass == 'DEATHKNIGHT') then
		RuneFrame:ClearAllPoints()
		RuneFrame.anchor = addon.c_anchor(RuneFrame,'Runes',RuneFrame:GetName(),uconfig.runeanchor,140,40)
		RuneFrame:SetParent(PlayerFrame)
		RuneFrame:SetScale(uconfig.runescale)
	end
end

-- /* FFA for player */
function __PlayerFrame_UpdatePvPStatus()
	PlayerPVPIcon:SetTexture('Interface\\TargetingFrame\\UI-PVP-FFA')
end

-- /* register module */
hooksecurefunc('PlayerFrame_ToPlayerArt',__PlayerFrame_ToPlayerArt)
if config.global.FFA then
	hooksecurefunc('PlayerFrame_UpdatePvPStatus',__PlayerFrame_UpdatePvPStatus)
end