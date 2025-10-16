return {
  'nvim-flutter/flutter-tools.nvim',
  ft = { 'dart' },
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

    local map = vim.keymap.set

    map('n', '<leader>afr', '<cmd>FlutterRun<cr>', { desc = 'Flutter Run' })
    map('n', '<leader>afR', '<cmd>FlutterRestart<cr>', { desc = 'Flutter Restart' })
    map('n', '<leader>afq', '<cmd>FlutterQuit<cr>', { desc = 'Flutter Quit' })
    map('n', '<leader>afc', '<cmd>FlutterCopyProfilerUrl<cr>', { desc = 'Flutter Copy Profiler URL' })
    map('n', '<leader>afd', '<cmd>FlutterDevices<cr>', { desc = 'Flutter Devices' })
    map('n', '<leader>afD', '<cmd>FlutterDetach<cr>', { desc = 'Flutter Detach' })
    map('n', '<leader>afe', '<cmd>FlutterEmulators<cr>', { desc = 'Flutter Emulators' })
    map('n', '<leader>afo', '<cmd>FlutterOutlineToggle<cr>', { desc = 'Flutter Outline Toggle' })
    map('n', '<leader>aft', '<cmd>FlutterDevTools<cr>', { desc = 'Flutter DevTools' })
    map('n', '<leader>afl', '<cmd>FlutterLogClear<cr>', { desc = 'Flutter Log Clear' })
    map('n', '<leader>afL', '<cmd>FlutterLogToggle<cr>', { desc = 'Flutter Log Toggle' })
    map('n', '<leader>afv', '<cmd>FlutterVisualDebug<cr>', { desc = 'Flutter Visual Debug' })
  end,
}
