return {
  {
    'mrcjkb/rustaceanvim',
    version = '^9',
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ['rust-analyzer'] = {
              cargo = { allFeatures = true },
              checkOnSave = { enable = true, command = 'clippy' },
            },
          },
        },
      }
    end,
  },
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
