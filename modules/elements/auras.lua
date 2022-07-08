local addon = select(2,...);
local config = addon.config.auras;
local src = addon.config.media;

--[[
/**
 * element: auras
 * contains style and functions of buffs and debuffs
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

-- /* lua lib */
local _G = _G
local select = select
local unpack = unpack
local strfind = string.find

-- /* WoW APIs */
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local GetName = GetName
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local hooksecurefunc = hooksecurefunc

-- /* locals */
local __TargetFrame_UpdateAuras
local __TargetFrame_UpdateAurasDispel
local __UpdateAuraPositions
local __UpdateBuffAnchor
local __UpdateDebuffAnchor
local __UpdateTargetAuraPositions
local __RefreshDebuffs

-- /* consts */
local BUFFS_SCALE = config.buffs_scale
local DEBUFFS_SCALE = config.debuffs_scale
local MAX_TARGET_BUFFS = 32
local MAX_TARGET_DEBUFFS = 16
local AURA_START_X = config.start_x
local AURA_START_Y = config.start_y
local AURA_OFFSET_X = config.offset_x
local AURA_OFFSET_Y = config.offset_y
local LARGE_AURA_SIZE = config.aura_size
local SMALL_AURA_SIZE = config.aura_size
local AURA_ROW_WIDTH = 25 * config.numrow
local NUM_TOT_AURA_ROWS = config.numrowtot
local DEBUFFS_VERTICAL = config.debuffs_vertical
local DEBUFFS_OFFSET_Y = config.debuffs_offset_y
local E_DEBUFFS_OFFSET_Y = config.e_debuffs_offset_y
local BORDER_OFFSET = config.border_offset
local partybuffs = addon.config.party
local MAX_PARTY_BUFFS = partybuffs.maxbuffs
local MAX_PARTY_DEBUFFS = 4 -- don't touch this
local texcoord = addon.texcoord
local maxshows

FocusFrame.maxBuffs = config.focus_maxbuffs
FocusFrame.maxDebuffs = config.focus_maxdebuffs
TargetFrame.maxBuffs = config.target_maxbuffs
TargetFrame.maxDebuffs = config.target_maxdebuffs
TargetFrame_UpdateAuras(TargetFrame)

-- /* create anchor frame */
local t_buffs = CreateFrame('Frame', 'TargetBuffs', UIParent)
local t_debuffs = CreateFrame('Frame', 'TargetDebuffs', UIParent)
t_buffs:SetSize(116, 28)
t_debuffs:SetSize(116, 28)

local f_buffs = CreateFrame('Frame', 'FocusBuffs', UIParent)
local f_debuffs = CreateFrame('Frame', 'FocusDebuffs', UIParent)
f_buffs:SetSize(146, 28)
f_debuffs:SetSize(146, 28)

-- /* create dispelable buffs border */
function __TargetFrame_UpdateAurasDispel(self)
	for i=1, MAX_TARGET_BUFFS do
		_, _, ic, _, debuffType = UnitBuff(self.unit, i)
		if(ic and (not self.maxBuffs or i<=self.maxBuffs)) then
			fic = _G[self:GetName()..'Buff'..i..'Icon']
			fs = _G[self:GetName()..'Buff'..i..'Stealable']
			fs:SetPoint('TOPRIGHT', fic, 3.4, 3.4)
			fs:SetPoint('BOTTOMLEFT', fic, -3.4, -3.4)
			fs:SetBlendMode('ADD')
			fs:SetDrawLayer('OVERLAY', 7)
			if(UnitIsEnemy(PlayerFrame.unit, self.unit) and debuffType == 'Magic') then fs:Show() else fs:Hide() end
		end
	end
end

-- /* create style buffs & debuffs */
function __TargetFrame_UpdateAuras(self)
	if maxshows then return end
	local frame, frameName
	local frameIcon, frameCount, frameCooldown
	local name, rank, icon, count, debuffType
	local color
	local frameBorder
	local selfName = _G[self:GetName()]
	if selfName:IsShown() then
		for i = 1, MAX_TARGET_BUFFS do
			frame = _G[self:GetName()..'Buff'..i]
			if (not frame) then break end
			if (not frame.styled) then
				frame:SetScale(BUFFS_SCALE)
				frame.styled = true
				-- icons:
				frameIcon = _G[self:GetName()..'Buff'..i..'Icon']
				if frameIcon then
					frameIcon:SetPoint('TOPLEFT', frame, 'TOPLEFT', 2, -2)
					frameIcon:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 2)
					frameIcon:SetTexCoord(unpack(texcoord))
				end
				-- border:
				local bo = frame:CreateTexture(nil, 'OVERLAY')
				if bo then
					bo:SetAllPoints()
					bo:SetTexture(src.border)
					bo:SetVertexColor(unpack(config.border_color))
				end
				-- count:
				frameCount = _G[self:GetName()..'Buff'..i..'Count']
				if frameCount then
					frameCount:SetJustifyH('CENTER')
					frameCount:SetFontObject('pUiFont_Auras')
					frameCount:SetDrawLayer('OVERLAY', 7)
				end
				-- cooldown:
				frameCooldown = _G[self:GetName()..'Buff'..i..'Cooldown']
				if frameCooldown then
					frameCooldown:ClearAllPoints()
					frameCooldown:SetPoint('TOPLEFT', frame, 1.5, -1.5)
					frameCooldown:SetPoint('BOTTOMRIGHT', frame, -1.5, 1.5)
					frameCooldown:SetFrameLevel(frame:GetFrameLevel())
				end
				if i == MAX_TARGET_BUFFS then
					maxshows = true
				end
			end
		end
		for i = 1, MAX_TARGET_DEBUFFS do
			frame = _G[self:GetName()..'Debuff'..i]
			if (not frame) then break end
			if (not frame.styled) then
				frame:SetScale(DEBUFFS_SCALE)
				frame.styled = true
				-- icons:
				frameIcon = _G[self:GetName()..'Debuff'..i..'Icon']
				if frameIcon then
					frameIcon:SetPoint('TOPLEFT', frame, 'TOPLEFT', 2, -2)
					frameIcon:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 2)
					frameIcon:SetTexCoord(unpack(texcoord))
				end
				-- border:
				local bo = frame:CreateTexture(nil, 'OVERLAY', nil, 7)
				if bo then
					bo:SetTexture(src.border)
					bo:SetAllPoints()
				end
				-- color:
				local debuffName = UnitDebuff(self.unit, i)
				_,_,_,_, debuffType = UnitDebuff(self.unit, i)
				if debuffName then
					color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
					frameBorder = _G[self:GetName()..'Debuff'..i..'Border']
					frameBorder:Hide()
					if color then
						bo:SetVertexColor(color.r, color.g, color.b)
					end
				else
					bo:SetVertexColor(unpack(config.border_color))
				end
				-- count:
				frameCount = _G[self:GetName()..'Debuff'..i..'Count']
				if frameCount then
					frameCount:SetJustifyH('CENTER')
					frameCount:SetFontObject('pUiFont_Auras')
					frameCount:SetDrawLayer('OVERLAY', 7)
				end
				-- cooldown:
				frameCooldown = _G[self:GetName()..'Debuff'..i..'Cooldown']
				if frameCooldown then
					frameCooldown:ClearAllPoints()
					frameCooldown:SetPoint('TOPLEFT', frame, 1.5, -1.5)
					frameCooldown:SetPoint('BOTTOMRIGHT', frame, -1.5, 1.5)
				end
				if i == MAX_TARGET_DEBUFFS then
					maxshows = true
				end
			end
		end
	end
end

-- /* style auras position */
function __UpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
	local size
	local offsetY = AURA_OFFSET_Y
	local offsetX = AURA_OFFSET_X
	local rowWidth = 0
	local firstBuffOnRow = 1
	for i=1, numAuras do
		if ( largeAuraList[i] ) then
			size = LARGE_AURA_SIZE
			offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y
		else
			size = SMALL_AURA_SIZE
		end
		if ( i == 1 ) then
			rowWidth = size
			self.auraRows = self.auraRows + 1
		else
			rowWidth = rowWidth + size + offsetX
		end
		if ( rowWidth > maxRowWidth ) then
			updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY, mirrorAurasVertically)
			rowWidth = size
			self.auraRows = self.auraRows + 1
			firstBuffOnRow = i
			offsetY = AURA_OFFSET_Y
			if ( self.auraRows > NUM_TOT_AURA_ROWS ) then
				maxRowWidth = AURA_ROW_WIDTH;
			end
		else
			updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY, mirrorAurasVertically)
		end
	end
end

function __UpdateBuffAnchor(self, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	local point, relativePoint
	local startY, auraOffsetY
	if ( mirrorVertically ) then
		point = 'BOTTOM'
		relativePoint = 'TOP'
		startY = -8
		offsetY = -offsetY
		auraOffsetY = -AURA_OFFSET_Y
	else
		point = 'TOP'
		relativePoint = 'BOTTOM'
		startY = AURA_START_Y
		auraOffsetY = AURA_OFFSET_Y -- debuffs
	end

	local buff = _G[buffName..index]
	if ( index == 1 ) then
		-- if ( UnitIsFriend('player', self.unit) or numDebuffs == 0 ) then
			-- unit is friendly or there are no debuffs...buffs start on top
			if (self.unit == 'target') then
				buff:ClearAllPoints()
				buff:SetPoint(point..'LEFT', t_buffs, relativePoint..'LEFT', AURA_START_X, startY)
			elseif (self.unit == 'focus') then
				buff:ClearAllPoints()
				buff:SetPoint(point..'LEFT', f_buffs, relativePoint..'LEFT', AURA_START_X, startY)
			else
				buff:SetPoint(point..'LEFT', self, relativePoint..'LEFT', AURA_START_X, startY)
			end
		-- else
			-- unit is not friendly and we have debuffs...buffs start on bottom
			-- buff:SetPoint(point..'LEFT', self.debuffs, relativePoint..'LEFT', 0, -offsetY)
		-- end
		self.buffs:SetPoint(point..'LEFT', buff, point..'LEFT', 0, 0)
		self.buffs:SetPoint(relativePoint..'LEFT', buff, relativePoint..'LEFT', 0, -auraOffsetY)
		self.spellbarAnchor = buff
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint(point..'LEFT', _G[buffName..anchorIndex], relativePoint..'LEFT', 0, -offsetY)
		self.buffs:SetPoint(relativePoint..'LEFT', buff, relativePoint..'LEFT', 0, -auraOffsetY)
		self.spellbarAnchor = buff
	else
		-- anchor index is the previous index
		buff:SetPoint(point..'LEFT', _G[buffName..anchorIndex], point..'RIGHT', offsetX, 0)
	end
end

function __UpdateDebuffAnchor(self, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	local buff = _G[debuffName..index];
	local isFriend = UnitIsFriend('player', self.unit);

	-- For mirroring vertically
	local point, relativePoint;
	local startY, auraOffsetY;
	mirrorVertically = DEBUFFS_VERTICAL
	if ( mirrorVertically ) then
		point = 'TOP'
		relativePoint = 'TOP'
		startY = AURA_START_Y
		offsetY = -offsetY * DEBUFFS_OFFSET_Y
		auraOffsetY = AURA_OFFSET_Y
	else
		point = 'TOP';
		relativePoint = 'BOTTOM';
		startY = AURA_START_Y;
		auraOffsetY = AURA_OFFSET_Y;
	end

	if ( index == 1 ) then
		-- if ( isFriend and numBuffs > 0 ) then
			-- unit is friendly and there are buffs...debuffs start on bottom
			if (self.unit == 'target') then
				buff:SetPoint(point..'LEFT', t_debuffs, relativePoint..'LEFT', AURA_START_X, startY);
			elseif (self.unit == 'focus') then
				buff:SetPoint(point..'LEFT', f_debuffs, relativePoint..'LEFT', AURA_START_X, startY);
			else
				buff:SetPoint(point..'LEFT', self, relativePoint..'LEFT', AURA_START_X, startY);
			end
		-- else
			-- unit is not friendly or there are no buffs...debuffs start on top
			-- if (self.unit == 'target') then
				-- buff:SetPoint(point..'LEFT', t_debuffs, relativePoint..'LEFT', AURA_START_X, startY);
			-- else
				-- buff:SetPoint(point..'LEFT', self, relativePoint..'LEFT', AURA_START_X, startY);
			-- end
		-- end
		self.debuffs:SetPoint(point..'LEFT', buff, point..'LEFT', 0, 0);
		self.debuffs:SetPoint(relativePoint..'LEFT', buff, relativePoint..'LEFT', 0, -auraOffsetY);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint(point..'LEFT', _G[debuffName..anchorIndex], relativePoint..'LEFT', 0, E_DEBUFFS_OFFSET_Y);
		self.debuffs:SetPoint(relativePoint..'LEFT', buff, relativePoint..'LEFT', 0, -auraOffsetY);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
	else
		-- anchor index is the previous index
		buff:SetPoint(point..'LEFT', _G[debuffName..(index-1)], point..'RIGHT', offsetX, 0);
	end
end

function __UpdateTargetAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX)
	local AURA_OFFSET_Y = 3;
	local LARGE_AURA_SIZE = 30;
	local SMALL_AURA_SIZE = 21;
	local size;
	local offsetY = AURA_OFFSET_Y;
	local rowWidth = 0;
	local firstBuffOnRow = 1;
	for i=1, numAuras do
		if ( largeAuraList[i] ) then
			size = LARGE_AURA_SIZE;
			offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y;
		else
			size = SMALL_AURA_SIZE;
		end
		if ( i == 1 ) then
			rowWidth = size;
			self.auraRows = self.auraRows + 1;
		else
			rowWidth = rowWidth + size + offsetX;
		end
		if ( rowWidth > AURA_ROW_WIDTH ) then
			updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY);
			rowWidth = size;
			self.auraRows = self.auraRows + 1;
			firstBuffOnRow = i;
			offsetY = AURA_OFFSET_Y;
		else
			updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY);
		end
	end;
end;

-- /* create auras for party */
local function CreatePartyAuras()
	local i;
	for i = 1,4,1 do
		local party = 'PartyMemberFrame'..i;
		local buffs;
		local debuffs;
		local icn, bo, oldborder;
		if not party then break end
		-- buffs:
		for j = 1, MAX_PARTY_BUFFS, 1 do
			buffs = CreateFrame('Button', party..'Buff'..j, _G[party], 'PartyBuffFrameTemplate');
			buffs:SetID(j);
			buffs:SetScale(partybuffs.buffs_scale)
			buffs:ClearAllPoints();
			if j == 1 then
				buffs:SetPoint('TOPLEFT', party, 'TOPLEFT', 24, -20);
			else
				buffs:SetPoint('LEFT', party..'Buff'..j-1, 'RIGHT', -1, 0);
			end;
			if (not buffs.styled) then
				-- icon:
				icn = _G[buffs:GetName()..'Icon']
				if icn then
					icn:SetPoint('TOPLEFT', buffs, 'TOPLEFT', 2, -2)
					icn:SetPoint('BOTTOMRIGHT', buffs, 'BOTTOMRIGHT', -2, 2)
					icn:SetTexCoord(unpack(texcoord))
				end
				-- border:
				bo = buffs:CreateTexture(nil, 'OVERLAY', nil, 7)
				if bo then
					bo:SetTexture(src.border)
					bo:SetAllPoints()
					bo:SetVertexColor(unpack(config.border_color))
				end
				buffs.styled = true
			end
		end
		
		-- debuffs first row:
		for k = 1, MAX_PARTY_DEBUFFS, 1 do
			debuffs = _G[party..'Debuff'..k];
			if not partybuffs.show_debuffs then debuffs:SetAlpha(0); return end
			debuffs:SetScale(partybuffs.debuffs_scale)
			debuffs:SetFrameLevel(1)
			debuffs:ClearAllPoints();
			if (k == 1) then
				debuffs:SetPoint('TOPLEFT', party, 'TOPLEFT', 74, -6)
			else
				debuffs:SetPoint('LEFT', _G[party..'Debuff'..(k-1)], 'RIGHT', -1, 0)
			end
			if not debuffs.styled then
				-- icon:
				icn = _G[debuffs:GetName()..'Icon']
				if icn then
					icn:SetPoint('TOPLEFT', debuffs, 'TOPLEFT', 2, -2)
					icn:SetPoint('BOTTOMRIGHT', debuffs, 'BOTTOMRIGHT', -2, 2)
					icn:SetTexCoord(unpack(texcoord))
				end
				-- border:
				bo = debuffs:CreateTexture(nil, 'OVERLAY', nil, 7)
				if bo then
					bo:SetTexture(src.border)
					bo:SetAllPoints()
				end
				-- color:
				oldborder = _G[debuffs:GetName()..'Border']
				oldborder:Hide()
				bo:SetVertexColor(1, 0, 0)
				debuffs.styled = true
			end
		end
	end
end

-- /* hide buffinfo tooltip */
__PartyMemberBuffTooltip_Update = PartyMemberBuffTooltip_Update;
PartyMemberBuffTooltip_Update = function(self)
	if not partybuffs.show_buffs then
		__PartyMemberBuffTooltip_Update(self)
	end
	return;
end

-- /* hook func is safe to call */
function __RefreshDebuffs(frame, unit, numDebuffs, suffix, checkCVar)
	local frameName = frame:GetName();
	numDebuffs = numDebuffs or 4;
	if strfind(frameName, '^PartyMemberFrame%d$') then
		if partybuffs.show_buffs then
			RefreshBuffs(frame, unit, MAX_PARTY_BUFFS);
		end
	end
end

-- /* setup module */
CreatePartyAuras()
hooksecurefunc('RefreshDebuffs',__RefreshDebuffs)
hooksecurefunc('TargetFrame_UpdateAuras',__TargetFrame_UpdateAuras)
if config.dispelable then hooksecurefunc('TargetFrame_UpdateAuras',__TargetFrame_UpdateAurasDispel) end
hooksecurefunc('TargetFrame_UpdateAuraPositions',__UpdateAuraPositions)
hooksecurefunc('TargetFrame_UpdateBuffAnchor',__UpdateBuffAnchor)
hooksecurefunc('TargetFrame_UpdateDebuffAnchor',__UpdateDebuffAnchor)