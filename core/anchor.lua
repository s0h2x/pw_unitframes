local addon = select(2,...);
local event_ = addon:package()

-- /* lua lib */
local unpack = unpack
local pairs = pairs
local wipe = wipe
local print = print
local table = addon.table

-- /* WoW APIs */
local GetEffectiveScale = GetEffectiveScale
local StaticPopup_Show = StaticPopup_Show
local InCombatLockdown = InCombatLockdown
local UIErrorsFrame = UIErrorsFrame
local UIParent = UIParent
local CreateFrame = CreateFrame

-- /* consts */
local CANCEL = CANCEL
local LOCK = LOCK
local OKAY = OKAY
local RESET = RESET
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local istoggle = false
local secure = true

-- /* create screen shade */
local shadeFrame = CreateFrame('Frame')
local shadeTexture = shadeFrame:CreateTexture(nil, 'BACKGROUND', nil, -8)
shadeFrame:SetFrameStrata('BACKGROUND')
shadeFrame:SetWidth(GetScreenWidth() * UIParent:GetEffectiveScale())
shadeFrame:SetHeight(GetScreenHeight() * UIParent:GetEffectiveScale())
shadeTexture:SetAllPoints(shadeFrame)
shadeFrame:SetPoint('CENTER', 0, 0)

-- /* create screen crosshair */
local crosshairFrameNS = CreateFrame('Frame')
local crosshairTextureNS = crosshairFrameNS:CreateTexture(nil, 'TOOLTIP')
crosshairFrameNS:SetFrameStrata('TOOLTIP')
crosshairFrameNS:SetWidth(1)
crosshairFrameNS:SetHeight(GetScreenHeight() * UIParent:GetEffectiveScale())
crosshairTextureNS:SetAllPoints(crosshairFrameNS)
crosshairTextureNS:SetTexture(0, 0, 0, 1)

local crosshairFrameEW = CreateFrame('Frame')
local crosshairTextureEW = crosshairFrameEW:CreateTexture(nil, 'TOOLTIP')
crosshairFrameEW:SetFrameStrata('TOOLTIP')
crosshairFrameEW:SetWidth(GetScreenWidth() * UIParent:GetEffectiveScale())
crosshairFrameEW:SetHeight(1)
crosshairTextureEW:SetAllPoints(crosshairFrameEW)
crosshairTextureEW:SetTexture(0, 0, 0, 1)

-- /* setup screen align */
local function clear()
	shadeFrame:Hide()
	crosshairFrameNS:Hide()
	crosshairFrameEW:Hide()
end

local function shade(r, g, b, a)
	shadeTexture:SetTexture(r, g, b, a)
	shadeFrame:Show()
end

local function follow()
	local mouseX, mouseY = GetCursorPosition()
	crosshairFrameNS:SetPoint('TOPLEFT', mouseX, 0)
	crosshairFrameEW:SetPoint('BOTTOMLEFT', 0, mouseY)
end

local function crosshair(arg)
	local mouseX, mouseY = GetCursorPosition()
	crosshairFrameNS:SetPoint('TOPLEFT', mouseX, 0)
	crosshairFrameEW:SetPoint('BOTTOMLEFT', 0, mouseY)
	crosshairFrameNS:Show()
	crosshairFrameEW:Show()
	if (arg == 'follow') then
		crosshairFrameNS:SetScript('OnUpdate', follow)
	else
		crosshairFrameNS:SetScript('OnUpdate', nil)
	end
end

-- /* create mover elements */
local anchorlist, backup, f = {}, {}
local function create_anchor(self, text, value, anchor, width, height)
	local key = 'elements_anchor'
	if not _appdata[key] then _appdata[key] = {} end

	-- setup frame
	local mover = CreateFrame('Frame', nil, UIParent)
	mover:SetWidth(width or self:GetWidth())
	mover:SetHeight(height or self:GetHeight())
	mover:SetBackdrop(addon.backdrop)
	mover:SetBackdropColor(0.67058823529, 0.80392156862, 0.93725490196, .65)
	mover:SetBackdropBorderColor(0, 1, .62, .5)

	-- setup name
	mover.text = mover:CreateFontString(nil, 'OVERLAY', 'pUiFont')
	mover.text:SetPoint('CENTER', 0, 2)
	mover.text:SetTextColor(1, .8, 0)
	mover.text:SetText(text)

	tinsert(anchorlist, mover)

	if not _appdata[key][value] then
		mover:SetPoint(unpack(anchor))
	else
		mover:SetPoint(unpack(_appdata[key][value]))
	end
	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:SetFrameStrata('HIGH')
	mover:RegisterForDrag('LeftButton')
	mover:SetScript('OnDragStart', function() mover:StartMoving() end)
	mover:SetScript('OnDragStop', function()
		mover:StopMovingOrSizing()
		local orig, _, tar, x, y = mover:GetPoint()
		_appdata[key][value] = {orig, 'UIParent', tar, x, y}
	end)
	mover:Hide()

	self:ClearAllPoints()
	self:SetPoint('CENTER', mover, 'CENTER')

	return mover
end

-- /* create mover options */
local function unlock_elements()
	for i = 1, #anchorlist do
		local mover = anchorlist[i]
		if (not mover:IsShown()) then
			mover:Show()
		end
	end
	table.copy(_appdata['elements_anchor'], backup)
	f:Show()
end

local function lock_elements()
	for i = 1, #anchorlist do
		local mover = anchorlist[i]
		mover:Hide()
	end
	
	f:Hide()
	istoggle = false
	clear()
end

-- /* setup mover settings */
StaticPopupDialogs['PRETTY_MOVER_RESET'] = {
	text = 'Are you sure to reset all frames position?',
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		wipe(_appdata['elements_anchor'])
		ReloadUI()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 5,
}

StaticPopupDialogs['PRETTY_MOVER_CANCEL'] = {
	text = 'Are you sure to reverse your positioning?',
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		table.copy(backup, _appdata['elements_anchor'])
		ReloadUI()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 5,
}

-- /* create mover console */
local function createconsole()
	if f then return end
	
	f = CreateFrame('Frame', nil, UIParent)
	f:SetPoint('TOP', 0, -150)
	f:SetSize(296, 65)
	f:SetBackdrop(addon.backdrop)
	f:SetBackdropColor(0, 0, 0, .7)
	f:SetBackdropBorderColor(1, .71, 0, .4)
	addon.console_anchor(f)
	
	f.text = f:CreateFontString(nil, 'OVERLAY', 'pUiFont')
	f.text:SetPoint('TOP', 0, -10)
	f.text:SetText('Console')
	
	-- setup buttons
	local bu, text = {}, {LOCK, CANCEL, 'Grid', RESET}
	for i = 1, 4 do
		bu[i] = CreateFrame('Button', nil, f)
		bu[i]:SetSize(70, 28)

		if i==1 then
			bu[i]:SetPoint('BOTTOMLEFT', 5, 5)
		else
			bu[i]:SetPoint('LEFT', bu[i-1], 'RIGHT', 2, 0)
		end
		
		bu.text = bu[i]:CreateFontString(nil, 'OVERLAY')
		bu.text:SetFontObject('pUiFont')
		bu.text:SetPoint('TOP', 0, -10)
		bu.text:SetText(text[i])
	end

	-- create lock button
	bu[1]:SetScript('OnClick', lock_elements)
	
	-- create cancel button
	bu[2]:SetScript('OnClick', function()
		StaticPopup_Show('PRETTY_MOVER_CANCEL')
	end)
	
	-- create grids button
	bu[3]:SetScript('OnClick', function()
		if not istoggle then
			istoggle = true
			shade(1, 1, 1, .85)
			crosshairTextureNS:SetTexture(0, 0, 0, 1)
			crosshairTextureEW:SetTexture(0, 0, 0, 1)
			crosshair('follow')
		else
			istoggle = false
			clear()
		end
	end)
	
	-- create reset button
	bu[4]:SetScript('OnClick', function()
		StaticPopup_Show('PRETTY_MOVER_RESET')
	end)
end

-- /* create secure toggle function */
function event_:PLAYER_REGEN_DISABLED()
	addon:toggle_anchors(true)
end

function addon:toggle_anchors(forcelock)
	if secure and not forcelock then
		if self:taint() then
			return UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT)
		end
		event_:RegisterEvent('PLAYER_REGEN_DISABLED')
		createconsole()
		unlock_elements()
	elseif not secure then
		if f and f:IsShown() then
			lock_elements()
		end
		event_:UnregisterEvent('PLAYER_REGEN_DISABLED')
	end
	
	secure = not secure
	return secure
end

SlashCmdList['PRETTY_MOVER'] = function(...)
	addon:toggle_anchors()
end
SLASH_PRETTY_MOVER1 = '/mover'

addon.c_anchor = create_anchor