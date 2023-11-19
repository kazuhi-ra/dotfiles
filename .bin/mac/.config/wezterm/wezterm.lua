local wezterm = require("wezterm")
return {
	-- font
	font = wezterm.font_with_fallback({
		{ family = "HackGen Console NF", weight = "Regular" },
	}),
	font_size = 16.0,

	-- window
	initial_rows = 100,
	initial_cols = 400,
	hide_tab_bar_if_only_one_tab = true,

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
		{ key = "q", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },

		-- session の作成, 移動
		{ key = "t", mods = "CMD|SHIFT", action = wezterm.action.SendString("\027T") },
		{ key = "j", mods = "CMD", action = wezterm.action.SendString("\027j") },
		{ key = "k", mods = "CMD", action = wezterm.action.SendString("\027k") },

		-- window の作成, 移動
		{ key = "t", mods = "CMD", action = wezterm.action.SendString("\027t") },
		{ key = "h", mods = "CMD", action = wezterm.action.SendString("\027h") },
		{ key = "l", mods = "CMD", action = wezterm.action.SendString("\027l") },

		-- kill
		{ key = "w", mods = "CMD", action = wezterm.action.SendString("\027w") },
		{ key = "q", mods = "CMD", action = wezterm.action.SendString("\027q") },
	},
}
