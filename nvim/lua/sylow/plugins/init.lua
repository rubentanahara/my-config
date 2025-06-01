local utils = require('sylow.core.utils')

return {
  {
    'nvim-lua/plenary.nvim',
    lazy = true,
  },

  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
  },
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
    event = 'User BaseDeferred', -- Fixed typo from "BaseDefered"
    opts = {
      override = {
        default_icon = {
          icon = utils.get_icon('DefaultFile'),
        },
      },
      strict = true,
    },
  },
  {
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    lazy = true,
    'folke/zen-mode.nvim',
    opts = {},
  },
  {
    'SmiteshP/nvim-navic',
    lazy = false,
    opts = function()
      return {
        separator = utils.icons.PathSeparator,
        highlight = true,
        depth_limit = 5,
        icons = utils.icons.LSP_KINDS,
        lazy_update_context = true,
      }
    end,
  },
  {
    'MunifTanjim/nui.nvim',
    lazy = true,
  },
}
