return {
  -- Incremental rename
  {
    'smjonas/inc-rename.nvim',
    cmd = 'IncRename',
    keys = {
      {
        '<leader>cr',
        function()
          return ':IncRename ' .. vim.fn.expand('<cword>')
        end,
        desc = 'Rename',
        mode = 'n',
        noremap = true,
        expr = true,
      },
    },
    config = true,
  },

  -- Refactoring tool
  {
    'ThePrimeagen/refactoring.nvim',
    keys = {
      {
        '<leader>ct',
        function()
          require('refactoring').select_refactor({
            show_success_message = true,
          })
        end,
        mode = 'v',
        noremap = true,
        silent = true,
        expr = false,
      },
    },
    opts = {},
  },
}
