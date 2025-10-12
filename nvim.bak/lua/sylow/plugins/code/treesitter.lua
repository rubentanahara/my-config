local utils = require('sylow.core.utils')

return {
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    event = 'User BaseDeferred',
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
    build = ':TSUpdate',
    opts = {
      auto_install = true,
      autotag = {
        enable = true,
      },
      highlight = {
        enable = true,
        use_languagetree = true,
        disable = function(_, bufnr)
          return utils.is_big_file(bufnr)
        end,
      },
      matchup = {
        enable = true,
        enable_quotes = true,
        disable = function(_, bufnr)
          return utils.is_big_file(bufnr)
        end,
      },
      incremental_selection = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        'lua',
        'luadoc',
        'vim',
        'vimdoc',
        'c_sharp',
        'ninja',
        'rst',
        'rust',
        'python',
        'ron',
        'javascript',
        'typescript',
        'bash',
        'json',
        'bicep',
        'xml',
        'sql'
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { 'BufWrite', 'CursorHold' },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- Blocks
            ['ak'] = { query = '@block.outer', desc = 'around block' },
            ['ik'] = { query = '@block.inner', desc = 'inside block' },

            -- Classes
            ['ac'] = { query = '@class.outer', desc = 'around class' },
            ['ic'] = { query = '@class.inner', desc = 'inside class' },

            -- Conditionals
            ['a?'] = { query = '@conditional.outer', desc = 'around conditional' },
            ['i?'] = { query = '@conditional.inner', desc = 'inside conditional' },

            -- Functions
            ['af'] = { query = '@function.outer', desc = 'around function ' },
            ['if'] = { query = '@function.inner', desc = 'inside function ' },

            -- Loops
            ['al'] = { query = '@loop.outer', desc = 'around loop' },
            ['il'] = { query = '@loop.inner', desc = 'inside loop' },

            -- Parameters/Arguments
            ['aa'] = { query = '@parameter.outer', desc = 'around argument' },
            ['ia'] = { query = '@parameter.inner', desc = 'inside argument' },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']k'] = { query = '@block.outer', desc = 'Next block start' },
            [']f'] = { query = '@function.outer', desc = 'Next function start' },
            [']a'] = { query = '@parameter.inner', desc = 'Next parameter start' },
          },
          goto_next_end = {
            [']K'] = { query = '@block.outer', desc = 'Next block end' },
            [']F'] = { query = '@function.outer', desc = 'Next function end' },
            [']A'] = { query = '@parameter.inner', desc = 'Next parameter end' },
          },
          goto_previous_start = {
            ['[k'] = { query = '@block.outer', desc = 'Previous block start' },
            ['[f'] = { query = '@function.outer', desc = 'Previous function start' },
            ['[a'] = { query = '@parameter.inner', desc = 'Previous parameter start' },
          },
          goto_previous_end = {
            ['[K'] = { query = '@block.outer', desc = 'Previous block end' },
            ['[F'] = { query = '@function.outer', desc = 'Previous function end' },
            ['[A'] = { query = '@parameter.inner', desc = 'Previous parameter end' },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['>K'] = { query = '@block.outer', desc = 'Swap next block' },
            ['>F'] = { query = '@function.outer', desc = 'Swap next function' },
            ['>A'] = { query = '@parameter.inner', desc = 'Swap next parameter' },
          },
          swap_previous = {
            ['<K'] = { query = '@block.outer', desc = 'Swap previous block' },
            ['<F'] = { query = '@function.outer', desc = 'Swap previous function' },
            ['<A'] = { query = '@parameter.inner', desc = 'Swap previous parameter' },
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
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'VeryLazy',
    enabled = true,
    config = function()
      -- If treesitter is already loaded, we need to run config again for textobjects
      if utils.is_available('nvim-treesitter') then
        local opts = utils.get_plugin_opts('nvim-treesitter')
        require('nvim-treesitter.configs').setup({ textobjects = opts.textobjects })
      end

      -- When in diff mode, we want to use the default
      -- vim text objects c & C instead of the treesitter ones.
      local move = require('nvim-treesitter.textobjects.move') ---@type table<string,fun(...)>
      local configs = require('nvim-treesitter.configs')
      for name, fn in pairs(move) do
        if name:find('goto') == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module('textobjects.move')[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find('[%]%[][cC]') then
                  vim.cmd('normal! ' .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },
}
