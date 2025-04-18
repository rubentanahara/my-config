local utils = require('base.utils')
local utils_lsp = require('base.utils.lsp')

return {
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      -- import comment plugin safely
      local comment = require('Comment')

      local ts_context_commentstring = require('ts_context_commentstring.integrations.comment_nvim')

      -- enable comment
      comment.setup({
        -- for commenting tsx, jsx, svelte, html files
        pre_hook = ts_context_commentstring.create_pre_hook(),
      })
    end,
  },
  {
    'echasnovski/mini.indentscope',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      symbol = '│',
      options = {
        try_as_border = true,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'help',
          'alpha',
          'dashboard',
          'neo-tree',
          'Trouble',
          'trouble',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
        },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
    end,
  },
  {
    'echasnovski/mini.comment',
    version = false,
    event = 'VeryLazy',
    config = function() require('mini.comment').setup() end,
  },
  {
    'echasnovski/mini.pairs',
    version = false,
    event = 'VeryLazy',
    config = function() require('mini.pairs').setup() end,
  },
  {
    'echasnovski/mini.surround',
    event = 'VeryLazy',
    version = false,
    config = function() require('mini.surround').setup() end,
  },
  -- Flash enhances the built-in search functionality by showing labels
  -- at the end of each match, letting you quickly jump to a specific
  -- location.
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    vscode = true,
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local conform = require('conform')

      conform.setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          rust = { 'rustfmt' },
          c_sharp = { 'csharpier' },
          kotlin = { 'ktlint' },
          dart = { 'dart' },
          bash = { 'shfmt' },
          sh = { 'shfmt' },
          go = { 'gofmt', 'goimports', 'golines' },
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          javascriptreact = { 'prettier' },
          typescriptreact = { 'prettier' },
          css = { 'prettier' },
          html = { 'prettier' },
          json = { 'prettier' },
          yaml = { 'prettier' },
          markdown = { 'prettier' },
          graphql = { 'prettier' },
        },
        -- format_on_save = {
        --   lsp_fallback = true,
        --   async = false,
        --   timeout_ms = 1000,
        -- },
      })

      vim.keymap.set(
        { 'n', 'v' },
        '<leader>cf',
        function()
          conform.format({
            lsp_fallback = true,
            async = true,
            timeout_ms = 1000,
          })
        end,
        { desc = 'Format file or range (in visual mode)' }
      )
    end,
  },
  -- Linter
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = {
        javascript = { 'eslint_d' },
        typescript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
        python = { 'ruff' },
        lua = { 'luacheck' },
        bash = { 'shellcheck' },
        sh = { 'shellcheck' },
        markdown = { 'markdownlint' },
        yaml = { 'yamllint' },
        json = { 'jsonlint' },
        html = { 'htmlhint' },
        css = { 'stylelint' },
        scss = { 'stylelint' },
        rust = { 'rustfmt' },
        kotlin = { 'ktlint' },
        c_sharp = { 'cspell' },
        go = { 'golangci-lint' },
      }

      -- Configure linters
      lint.linters.ruff.args = {
        '--select=E,F,W,I,N,B,A',
        '--ignore=E501,E402',
        '--fix',
        '--quiet',
        '-',
      }

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Skip linting for large files
          local bufnr = vim.api.nvim_get_current_buf()
          local max_filesize = 100 * 1024 -- 100 KB
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local ok, stats = pcall(vim.loop.fs_stat, bufname)
          if ok and stats and stats.size > max_filesize then return end

          -- Skip linting for certain filetypes
          local filetype = vim.bo[bufnr].filetype
          local skip_filetypes = { 'NvimTree', 'TelescopePrompt', 'Trouble', 'help' }
          for _, ft in ipairs(skip_filetypes) do
            if ft == filetype then return end
          end

          -- Run linter with error handling
          local ok, err = pcall(function() lint.try_lint() end)

          if not ok then vim.notify('Linting error: ' .. tostring(err), vim.log.levels.WARN) end
        end,
      })

      vim.keymap.set('n', '<leader>cl', function() lint.try_lint() end, { desc = 'Lint current file' })
    end,
  },
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile' },
    version = false,
    build = ':TSUpdate',
    lazy = false,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    cmd = {
      'TSBufDisable',
      'TSBufEnable',
      'TSBufToggle',
      'TSDisable',
      'TSEnable',
      'TSToggle',
      'TSInstall',
      'TSInstallInfo',
      'TSInstallSync',
      'TSModuleInfo',
      'TSUninstall',
      'TSUpdate',
      'TSUpdateSync',
    },
    keys = {
      { '<c-space>', desc = 'Increment selection' },
      { '<bs>', desc = 'Decrement selection', mode = 'x' },
    },
    opts = {
      auto_install = false,
      highlight = {
        enable = true,
        -- disable = function(_, bufnr) return utils.is_big_file(bufnr) end,
      },
      matchup = {
        enable = true,
        enable_quotes = true,
        -- disable = function(_, bufnr) return utils.is_big_file(bufnr) end,
      },
      indent = { enable = true },
      autotag = {
        enable = true,
      },
      ensure_installed = {
        'bash',
        'c',
        'go',
        'html',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'luap',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'regex',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
        'css',
        'dockerfile',
        'graphql',
        'rust',
        'toml',
        'c_sharp',
        'dart',
        'kotlin',
        'dart',
        'xml',
        'scss',
        'sql',
        'svelte',
        'vue',
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
            [']p'] = '@parameter.inner',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']C'] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
            ['[p'] = '@parameter.inner',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[C'] = '@class.outer',
          },
        },
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
          },
        },
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then return false end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
    {
    'hrsh7th/nvim-cmp',
    version = false,
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'saadparwaiz1/cmp_luasnip',
      {
        'L3MON4D3/LuaSnip',
        build = (not jit.os:find('Windows'))
            and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
          or nil,
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
          },
        },
        opts = {
          history = true,
          delete_check_events = 'TextChanged',
        },
      },
    },
    opts = function()
      vim.api.nvim_set_hl(0, 'CmpGhostText', { link = 'Comment', default = true })
      local cmp = require('cmp')
      local defaults = require('cmp.config.default')()
      return {
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        snippet = {
          expand = function(args) require('luasnip').lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<S-CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ['<C-CR>'] = function(fallback)
            cmp.abort()
            fallback()
          end,
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
          { name = 'calc' },
          { name = 'treesitter' },
          { name = 'crates' },
          { name = 'tmux' },
        }, {
          { name = 'buffer' },
        }),
        formatting = {
          format = function(_, item)
            local icons = {
              Array = ' ',
              Boolean = '󰨙 ',
              Class = ' ',
              Constant = '󰏿 ',
              Constructor = ' ',
              Enum = ' ',
              EnumMember = ' ',
              Event = ' ',
              Field = ' ',
              File = ' ',
              Function = '󰊕 ',
              Interface = ' ',
              Key = ' ',
              Keyword = ' ',
              Method = '󰊕 ',
              Module = ' ',
              Namespace = '󰦮 ',
              Null = ' ',
              Number = '󰎠 ',
              Object = ' ',
              Operator = ' ',
              Package = ' ',
              Property = ' ',
              Reference = ' ',
              Snippet = ' ',
              String = ' ',
              Struct = '󰨾 ',
              Text = ' ',
              TypeParameter = ' ',
              Unit = ' ',
              Value = ' ',
              Variable = '󰀫 ',
            }
            if icons[item.kind] then item.kind = icons[item.kind] .. item.kind end
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = 'CmpGhostText',
          },
        },
        sorting = defaults.sorting,
      }
    end,
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      require('cmp').setup(opts)
    end,
  }
}
