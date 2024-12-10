local wezterm = require("wezterm")

config = wezterm.config_builder()

config = {
	automatically_reload_config = true,
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE", -- disable the title bar but enable the resizable border,
	default_cursor_style = "BlinkingBar",
	font_size = 14,
	font = wezterm.font("Hack Nerd Font Mono", {weight="Regular", stretch="Normal", style="Normal"}),
	window_padding = {
		left = 3,
		right = 3,
		top = 0,
		bottom = 0,
	}
}

return config
