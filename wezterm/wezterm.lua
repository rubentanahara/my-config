local wezterm = require("wezterm")
local mux = wezterm.mux

local config = wezterm.config_builder()

config.color_scheme = "MaterialDarker"
-- config.color_scheme = "rose-pine"
-- config.color_scheme = 'Vs Code Dark+ (Gogh)'

config.colors = {
  cursor_bg = "#ffffff",     -- Cursor background color
  cursor_fg = "#1a1a1e",     -- Cursor foreground color
  cursor_border = "#ffffff", -- Cursor border color
}

config.enable_kitty_graphics = true
-- config.font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Regular" })
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.automatically_reload_config = true
config.font_size = 14
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.harfbuzz_features = { "calt=0" }
config.window_close_confirmation = "NeverPrompt"
config.max_fps = 120
config.animation_fps = 120
config.front_end = "WebGpu"
config.prefer_egl = true
config.text_background_opacity = 1
-- config.window_background_opacity = 0.5
-- config.macos_window_background_blur = 20
-- macOS-specific window background blur
-- config.macos_window_background_blur = 30
config.audible_bell = "Disabled"
config.use_dead_keys = false
config.window_padding = {
  left = "0.0cell",
  right = "0.0cell",
  top = "0.0cell",
  bottom = "0.0cell",
}
config.background = {
  {
    source = { Color = "#171616" }, -- Background color
    height = "100%",
    width = "100%",
  },
}
config.inactive_pane_hsb = {
  saturation = 0.8, -- Saturation level for inactive panes
  brightness = 0.7, -- Brightness level for inactive panes
}

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true
config.adjust_window_size_when_changing_font_size = true
wezterm.on("gui-startup", function()
  local window = mux.spawn_window({})
  window:gui_window():maximize()
end)

return config
