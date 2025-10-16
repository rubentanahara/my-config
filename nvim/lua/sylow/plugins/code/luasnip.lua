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

local function setup_cmp_integration(_, opts)
  opts.snippet = opts.snippet or {}
  opts.snippet.expand = function(args)
    require('luasnip').lsp_expand(args.body)
  end

  opts.sources = opts.sources or {}
  table.insert(opts.sources, { name = 'luasnip', priority = 750 })
end

-- Luasnip key mappings
local luasnip_keys = {
  {
    '<tab>',
    function()
      local luasnip = require('luasnip')
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end,
    mode = { 'i', 's' },
    desc = 'Luasnip expand or jump next',
  },
  {
    '<s-tab>',
    function()
      require('luasnip').jump(-1)
    end,
    mode = { 'i', 's' },
    desc = 'Luasnip jump previous',
  },
}

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
    opts = setup_luasnip,
    config = configure_luasnip,
    keys = luasnip_keys,
  },

  -- CMP integration
  {
    'hrsh7th/nvim-cmp',
    optional = true,
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    opts = setup_cmp_integration,
  },
}
