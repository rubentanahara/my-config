return { -- better vim.ui with telescope
  'stevearc/dressing.nvim',
  event = 'User BaseDefered',
  opts = {
    input = {
      enabled = true,

      default_prompt = '➤ ',

      -- Can be 'left', 'right', or 'center'
      title_pos = 'left',

      -- Window options
      border = 'rounded',

      -- When true, <Esc> will close the modal
      insert_only = true,

      -- These are passed to nvim_open_win
      relative = 'cursor',

      -- Window transparency (0-100)
      winblend = 0,

      -- Change the default highlight groups
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',

      -- Position the input window
      override = function(conf)
        -- Center it
        conf.row = math.floor((vim.o.lines - conf.height) / 2)
        conf.col = math.floor((vim.o.columns - conf.width) / 2)
        return conf
      end,

      -- Keymaps for popup
      mappings = {
        n = {
          ['<Esc>'] = 'Close',
          ['<CR>'] = 'Confirm',
        },
        i = {
          ['<C-c>'] = 'Close',
          ['<CR>'] = 'Confirm',
          ['<Up>'] = 'HistoryPrev',
          ['<Down>'] = 'HistoryNext',
        },
      },

      -- Set to true to only use your config and disable the history
      override_ui_input = false,
    },

    select = {
      -- Set to false to disable
      enabled = true,

      -- Priority list of preferred vim.select implementations
      backend = { 'telescope', 'fzf_lua', 'fzf', 'builtin' },

      -- Options for telescope selector
      telescope = {
        -- Can be 'dropdown', 'cursor', or 'ivy'
        theme = 'dropdown',
      },

      -- Options for fzf selector
      fzf = {
        window = {
          width = 0.5,
          height = 0.4,
        },
      },

      -- Options for fzf-lua
      fzf_lua = {
        -- winopts table passed to fzf-lua
        winopts = {
          height = 0.5,
          width = 0.5,
        },
      },

      -- Options for nui Menu
      nui = {
        position = '50%',
        size = nil,
        relative = 'editor',
        border = {
          style = 'rounded',
        },
        max_width = 80,
        max_height = 40,
      },

      -- Options for built-in selector
      builtin = {
        -- Display numbers for options and set max width
        show_numbers = true,
        border = 'rounded',
        -- 'editor' and 'win' will default to being centered
        relative = 'editor',

        -- Window transparency (0-100)
        winblend = 10,

        -- Change default highlight groups
        winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',

        -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        width = nil,
        max_width = 0.8,
        min_width = 40,
        height = nil,
        max_height = 0.9,
        min_height = 10,
      },

      -- Used to override format_item
      format_item_override = {},

      -- Set to true to only use your config and disable the vim.ui.select implementation
      override_ui_select = false,
    },
  },
}
