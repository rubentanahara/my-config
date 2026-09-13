local wezterm = require("wezterm")
local mux = wezterm.mux

local cnfg = wezterm.config_builder()

cnfg.color_scheme = "MaterialDarker"

cnfg.colors = {
  cursor_bg = "#ffffff",     -- Cursor background color
  cursor_fg = "#1a1a1e",     -- Cursor foreground color
  cursor_border = "#ffffff", -- Cursor border color
}

cnfg.enable_kitty_graphics = true
cnfg.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
cnfg.automatically_reload_config = true
cnfg.font_size = 14
cnfg.window_decorations = "RESIZE"
cnfg.enable_tab_bar = false
cnfg.harfbuzz_features = { "calt=0" }
cnfg.window_close_confirmation = "NeverPrompt"
cnfg.max_fps = 120
cnfg.animation_fps = 120
cnfg.front_end = "WebGpu"
cnfg.prefer_egl = true
cnfg.text_background_opacity = 1
cnfg.window_background_opacity = 0.5
cnfg.macos_window_background_blur = 20
-- macOS-specific window background blur
cnfg.macos_window_background_blur = 30
cnfg.audible_bell = "Disabled"
cnfg.use_dead_keys = false
cnfg.window_padding = {
  left = "0.0cell",
  right = "0.0cell",
  top = "0.0cell",
  bottom = "0.0cell",
}
cnfg.background = {
  {
    source = { Color = "#171616" }, -- Background color
    height = "100%",
    width = "100%",
  },
}
cnfg.inactive_pane_hsb = {
  saturation = 0.8, -- Saturation level for inactive panes
  brightness = 0.7, -- Brightness level for inactive panes
}

cnfg.use_fancy_tab_bar = false
cnfg.tab_bar_at_bottom = false
cnfg.hide_tab_bar_if_only_one_tab = true
cnfg.adjust_window_size_when_changing_font_size = true
wezterm.on("gui-startup", function()
  local window = mux.spawn_window({})
  window:gui_window():maximize()
end)

return cnfg
