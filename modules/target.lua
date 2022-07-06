local addon = select(2,...);
local config = addon.config;
local uconfig, src = config.target, config.media;

--[[
/**
 * unit: target
 * contains style and functions of target frame
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

local __TargetFrame_CheckClassification
local __TargetFrame_CheckFaction

-- /* create target style */
function __TargetFrame_CheckClassification(self, forceNormalTexture)
	local classification = UnitClassification(self.unit);
	local threat = self.threatIndicator;
	if forceNormalTexture then
		self.borderTexture:SetTexture(src.targetFrame);
	elseif classification == 'worldboss' or classification == 'elite' then
		self.borderTexture:SetTexture(src.targetElite);
	elseif classification == 'rareelite' then
		self.borderTexture:SetTexture(src.targetElite);
	elseif classification == 'rare' then
		self.borderTexture:SetTexture(src.targetElite);
	else
		self.borderTexture:SetTexture(src.targetFrame);
		forceNormalTexture = true;
	end
	
	addon.check_texture(threat,'Interface\\TargetingFrame\\UI-TargetingFrame-Flash')
	if (forceNormalTexture) then
		self.haveElite = nil;
		if (threat) then
			if (classification == 'minus') then
				addon.check_texture(threat,'Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash')
				threat:SetTexCoord(0, 1, 0, 1);
			else
				threat:SetTexture('Interface\\TargetingFrame\\UI-FocusFrame-Large-Flash');
				threat:SetTexCoord(0.0, 0.945, 0.0, 0.73125);
			end
		end
	else
		self.haveElite = true;
		if (threat) then
			threat:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
			threat:SetWidth(242);
			threat:SetHeight(112);
		end
	end
	
	self.healthbar:SetSize(119, 27);
	self.healthbar:SetPoint('TOPLEFT', 7, -24);
	self.healthbar.TextString:SetPoint('CENTER', self.healthbar, 'CENTER', 0, 0);
	self.manabar:SetPoint('TOPLEFT', 6, -52);
	
	self.name:SetPoint('LEFT', 15, 38)
	self.name:SetFont(src.font, src.font_size+1)
	self.name:SetShadowColor(0, 0, 0, 1)
	self.name:SetShadowOffset(1, -1)
	
	self.deadText:SetPoint('CENTER', self.healthbar, 'CENTER', 0, 0);
	self.deadText:SetFontObject('pUiFont')
	self.deadText:SetTextColor(1, 1, 1)
	
	TargetFrameBackground:SetPoint('TOPRIGHT', -107, -24)
	TargetFrameNumericalThreat:SetScale(uconfig.threatscale)
	if uconfig.threatplayer then
		TargetFrameNumericalThreat:SetPoint('BOTTOM', PlayerFrame, 'TOP', 75, -22)
	end
	
	if not uconfig.name then self.name:SetAlpha(0) end
	if not uconfig.leadericon then self.leaderIcon:SetAlpha(0) end
	if not uconfig.pvpicon then self.pvpIcon:SetAlpha(0) end
	if not uconfig.level then self.levelText:SetAlpha(0) end
end

-- /* FFA for target */
function __TargetFrame_CheckFaction(self)
	self.pvpIcon:SetTexture('Interface\\TargetingFrame\\UI-PVP-FFA')
end

hooksecurefunc('TargetFrame_CheckClassification',__TargetFrame_CheckClassification)
if config.global.FFA then
	hooksecurefunc('TargetFrame_CheckFaction',__TargetFrame_CheckFaction)
end