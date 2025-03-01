local wezterm = require("wezterm")
local mux = wezterm.mux

-- Initialize the configuration
local config = {}

-- Apply configuration using the config_builder if available
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- ============================
-- Color Scheme and Visual Settings
-- ============================
config.color_scheme = "MaterialDarker"
-- Uncomment the line below to use an alternative color scheme
-- config.color_scheme = "rose-pine"

config.colors = {
  cursor_bg = "#9B96B5",
  cursor_fg = "#1a1a1e",
  cursor_border = "#9B96B5",
}

-- config.font = wezterm.font('FiraCode Nerd Font Mono', { weight = "Regular" })
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.automatically_reload_config = true
config.font_size = 14
config.line_height = 1.2
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.harfbuzz_features = { "calt=0" }
config.window_close_confirmation = "NeverPrompt"
config.default_cursor_style = "SteadyBar"
config.scrollback_lines = 5000 -- Updated from 10000 to 5000 for consistency
config.default_cursor_style = "BlinkingUnderline"
config.cursor_blink_rate = 800
config.max_fps = 120
config.animation_fps = 120
config.front_end = "WebGpu"
config.prefer_egl = true
config.text_background_opacity = 1.0
config.window_background_opacity = 0.67
config.macos_window_background_blur = 12
config.audible_bell = "SystemBeep"
config.use_dead_keys = false

-- ============================
-- Window Padding
-- ============================
config.window_padding = {
  left = "0.5cell",
  right = "0.5cell",
  top = "0.5cell",
  bottom = "0.5cell",
}

-- ============================
-- Background Configuration
-- ============================
config.background = {
  {
    source = { Color = "#171616" },
    height = "100%",
    width = "100%",
  },
}

-- ============================
-- Inactive Pane HSB Settings
-- ============================
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.7,
}

-- ============================
-- Tab Bar Configuration
-- ============================
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true

-- ============================
-- Workspace Configuration
-- ============================
config.adjust_window_size_when_changing_font_size = true

-- ============================
-- Startup Configuration
-- ============================
wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window({})
  window:gui_window():maximize()
end)

return config
