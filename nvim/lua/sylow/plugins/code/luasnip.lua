local is_windows = vim.fn.has('win32') == 1

-- Local helper functions
local function setup_luasnip()
  return {
    history = true,
    delete_check_events = 'TextChanged',
    region_check_events = 'CursorMoved',
    update_events = 'TextChanged,TextChangedI',
  }
end

local function configure_luasnip(_, opts)
  local luasnip = require('luasnip')
  luasnip.config.setup(opts)

  -- Load snippets from various sources
  vim.tbl_map(function(type)
    require('luasnip.loaders.from_' .. type).lazy_load()
  end, { 'vscode', 'snipmate', 'lua' })

  -- Custom snippet paths
  require('luasnip.loaders.from_vscode').lazy_load({
    paths = { vim.fn.stdpath('config') .. '/snippets' },
  })

  -- Filetype extensions for documentation snippets
  local filetype_extensions = {
    lua = { 'luadoc' },
    typescript = { 'tsdoc' },
    javascript = { 'jsdoc' },
    python = { 'pydoc' },
    rust = { 'rustdoc' },
    cs = { 'csharpdoc' },
    cpp = { 'cppdoc' },
  }

  for ft, exts in pairs(filetype_extensions) do
    luasnip.filetype_extend(ft, exts)
  end
end

return {
  -- Friendly snippets collection
  {
    'rafamadriz/friendly-snippets',
    lazy = true,
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },

  -- Additional snippets
  {
    'zeioth/NormalSnippets',
    lazy = true,
    dependencies = { 'L3MON4D3/LuaSnip' },
  },

  -- Telescope integration for snippets
  {
    'benfowler/telescope-luasnip.nvim',
    cmd = 'Telescope',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('telescope').load_extension('luasnip')
    end,
  },

  -- Main LuaSnip plugin
  {
    'L3MON4D3/LuaSnip',
    build = not is_windows and 'make install_jsregexp' or nil,
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'rafamadriz/friendly-snippets',
      'zeioth/NormalSnippets',
      'benfowler/telescope-luasnip.nvim',
    },
    opts = setup_luasnip,
    config = configure_luasnip,
  },
}
