-- =============================================================
-- WezTerm Configuration
-- =============================================================

-- =============================================================
-- 1. Module Imports
-- =============================================================
local wezterm = require("wezterm")
local mux = wezterm.mux

-- =============================================================
-- 2. Configuration Builder
-- =============================================================
-- Initialize the configuration using the configuration builder for better structure and readability.
local config = wezterm.config_builder()

-- =============================================================
-- 3. Color Scheme and Visual Settings
-- =============================================================

-- Set the color scheme to 'MaterialDarker'. Uncomment the line below to switch to 'rose-pine'.
config.color_scheme = "MaterialDarker"
-- config.color_scheme = "rose-pine"

-- Customize specific colors
config.colors = {
  cursor_bg = "#ffffff",     -- Cursor background color
  cursor_fg = "#1a1a1e",     -- Cursor foreground color
  cursor_border = "#ffffff", -- Cursor border color
}

-- Configure terminal type and enable kitty graphics
config.enable_kitty_graphics = true

-- Set the font and its properties
config.font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Regular" })
-- config.font = wezterm.font("JetBrains Mono", { weight = "Regular" }) -- Alternative font

-- Automatically reload the configuration when changes are detected
config.automatically_reload_config = true

-- Font size and line height
config.font_size = 15
config.line_height = 1.2

-- Window decorations and tab bar settings
config.window_decorations = "RESIZE"
config.enable_tab_bar = false

-- HarfBuzz font shaping features
config.harfbuzz_features = { "calt=0" }

-- Window close confirmation behavior
config.window_close_confirmation = "NeverPrompt"

-- Cursor style and blink settings
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 800
config.cursor_blink_ease_out = "Constant"
config.cursor_blink_ease_in = "Constant"

-- Performance settings
config.max_fps = 120
config.animation_fps = 120
config.front_end = "WebGpu"
config.prefer_egl = true

-- Opacity settings for text and window backgrounds
config.text_background_opacity = 1.0
config.window_background_opacity = 0.8

-- macOS-specific window background blur
config.macos_window_background_blur = 30

-- Audio bell settings
config.audible_bell = "Disabled"

-- Dead keys configuration
config.use_dead_keys = false

-- =============================================================
-- 4. Window Padding
-- =============================================================
config.window_padding = {
  left = "0.5cell",
  right = "0.5cell",
  top = "0.5cell",
  bottom = "0.5cell",
}

-- =============================================================
-- 5. Background Configuration
-- =============================================================
config.background = {
  {
    source = { Color = "#171616" }, -- Background color
    height = "100%",
    width = "100%",
  },
}

-- =============================================================
-- 6. Inactive Pane HSB Settings
-- =============================================================
config.inactive_pane_hsb = {
  saturation = 0.8, -- Saturation level for inactive panes
  brightness = 0.7, -- Brightness level for inactive panes
}

-- =============================================================
-- 7. Tab Bar Configuration
-- =============================================================
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true

-- =============================================================
-- 8. Workspace Configuration
-- =============================================================
config.adjust_window_size_when_changing_font_size = true

-- =============================================================
-- 9. Startup Configuration
-- =============================================================
wezterm.on("gui-startup", function()
  -- Spawn a new window on GUI startup
  local tab, pane, window = mux.spawn_window({})
  -- Maximize the new window
  window:gui_window():maximize()
end)

-- =============================================================
-- 10. Finalize Configuration
-- =============================================================
-- Return the fully constructed configuration
return config
