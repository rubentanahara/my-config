local wezterm = require("wezterm")

config = wezterm.config_builder()

config = {
	default_cursor_style = "SteadyBar",
	automatically_reload_config = true,
	window_close_confirmation = "NeverPrompt",
	adjust_window_size_when_changing_font_size = false,
	window_decorations = "RESIZE",
	check_for_updates = false,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = false,
	enable_tab_bar = false,
	window_padding = {
		left = 3,
		right = 3,
		top = 3,
		bottom = 3,
	},
	font_size = 14,
	font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular", stretch = "Normal", style = "Normal" }),
	color_scheme = "Material Darker (base16)",
}

return config
