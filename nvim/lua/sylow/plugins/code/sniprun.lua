return {
  {
    'michaelb/sniprun',
    branch = 'master',
    build = 'sh install.sh',
    cmd = { 'SnipRun', 'SnipInfo', 'SnipReset', 'SnipReplMemoryClean', 'SnipClose', 'SnipLive', 'SnipTerminate' },
    init = function()
      vim.g.markdown_fenced_languages =
        { 'javascript', 'typescript', 'bash', 'lua', 'go', 'rust', 'c', 'cpp', 'python' }
    end,
    keys = {
      { '<leader>r', '<cmd>SnipRun<cr>', mode = 'n', desc = 'SnipRun (current line)' },
      { '<leader>r', ':SnipRun<cr>', mode = 'v', silent = true, desc = 'SnipRun (selection)' },
      { '<leader>rc', ':SnipClose<cr>', mode = 'n', silent = true, desc = 'SnipClose' },
    },
    opts = {
      display = {
        'VirtualTextOk',
        'LongTempFloatingWindow',
      },
      live_display = { 'VirtualTextOk' },
      display_options = {
        max_fw_width = 100,
      },
      show_no_output = { 'VirtualTextOk' },
      -- notebook-like REPL memory across runs; Python3_original needs `pip install --user klepto`
      repl_enable = { 'Python3_original' },
      live_mode_toggle = 'enable',
      ansi_escape = true,
      borders = 'single',
    },
  },
}
