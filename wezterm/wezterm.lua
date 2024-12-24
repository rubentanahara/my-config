local wezterm = require("wezterm")
local mux = wezterm.mux

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Color scheme and visual settings
config.color_scheme = "MaterialDarker"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 14
config.line_height = 1.1
config.text_background_opacity = 1.0
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.scrollback_lines = 10000
config.default_cursor_style = "BlinkingUnderline"
config.cursor_blink_rate = 800
config.animation_fps = 60

-- Window padding
config.window_padding = {
	left = "0.5cell",
	right = "0.5cell",
	top = "0cell",
	bottom = "0cell",
}

-- Background configuration
config.background = {
	{
		source = { Color = "#171616" },
		height = "100%",
		width = "100%",
	},
}

-- Tab bar configuration
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true

-- Workspace configuration
config.automatically_reload_config = true
config.adjust_window_size_when_changing_font_size = false

-- Startup configuration
wezterm.on("gui-startup", function(cmd)
	local window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return config
