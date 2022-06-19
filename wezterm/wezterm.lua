local wezterm = require 'wezterm';

local shell;
local MODKEY = "SUPER"
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	shell = {"wsl.exe"}
	MODKEY = "ALT"
end


return {
	default_prog = shell,
	exit_behavior = "Close",
	font = wezterm.font("Cica"),
	use_ime = true,
	-- treat_east_asian_ambiguous_width_as_wide = true,
	-- unicode_version = 14,
	font_size = 14,
	colors ={
		foreground = "#f6f3e8",
		background = "rgba(0,0,0,128)"
	},
	-- allow_square_glyphs_to_overflow_width = "Always",
	-- allow_square_glyphs_to_overflow_width = "Never",

	window_background_opacity = 0.5,
	hide_tab_bar_if_only_one_tab = true,
	
	-- disable_default_key_bindings = True,
	-- debug_key_events = true,
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

