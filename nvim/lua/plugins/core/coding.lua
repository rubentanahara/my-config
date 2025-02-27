return {
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    version = false,
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    keys = {
      { '<c-space>', desc = 'Increment selection' },
      { '<bs>',      desc = 'Decrement selection', mode = 'x' },
    },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        'bash',
        'c',
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
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  -- Auto pairs
  {
    'echasnovski/mini.pairs',
    event = 'VeryLazy',
    opts = {
      -- In which modes mappings from this `config` should be created
      modes = { insert = true, command = false, terminal = false },

      -- Global mappings. Each right hand side should be a pair information, a
      -- table with at least these fields (see more in |MiniPairs.map|):
      -- - `action` - one of "open", "close", "closeopen".
      -- - `pair` - two-character string for pair to be used.
      -- - `neigh_pattern` - pattern of neighboring characters.
      -- - `register` - boolean whether to use pair characters in insert mode.
      mappings = {
        -- Brackets
        ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
        ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
        ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },

        [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
        [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
        ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },

        -- Quotes
        ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
        ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
        ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
      },
    },
  },

  -- Surround
  {
    'echasnovski/mini.surround',
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require('lazy.core.config').spec.plugins['mini.surround']
      local opts = require('lazy.core.plugin').values(plugin, 'opts', false)
      local mappings = {
        { opts.mappings.add,            desc = 'Add surrounding',                     mode = { 'n', 'v' } },
        { opts.mappings.delete,         desc = 'Delete surrounding' },
        { opts.mappings.find,           desc = 'Find right surrounding' },
        { opts.mappings.find_left,      desc = 'Find left surrounding' },
        { opts.mappings.highlight,      desc = 'Highlight surrounding' },
        { opts.mappings.replace,        desc = 'Replace surrounding' },
        { opts.mappings.update_n_lines, desc = 'Update `MiniSurround.config.n_lines`' },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = 'gza',
        delete = 'gzd',
        find = 'gzf',
        find_left = 'gzF',
        highlight = 'gzh',
        replace = 'gzr',
        update_n_lines = 'gzn',
      },
    },
  },

  -- Comments
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },
  {
    'echasnovski/mini.comment',
    event = 'VeryLazy',
    opts = {
      options = {
        custom_commentstring = function()
          return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
        end,
      },
      mappings = {
        comment = 'gc',
        comment_line = 'gcc',
        textobject = 'gc',
      },
    },
  },

  -- Formatter
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        javascript = { { 'prettierd', 'prettier' } },
        typescript = { { 'prettierd', 'prettier' } },
        javascriptreact = { { 'prettierd', 'prettier' } },
        typescriptreact = { { 'prettierd', 'prettier' } },
        json = { { 'prettierd', 'prettier' } },
        html = { { 'prettierd', 'prettier' } },
        css = { { 'prettierd', 'prettier' } },
        scss = { { 'prettierd', 'prettier' } },
        markdown = { { 'prettierd', 'prettier' } },
        yaml = { { 'prettierd', 'prettier' } },
        rust = { 'rustfmt' },
        c_sharp = { 'csharpier' },
        kotlin = { 'ktlint' },
        dart = { 'dart' },
        bash = { 'shfmt' },
        sh = { 'shfmt' },
      },
      -- Configure formatters
      formatters = {
        prettier = {
          -- Use a specific prettier parser for certain filetypes
          ft_parsers = {
            javascript = 'babel',
            javascriptreact = 'babel',
            typescript = 'typescript',
            typescriptreact = 'typescript',
            vue = 'vue',
          },
          -- Prettier config options
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand '~/.config/nvim/utils/linter-config/.prettierrc.json',
          },
          -- For React Native projects, try to use local prettier if available
          prepend_args = function(self, ctx)
            -- Check if we're in a React Native project
            local is_react_native = false
            local package_json = vim.fn.findfile('package.json', ctx.dirname .. ';')

            if package_json ~= '' then
              local content = vim.fn.readfile(package_json)
              local package_content = table.concat(content, '\n')
              if package_content:match 'react%-native' then
                is_react_native = true
              end
            end

            if is_react_native then
              -- Try to use project-local prettier configuration
              local prettier_config = vim.fn.findfile('.prettierrc', ctx.dirname .. ';')
              if prettier_config ~= '' then
                return { '--config', prettier_config }
              end

              -- Use more permissive settings for React Native
              return { '--print-width', '100', '--single-quote', '--jsx-single-quote' }
            end

            return {}
          end,
        },

        black = {
          -- Increase timeout for Black formatter
          timeout_ms = 5000, -- 5 seconds instead of default
          -- Add args for Black
          args = {
            '--quiet',
            '--fast',
            '-',
          },
          -- Add environment variables
          env = {
            PYTHONPATH = vim.fn.getcwd(),
          },
        },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        -- or vim.b[bufnr].disable_autoformat t
        if vim.g.disable_autoformat then
          return
        end

        -- Get the filetype
        local filetype = vim.bo[bufnr].filetype

        -- Skip formatting for certain filetypes or directories
        local skip_filetypes = { 'NvimTree', 'TelescopePrompt', 'Trouble', 'help' }
        for _, ft in ipairs(skip_filetypes) do
          if ft == filetype then
            return
          end
        end

        -- Check if we're in a node_modules directory
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match 'node_modules' then
          return
        end

        -- Check if the file is too large
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, bufname)
        if ok and stats and stats.size > max_filesize then
          return
        end

        -- Get formatter options based on filetype
        local filetype_specific_options = {}
        if filetype == 'python' then
          -- Check if Python formatting is disabled
          if vim.g.python_format == false then
            return
          end

          filetype_specific_options = {
            timeout_ms = 5000, -- 5 seconds for Python files
            formatters = { 'black' },
          }
        end

        -- Try to format with protection against errors
        local ok, err = pcall(function()
          return vim.tbl_extend('force', { timeout_ms = 1000, lsp_fallback = true }, filetype_specific_options)
        end)

        if not ok then
          vim.notify('Format on save error: ' .. tostring(err), vim.log.levels.WARN)
          return
        end

        return vim.tbl_extend('force', { timeout_ms = 1000, lsp_fallback = true }, filetype_specific_options)
      end,
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      -- Add command to toggle format on save
      vim.api.nvim_create_user_command('FormatToggle', function(args)
        if args.bang then
          -- FormatToggle! will toggle globally
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify('Global autoformatting ' .. (vim.g.disable_autoformat and 'disabled' or 'enabled'),
            vim.log.levels.INFO)
        else
          -- FormatToggle will toggle for current buffer
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          vim.notify('Buffer autoformatting ' .. (vim.b.disable_autoformat and 'disabled' or 'enabled'),
            vim.log.levels.INFO)
        end
      end, { bang = true })

      -- Add command to toggle React Native formatting mode
      vim.api.nvim_create_user_command('ReactNativeFormatToggle', function()
        vim.g.react_native_format = not vim.g.react_native_format
        if vim.g.react_native_format then
          vim.notify('React Native formatting mode ENABLED - Will format on save', vim.log.levels.INFO)
        else
          vim.notify('React Native formatting mode DISABLED - Will NOT format on save', vim.log.levels.INFO)
        end
      end, {})

      -- Add command to manually format React Native files
      vim.api.nvim_create_user_command('ReactNativeFormat', function()
        local bufnr = vim.api.nvim_get_current_buf()
        require('conform').format {
          bufnr = bufnr,
          async = false,
          lsp_fallback = true,
          formatters = { 'prettier' },
          timeout_ms = 1000,
        }
      end, {})

      -- Add command to manually format Python files with extended timeout
      vim.api.nvim_create_user_command('BlackFormat', function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.notify('Running Black formatter with extended timeout (10s)...', vim.log.levels.INFO)
        require('conform').format {
          bufnr = bufnr,
          async = true,
          lsp_fallback = false,
          formatters = { 'black' },
          timeout_ms = 10000, -- 10 seconds
        }
      end, {})

      -- Add command to toggle Python formatting
      vim.api.nvim_create_user_command('PythonFormatToggle', function()
        vim.g.python_format = not vim.g.python_format
        if vim.g.python_format then
          vim.notify('Python formatting ENABLED - Will format on save', vim.log.levels.INFO)
        else
          vim.notify('Python formatting DISABLED - Will NOT format on save', vim.log.levels.INFO)
        end
      end, {})

      -- We don't need to add .NET project file completion here since it's handled in dotnet.lua
    end,
  },

  -- Linter
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
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
          if ok and stats and stats.size > max_filesize then
            return
          end

          -- Skip linting for certain filetypes
          local filetype = vim.bo[bufnr].filetype
          local skip_filetypes = { 'NvimTree', 'TelescopePrompt', 'Trouble', 'help' }
          for _, ft in ipairs(skip_filetypes) do
            if ft == filetype then
              return
            end
          end

          -- Run linter with error handling
          local ok, err = pcall(function()
            lint.try_lint()
          end)

          if not ok then
            vim.notify('Linting error: ' .. tostring(err), vim.log.levels.WARN)
          end
        end,
      })

      vim.keymap.set('n', '<leader>cl', function()
        lint.try_lint()
      end, { desc = 'Lint current file' })
    end,
  },

  -- Better text objects
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    opts = function()
      local ai = require 'mini.ai'
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }, {}),
          f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {}),
          c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {}),
          t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' },
        },
      }
    end,
  },

  -- Better completion
  {
    'hrsh7th/nvim-cmp',
    version = false,
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      {
        'L3MON4D3/LuaSnip',
        build = (not jit.os:find 'Windows') and
            "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp" or nil,
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
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
      local cmp = require 'cmp'
      local defaults = require 'cmp.config.default' ()
      return {
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
          ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<S-CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<C-CR>'] = function(fallback)
            cmp.abort()
            fallback()
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          { name = "calc" },
          { name = "treesitter" },
          { name = "crates" },
          { name = "tmux" },
        }, {
          { name = "buffer" },
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
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
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
  },
}
