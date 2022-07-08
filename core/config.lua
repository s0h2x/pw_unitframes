local addon = select(2,...);
local path = [[Interface\AddOns\pw_unitframes\assets\]];

--[[
/**
 * config
 * contains main settings of addon
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

local config = {

	-- general settings:
	global = {
		classportraits = true, -- enable portraits by class
		prettyportraits = true, -- display custom portraits
		framecolors = {.22, .22, .22, 1}, -- main colors theme of frames
		combaticon = true, -- display combat state
		castbar_show = true, -- enable castbar style
		castbar_scale = 1.2, -- castbar scale
		castbar_icon_color = {.2, .2, .2, 1}, -- castbar icon border color
		FFA = true, -- show FFA status icon for all frames
	},
	
	-- buffs & debuffs:
	auras = {
		-- size:
		aura_size = 26, -- aura size
		font_size = 14, -- base font size
		buffs_scale = 1.16, -- buffs scale
		debuffs_scale = 1.16, -- debuffs scale
		
		-- cooldown timer:
		cooldown_show = true, -- show cooldown timer text
		cooldown_module = true, -- enable cooldown module (its global)
		minscale = .6, -- get optimal UIScale for showing cooldown (if UIScale < minscale = hide cooldown text)
		minduration = 3, -- minimum duration to show cooldown text (trigger)
		threshold = 6.5, -- last seconds (red)
		duration_color = {1, .7, 0}, -- text color of duration > threshold (yellow by default)
		threshold_color = {1, 0, 0}, -- text color of duration < threshold (red by default)
		timer_y = 4, -- cooldown text position by y-axis (TOP by default)
		
		-- position:
		start_x = 1, -- auras start position by x-axis (buffs)
		start_y = 26, -- auras start position by y-axis (buffs)
		offset_x = -1, -- spacing between auras by x-axis
		offset_y = 3, --  spacing between auras by y-axis
		numrow = 5, -- how many auras to show in one row (second line) 5 = 4x4x4
		numrowtot = 2, -- space in buffs row, if target has of target (4 = only first row, 5 = first and second row)
		debuffs_vertical = true, -- vertical growth (from bottom to top)
		debuffs_offset_y = 5, -- vertical growth offset between debuffs
		e_debuffs_offset_y = 30, -- vertical growth offset between debuffs on enemy frame
		
		-- maximum number of buffs/debuffs:
		target_maxbuffs = 12, -- max buffs show, recommended to set value between 8-16
		target_maxdebuffs = 12, -- default: 16, recommended to set value between 8-16
		focus_maxbuffs = 12,
		focus_maxdebuffs = 12,
		
		-- misc:
		dispelable = true, -- glowing dispelable buffs
		border_color = {.3, .3, .3, 1}, -- border colors for buffs and some debuffs (R, G, B, Alpha)
	},
	
	-- player frame:
	player = {
		scale = 1.08, -- player scale
		elite = true, -- make yourself an elite
		level = false, -- show player level
		leadericon = false, -- show player leader icon
		name = true, -- show player name
		petname = false, -- show pet name
		runescale = 1.15, -- deathknight rune orbs scale
		runeanchor = {'TOP', PlayerFrame, 'BOTTOM', 54, 43}, -- default position for runebars
	},
	
	-- target frame:
	target = {
		scale = 1.08, -- target scale
		level = false, -- show target level
		leadericon = false, -- show target leader icon
		pvpicon = true, -- show target pvp icon
		name = true, -- show target name
		threatscale = 1, -- threat aggro scale
		threatplayer = true, -- show threat on player frame
	},
	
	-- focus frame:
	focus = {
		scale = 1, -- focus scale
		level = false, -- show focus level
		leadericon = false, -- leader icon
		name = true, -- show focus name
		threatscale = 1, -- threat aggro scale
		fk = true, -- enable hotkey macro mode
		modbutton = 'shift', -- shift, alt, ctrl
		mousebutton = '1',	 -- 1 = left, 2 = right, 3 = middle, 4 and 5 = thumb buttons if there are any
	},
	
	-- arena frame:
	arena = {
		enable = true, -- show arena enemys frames
		scale = 1.6, -- arena scale
		name = true, -- show arena enemys name
		trinkets = true, -- show arena trinkets
		trinket_announce = true, -- enable trinket announce
		announce_chat = 'PARTY', -- trinket announce chat type
		-- text announce:
		text_trinket = 'Use Trinket!', -- Enemyname (Class): Use Trinket!
		text_wotf = 'Use WotF!',
		textstring_size = 8, -- text font size of health and mana bars
		textcast_size = 7, -- text font size of castbar spell name
	},
	
	-- party frames:
	party = {
		-- general:
		enable = true, -- show party member frames
		scale = 1.26, -- party members scale
		
		-- castbar:
		castbar_scale = 1.07, -- castbar scale
		castbar_width = 125, -- castbar width
		castbar_height = 10, -- castbar height
		
		-- auras:
		show_buffs = true, -- show party buffs
		show_debuffs = true, -- show party debuffs
		maxbuffs = 4, -- how many buffs to show
		buffs_scale = 1.8, -- party buffs scale
		debuffs_scale = 1.64, -- party debuffs scale
	},
	
	-- target of targets:
	targettarget = {
		scale = 1.16, -- scale for target of target and focus target
		squarestyle = false, -- enable square style for target of targets
		partytargets = true, -- show party targets
		arenatargets = true, -- show arena targets
		partytarget_scale = 0.9, -- party target scale
		arenatarget_scale = 0.6, -- arena target scale
	},
	
	media = {
		-- assets:
		statusbar = path..'beige.tga', -- main statusbar texture theme
		targetFrame = path..'UI-TargetingFrame', -- player, target, focus texture
		targetElite = path..'UI-TargetingEliteFrame', -- elite texture
		targetTargetNormal = path..'TargetOfTarget', -- target of target normal
		targetTargetSquare = path..'TargetOfTargetSquare.tga', -- target of target square style
		partyFrame = path..'UI-PartyFrame', -- party frame texture
		border = path..'Border.tga', -- main auras border texture
		trinket_border = path..'units_trinket_border', -- trinket border
		dualweild = path..'dualwield01.tga', -- combat icon
		portraits = path..'UI-Classes-Circles', -- my custom portraits ^__^
		castborder = path..'UI-CastingBar-Border-Small', -- main castbar border texture
		castflash = path..'UI-CastingBar-Flash-Small', -- main castbar flash texture
		castshield = path..'UI-CastingBar-Small-Shield', -- castbar non-interrupt texture
		-- font:
		font = path..'normal.ttf', -- main font theme
		font_style = '', -- OUTLINE
		font_size = 14, -- font size
		font_offset = 1, -- font shadow offset
	},
}

addon.config = config