return {
  {
    'saecki/crates.nvim',
    ft = { 'toml' },
    config = function()
      require('crates').setup {
        lsp = {
          enabled = true,
        },
      }
      require('crates').show()
    end,
  },
}
