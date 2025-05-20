-- Register any queued mappings from the utils module
local utils = require('sylow.core.utils')
local get_icon = utils.get_icon

return { -- Which-key: Display available keybindings in popup
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts_extend = { 'spec' },
    opts = {
      preset = 'modern',
      plugins = {
        marks = true, -- Shows marks when pressing ' or `
        registers = true, -- Shows registers when pressing " in NORMAL or <C-r> in INSERT
        spelling = {
          enabled = true, -- Enable showing spelling suggestions with z=
          suggestions = 20, -- Number of suggestions to show
        },
        presets = {
          operators = true, -- Adds help for operators like d, y, ...
          motions = true, -- Adds help for motions
          text_objects = true, -- Help for text objects triggered after entering an operator
          windows = true, -- Default bindings on <c-w>
          nav = true, -- Misc bindings to work with windows
          z = true, -- Bindings for folds, spelling, etc. starting with z
          g = true, -- Bindings starting with g
        },
      },
      icons = {
        breadcrumb = '»', -- Symbol used in the command line area that shows your active key combo
        separator = '➜', -- Symbol used between a key and its label
        group = '+', -- Symbol prepended to a group
      },
      filter = function(text)
        return text
      end,
      disable = { -- Replaced triggers_blacklist
        -- list of mode / prefixes that should never be hooked by WhichKey
        buftypes = {}, -- Disabled for these buffer types
        filetypes = {}, -- Disabled for these file types
        -- Specific key sequence blacklists
        keys = {
          i = { 'j', 'k' }, -- Disable in insert mode for jk mapping
          v = { 'j', 'k' }, -- Disable in visual mode for jk mapping
        },
      },
      spec = {
        {
          mode = { 'n', 'v' },
          {
            '<leader>',
            group = 'Main Menu',
          },
          {
            '<leader>f',
            group = 'Find',
          },
          {
            '<leader>p',
            group = 'Packages',
            icon = { icon = get_icon('Packages'), color = 'yellow' },
            desc = 'Packages',
          },
          {
            '<leader>l',
            group = 'LSP',
            icon = { icon = get_icon('LSP'), color = 'cyan' },
            desc = 'LSP',
          },
          {
            '<leader>u',
            group = 'UI',
          },
          {
            '<leader>b',
            group = 'Buffers',
            expand = function()
              return require('which-key.extras').expand.buf()
            end,
          },
          {
            '<leader>d',
            group = 'Debug',
          },
          {
            '<leader>tt',
            group = 'Test',
          },
          {
            '<leader>dc',
            group = 'Docs',
            icon = { icon = get_icon('Docs'), color = 'green' },
            desc = 'Docs',
          },
          {
            '<leader>g',
            group = 'Git',
            icon = { icon = get_icon('Git') },
          },
          {
            '<leader>t',
            group = 'Terminal',
          },
          {
            '<leader>s',
            group = 'Search',
            icon = { icon = get_icon('Search'), color = 'green' },
            desc = 'Search',
          },
          {
            '<leader>w',
            group = 'Window',
            desc = 'Window',
            proxy = '<c-w>',
            expand = function()
              return require('which-key.extras').expand.win()
            end,
          },
          {
            '<leader>x',
            group = 'Diagnostics',
            icon = { icon = get_icon('DiagnosticInfo'), color = 'green' },
            desc = 'Diagnostics',
          },
          {
            '<leader>z',
            group = 'Fold',
            icon = { icon = get_icon('NeoTree'), color = 'green' },
          },
        },
      },
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({
            global = false,
          })
        end,
        desc = 'Buffer Keymaps (which-key)',
      },
      {
        '<c-w><space>',
        function()
          require('which-key').show({
            keys = '<c-w>',
            loop = true,
          })
        end,
        desc = 'Window Hydra Mode (which-key)',
      },
    },
    config = function(_, opts)
      local wk = require('which-key')
      wk.setup(opts)

      -- Register which-key register function to utils
      utils.which_key_register = function()
        if utils.which_key_queue then
          wk.add(utils.which_key_queue)
          utils.which_key_queue = nil
        end
      end

      -- Register any queued mappings
      if utils.which_key_queue then
        wk.add(utils.which_key_queue)
        utils.which_key_queue = nil
      end
    end,
  },
}
