local wezterm = require 'wezterm';

local shell;
local MODKEY = "SUPER"
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	shell = {"wsl.exe"}
	MODKEY = "ALT"
end


return {
	default_prog = shell,
	-- exit_behavior = "Close",
	font = wezterm.font("Cica"),
	use_ime = true,
	ime_preedit_rendering = "Builtin",
	-- disable_default_key_bindings = True,
	-- debug_key_events = true,


	font_size = 14,
	-- unicode_version = 14,
	-- treat_east_asian_ambiguous_width_as_wide = true,
	-- allow_square_glyphs_to_overflow_width = "Always",
	-- allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace",
	adjust_window_size_when_changing_font_size = false,
	--
	
	
	animation_fps = 1,

	cursor_blink_ease_in = 'Constant',
	cursor_blink_ease_out = 'Constant',
	cursor_blink_rate = 800,

	use_fancy_tab_bar = false,


	colors ={
		cursor_bg='gray',
		cursor_fg='silver',
		foreground = "#f6f3e8",
		background = "rgba(0,0,0,128)"
	},

	-- color_scheme = 'Dracula',
	-- color_scheme = "Neon (terminal.sexy)",
	-- color_scheme = "iceberg-dark",
	color_scheme = "Pro Light",
	


	window_background_opacity = 0.5,
	hide_tab_bar_if_only_one_tab = true,
	
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

