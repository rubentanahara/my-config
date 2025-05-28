local utils = require('sylow.core.utils')

-- Base dependencies used by other plugins
-- This file contains core utility plugins that other plugins depend on
return {
  {
    'nvim-lua/plenary.nvim',
    lazy = true,
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
    'SmiteshP/nvim-navic',
    lazy = true,
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
    'echasnovski/mini.icons',
    lazy = true,
    opts = {
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
        [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
        [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
        ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
        ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
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
    'MunifTanjim/nui.nvim',
    lazy = true,
  },
}
