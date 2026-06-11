return {
  {
    'Zeioth/compiler.nvim',
    cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo', 'CompilerStop' },
    dependencies = {
      'stevearc/overseer.nvim',
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      { '<F6>', '<cmd>CompilerOpen<cr>', desc = 'Compiler Open' },
      { '<S-F6>', '<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>', desc = 'Compiler Redo' },
      { '<S-F7>', '<cmd>CompilerToggleResults<cr>', desc = 'Compiler Toggle Results' },
    },
    opts = {},
  },
  {
    'stevearc/overseer.nvim',
    commit = '6271cab7ccc4ca840faa93f54440ffae3a3918bd',
    cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo', 'CompilerStop', 'OverseerRun', 'OverseerToggle' },
    opts = {
      task_list = {
        direction = 'bottom',
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
  },
}
