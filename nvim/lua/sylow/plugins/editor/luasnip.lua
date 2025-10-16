local is_windows = vim.fn.has('win32') == 1

return {
  {
    'L3MON4D3/LuaSnip',
    build = not is_windows and 'make install_jsregexp' or nil,
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
          require('luasnip.loaders.from_vscode').lazy_load({ paths = { vim.fn.stdpath('config') .. '/snippets' } })
        end,
      },
      'zeioth/NormalSnippets',
      'benfowler/telescope-luasnip.nvim',
    },
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
      region_check_events = 'CursorMoved',
    },
    config = function(_, opts)
      if opts then
        require('luasnip').config.setup(opts)
      end
      vim.tbl_map(function(type)
        require('luasnip.loaders.from_' .. type).lazy_load()
      end, { 'vscode', 'snipmate', 'lua' })
      require('luasnip').filetype_extend('lua', { 'luadoc' })
      require('luasnip').filetype_extend('typescript', { 'tsdoc' })
      require('luasnip').filetype_extend('javascript', { 'jsdoc' })
      require('luasnip').filetype_extend('python', { 'pydoc' })
      require('luasnip').filetype_extend('rust', { 'rustdoc' })
      require('luasnip').filetype_extend('cs', { 'csharpdoc' })
      require('luasnip').filetype_extend('cpp', { 'cppdoc' })
    end,
  },
}
