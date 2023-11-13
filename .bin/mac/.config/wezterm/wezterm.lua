local wezterm = require("wezterm")
return {
	-- font
	font = wezterm.font_with_fallback({
		{ family = "HackGen Console NF", weight = "Regular" },
	}),
	font_size = 16.0,

	-- window
	window_background_opacity = 0.8,
	initial_rows = 100,
	initial_cols = 400,

	-- theme
	color_scheme = "zenbones_dark",

	-- tab bar
	use_fancy_tab_bar = false,
	colors = {
		cursor_bg = "#c6c8d1",
		tab_bar = {
			background = "#1b1f2f",

			active_tab = {
				bg_color = "#444b71",
				fg_color = "#c6c8d1",
				intensity = "Normal",
				underline = "None",
				italic = false,
				strikethrough = false,
			},

			inactive_tab = {
				bg_color = "#282d3e",
				fg_color = "#c6c8d1",
				intensity = "Normal",
				underline = "None",
				italic = false,
				strikethrough = false,
			},

			new_tab = {
				bg_color = "#1b1f2f",
				fg_color = "#c6c8d1",
				italic = false,
			},
		},
	},

	-- key
	keys = {
		{ key = "Tab", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
		{ key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
		{ key = "w", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
	},
}
