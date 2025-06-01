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
    event = 'User BaseFile',
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
      require("luasnip").filetype_extend("typescript", { "tsdoc" })
      require("luasnip").filetype_extend("javascript", { "jsdoc" })
      -- require("luasnip").filetype_extend("python", { "pydoc" })
      -- require("luasnip").filetype_extend("rust", { "rustdoc" })
      require("luasnip").filetype_extend("cs", { "csharpdoc" })
      -- require("luasnip").filetype_extend("java", { "javadoc" })
      -- require("luasnip").filetype_extend("c", { "cdoc" })
      -- require("luasnip").filetype_extend("cpp", { "cppdoc" })
      -- require("luasnip").filetype_extend("php", { "phpdoc" })
      -- require("luasnip").filetype_extend("kotlin", { "kdoc" })
      -- require("luasnip").filetype_extend("ruby", { "rdoc" })
      -- require("luasnip").filetype_extend("sh", { "shelldoc" })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    optional = true,
    dependencies = { 'saadparwaiz1/cmp_luasnip' },
    opts = function(_, opts)
      opts.snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      }
      table.insert(opts.sources, { name = 'luasnip' })
    end,
    -- stylua: ignore
    keys = {
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
  },
}
