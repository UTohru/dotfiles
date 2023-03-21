local wezterm = require 'wezterm';

local shell;
local MODKEY = "SUPER"
local FONT_SIZE = 14
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	shell = {"wsl.exe"}
	MODKEY = "ALT"
	FONT_SIZE = 12
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
	return {{Text = ' ' .. tab.tab_index+1 .. ' '}}
end)


wezterm.on('update-right-status', function(window, pane)
	-- # see _shell/wezterm.sh
	
	local icons ={
		-- left = utf8.char(0xe0b6),
		left = utf8.char(0xe0b2),
		right = utf8.char(0xf054),
		user = utf8.char(0xf2be),
		host = utf8.char(0xf108),
		branch = utf8.char(0xe725),
	}

	local elements = {}
	-- push into elements
	function push(text, color, before_color)
		table.insert(elements, {Foreground = {Color = color }})
		table.insert(elements, {Background = {Color = before_color }})
		table.insert(elements, {Text = icons["left"] })
		table.insert(elements, {Foreground = {Color = "midnightblue" }})
		table.insert(elements, {Background = {Color = color }})
		table.insert(elements, {Text = ' ' .. text .. ' '})
	end

	local username = pane:get_user_vars().WEZTERM_USER
	local hostname = string.lower(pane:get_user_vars().WEZTERM_HOST)
	local dot = hostname:find '[.]'
	if dot then
		hostname = hostname:sub(1, dot -1)
	end
	local hostcolor = 'royalblue'
	local wezhost = string.lower(wezterm.hostname())
	if hostname ~= wezhost then
		hostcolor = 'blueviolet'
	end

	local cwd = pane:get_current_working_dir()
	local prev_color = 'none'
	if cwd then
		cwd = cwd:sub((cwd:sub(8): find '/'))
		if string.len(cwd) > 23 then
			cwd = '..' .. cwd:sub(-23)
		end
		push( cwd, 'lightsteelblue', prev_color)
		prev_color = 'lightsteelblue'
	end
	push(icons["user"] .. ' ' .. username, 'lightseagreen', prev_color)
	push(icons["host"] .. ' ' .. hostname, hostcolor, 'lightseagreen')

	window:set_right_status(wezterm.format(elements))
end)


return {
	default_prog = shell,
	-- exit_behavior = "Close",
	font = wezterm.font("Cica"),
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
		{key='t', mods=MODKEY, action=wezterm.action{SpawnTab="DefaultDomain"}},
		{key='h', mods=MODKEY, action=wezterm.action{ ActivateTabRelative = -1}},
		{key='l', mods=MODKEY, action=wezterm.action{ ActivateTabRelative =  1}},
		{key='h', mods=MODKEY.."|CTRL", action=wezterm.action{ MoveTabRelative = -1}},
		{key='l', mods=MODKEY.."|CTRL", action=wezterm.action{ MoveTabRelative =  1}},
		{key='v', mods="CTRL|SHIFT", action=wezterm.action{ PasteFrom =  "Clipboard"}},
		{key='c', mods="CTRL|SHIFT", action=wezterm.action{ CopyTo =  "ClipboardAndPrimarySelection"}},
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

