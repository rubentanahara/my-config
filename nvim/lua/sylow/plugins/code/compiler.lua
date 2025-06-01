return {
  {
    'zeioth/compiler.nvim',
    cmd = {
      'CompilerOpen',
      'CompilerToggleResults',
      'CompilerRedo',
      'CompilerStop',
    },
    dependencies = { 'stevearc/overseer.nvim' },
    opts = {},
  },
  {
    'stevearc/overseer.nvim',
    cmd = {
      'OverseerOpen',
      'OverseerClose',
      'OverseerToggle',
      'OverseerSaveBundle',
      'OverseerLoadBundle',
      'OverseerDeleteBundle',
      'OverseerRunCmd',
      'OverseerRun',
      'OverseerInfo',
      'OverseerBuild',
      'OverseerQuickAction',
      'OverseerTaskAction',
      'OverseerClearCache',
    },
    opts = {
      task_list = { -- the window that shows the results.
        direction = 'bottom',
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
      component_aliases = {
        default = {
          "on_exit_set_status",                   -- don't delete this one.
          "on_output_summarize",                  -- show last line on the list.
          "display_duration",                     -- display duration.
          "on_complete_notify",                   -- notify on task start.
          "open_output",                          -- focus last executed task.
          { "on_complete_dispose", timeout=300 }, -- dispose old tasks.
        },
      },
    },
  },
}
