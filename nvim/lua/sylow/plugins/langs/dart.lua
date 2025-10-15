return {
  'nvim-flutter/flutter-tools.nvim',
  event = 'VeryLazy', -- Changed from lazy = false to event-based loading
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim', -- optional for vim.ui.select
  },
  opts = { -- Using opts instead of config function for better performance
    ui = {
      border = 'rounded',
      notification_style = 'native',
    },
    decorations = {
      statusline = {
        app_version = false,
        device = false,
        project_config = false,
      },
    },
    debugger = {
      enabled = true,
      exception_breakpoints = {},
      evaluate_to_string_in_debug_views = true,
    },
    flutter_lookup_cmd = nil,
    root_patterns = { '.git', 'pubspec.yaml' },
    fvm = false,
    widget_guides = {
      enabled = true,
    },
    closing_tags = {
      highlight = 'Comment',
      prefix = '>',
      priority = 10,
      enabled = true,
    },
    dev_log = {
      enabled = true,
      notify_errors = false,
      open_cmd = '15split',
      focus_on_open = true,
    },
    dev_tools = {
      autostart = false,
      auto_open_browser = false,
    },
    outline = {
      open_cmd = '30vnew',
      auto_open = false,
    },
  },
  config = function(_, opts)
    require('flutter-tools').setup(opts)
  end,
}
