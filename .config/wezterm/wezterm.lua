local wezterm = require 'wezterm';

local shell;
local MODKEY = "SUPER"
local FONT_SIZE = 14
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	shell = {"wsl.exe", "~"}
	MODKEY = "ALT"
	FONT_SIZE = 12
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
	return {{Text = ' ' .. tab.tab_index+1 .. ' '}}
end)


wezterm.on('update-right-status', function(window, pane)
	-- # see _shell/wezterm.sh
	
	local icons ={
		left = utf8.char(0xe0b2),
		right = utf8.char(0xf054),
		user = utf8.char(0xf2be),
		host = utf8.char(0xf108),
		branch = utf8.char(0xe725),
	}
	local colors ={
		host = "royalblue",
		remote_host = "magenta",
		user = "darkturquoise",
		cwd = "limegreen",
		-- FG
		text = "midnightblue"
	}

	local elements = {}
	-- push into elements
	function push(text, color, prev_color)
		table.insert(elements, {Foreground = {Color = color }})
		table.insert(elements, {Background = {Color = prev_color }})
		table.insert(elements, {Text = icons["left"] })
		table.insert(elements, {Foreground = {Color = colors["text"] }})
		table.insert(elements, {Background = {Color = color }})
		table.insert(elements, {Text = ' ' .. text .. ' '})
	end

	local username = pane:get_user_vars().WEZTERM_USER
	local hostname = string.lower(pane:get_user_vars().WEZTERM_HOST)
	local dot = hostname:find '[.]'
	local hostcolor = colors["host"]
	local wezhost = string.lower(wezterm.hostname())

	if dot then
		hostname = hostname:sub(1, dot -1)
	end
	dot = wezhost:find '[.]'
	if dot then
		wezhost = wezhost:sub(1, dot -1)
	end
	if hostname ~= wezhost then
		hostcolor = colors["remote_host"]
	end

	local cwd = pane:get_current_working_dir()
	if cwd then
		cwd = cwd:sub((cwd:sub(8):find '/') + 7)
		local cdir_size = 20
		if string.len(cwd) > cdir_size then
			cwd = '..' .. cwd:sub(-cdir_size)
		end
		push( cwd, colors["cwd"], 'none')
	end
	push(icons["user"] .. ' ' .. username, colors["user"], colors["cwd"])
	push(icons["host"] .. ' ' .. hostname, hostcolor, colors["user"])

	window:set_right_status(wezterm.format(elements))
end)


return {
	default_prog = shell,
	-- exit_behavior = "Close",
	font = wezterm.font_with_fallback({
			{ family = "Cica" },
			{ family = "Cica", assume_emoji_presentation = true },
	}),
	use_ime = true,
	ime_preedit_rendering = "Builtin",
	-- disable_default_key_bindings = True,
	-- debug_key_events = true,


	font_size = FONT_SIZE,
	-- unicode_version = 14,
	-- treat_east_asian_ambiguous_width_as_wide = true,
	-- allow_square_glyphs_to_overflow_width = "Always",
	-- allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace",
	adjust_window_size_when_changing_font_size = false,

	window_padding = {
		top = 0,
		bottom = 0,
		left = 1,
		right = 0,
	},
	
	-- style:  {Steady, Blink} , {Block, Underline, Bar}
	default_cursor_style = 'SteadyUnderline',
	animation_fps = 1,
	cursor_blink_ease_in = 'Constant',
	cursor_blink_ease_out = 'Constant',
	cursor_blink_rate = 0,

	-- hide_tab_bar_if_only_one_tab = true,
	tab_bar_at_bottom = true,
	-- tab bar font
	use_fancy_tab_bar = false,

	-- color candidate { 'Dracula', 'Neon (terminal.sexy)', 'Pro Light' }
	color_scheme = "Pro Light",

	colors ={
		cursor_bg='aquamarine',
		cursor_fg='gray',
		cursor_border='skyblue',
		foreground = "white",
		background = "rgba(0,0,0,128)",
		selection_fg = 'black',
		selection_bg = 'lightgray',
		tab_bar = {
			background = 'none',
			active_tab = {
				bg_color = 'lightgray',
				fg_color = 'black',
			},
			inactive_tab = {
				fg_color = 'gray',
				bg_color = 'none',
			},
		},
	},
	window_background_opacity = 0.5,

	
	keys = {
		-- PANE
		{key='-', mods=MODKEY, action=wezterm.action{ SplitVertical = {domain = "CurrentPaneDomain"} }},
		{key='|', mods=MODKEY.."|SHIFT", action=wezterm.action{ SplitHorizontal = {domain = "CurrentPaneDomain"} }},
		{key='h', mods=MODKEY, action=wezterm.action{ ActivatePaneDirection = 'Left' }},
		{key='l', mods=MODKEY, action=wezterm.action{ ActivatePaneDirection = 'Right' }},
		{key='j', mods=MODKEY, action=wezterm.action{ ActivatePaneDirection = 'Down' }},
		{key='k', mods=MODKEY, action=wezterm.action{ ActivatePaneDirection = 'Up' }},
		{key='h', mods=MODKEY.."|SHIFT", action=wezterm.action{ AdjustPaneSize = {'Left', 1 }}},
		{key='l', mods=MODKEY.."|SHIFT", action=wezterm.action{ AdjustPaneSize = {'Right', 1}}},
		{key='j', mods=MODKEY.."|SHIFT", action=wezterm.action{ AdjustPaneSize = {'Down', 1 }}},
		{key='k', mods=MODKEY.."|SHIFT", action=wezterm.action{ AdjustPaneSize = {'Up', 1 }}},

		-- WINDOW (TAB)
		{key='t', mods=MODKEY.."|CTRL", action=wezterm.action{SpawnTab="DefaultDomain"}},
		{key='h', mods=MODKEY.."|CTRL", action=wezterm.action{ ActivateTabRelative = -1}},
		{key='l', mods=MODKEY.."|CTRL", action=wezterm.action{ ActivateTabRelative =  1}},

		-- CLIP
		{key='v', mods="CTRL|SHIFT", action=wezterm.action{ PasteFrom =  "Clipboard"}},
		{key='c', mods="CTRL|SHIFT", action=wezterm.action{ CopyTo =  "ClipboardAndPrimarySelection"}},

		-- OTHER
		--  Press CTRL|SHIFT to use
		{key='_', mods="CTRL", action="DisableDefaultAssignment"},
		{key='-', mods="CTRL", action="DisableDefaultAssignment"},
		-- {key='/', mods="CTRL", action="Nop"},
	},

	-- disable_default_mouse_bindings = true,
	mouse_bindings = {
		{
			event={ Up = { streak=1, button="Middle" } },
			mods = "NONE",
			action = wezterm.action({ CompleteSelection = "PrimarySelection" }),
		},
		{
			event={ Up = { streak=1, button="Right" }},
			mods = "NONE",
			action = wezterm.action({ CompleteSelection = "Clipboard" }),
		},
		{
			event={ Up = { streak=1, button="Left" }},
			mods = "NONE",
			action = wezterm.action{CompleteSelection="PrimarySelection"},
		},
		{
			event={ Up = { streak=1, button="Left" }},
			mods = "CTRL",
			action = "OpenLinkAtMouseCursor",
		},
	}
}

