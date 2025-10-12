return {
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
