return {
  {
    'echasnovski/mini.icons',
    lazy = true,
    opts = {
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        ['.eslintrc.js'] = { glyph = '󰱺', hl = 'MiniIconsYellow' },
        ['.node-version'] = { glyph = '', hl = 'MiniIconsGreen' },
        ['.prettierrc'] = { glyph = '', hl = 'MiniIconsPurple' },
        ['.yarnrc.yml'] = { glyph = '', hl = 'MiniIconsBlue' },
        ['eslint.config.js'] = { glyph = '󰱺', hl = 'MiniIconsYellow' },
        ['package.json'] = { glyph = '', hl = 'MiniIconsGreen' },
        ['tsconfig.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        ['tsconfig.build.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        ['yarn.lock'] = { glyph = '', hl = 'MiniIconsBlue' },
      },
      filetype = {
        dotenv = { glyph = '', hl = 'MiniIconsYellow' },
      },
    },
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },
  {
    'echasnovski/mini.indentscope',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      -- draw = { delay = 0, animation = function() return 0 end },
      options = { border = 'top', try_as_border = true },
      symbol = '▏',
    },
    config = function(_, opts)
      require('mini.indentscope').setup(opts)

      -- Disable for certain filetypes
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        desc = 'Disable indentscope for certain filetypes',
        callback = function()
          local ignored_filetypes = {
            'aerial',
            'dashboard',
            'help',
            'lazy',
            'leetcode.nvim',
            'mason',
            'neo-tree',
            'NvimTree',
            'neogitstatus',
            'notify',
            'startify',
            'toggleterm',
            'Trouble',
            'calltree',
            'coverage',
          }
          if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
            vim.b.miniindentscope_disable = true
          end
        end,
      })
    end,
  },
  {
    'echasnovski/mini.pairs',
    event = 'VeryLazy',
    opts = {
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { 'string' },
      skip_unbalanced = true,
      markdown = true,
      modes = { insert = true, command = false, terminal = false },
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
      local plugin = require('lazy.core.config').spec.plugins['mini.surround']
      local opts = require('lazy.core.plugin').values(plugin, 'opts', false)
      local mappings = {
        { opts.mappings.add, desc = 'Add surrounding', mode = { 'n', 'v' } },
        { opts.mappings.delete, desc = 'Delete surrounding' },
        { opts.mappings.find, desc = 'Find right surrounding' },
        { opts.mappings.find_left, desc = 'Find left surrounding' },
        { opts.mappings.highlight, desc = 'Highlight surrounding' },
        { opts.mappings.replace, desc = 'Replace surrounding' },
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
}
