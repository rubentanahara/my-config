local utils = require('sylow.core.utils')
local get_icon = utils.get_icon

local mode = {
  'mode',
  fmt = function(str)
    return get_icon('Vim') .. str
  end,
}

local filename = {
  'filename',
  file_status = true, -- displays file status (readonly status, modified status)
  path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
}

local hide_in_width = function()
  return vim.fn.winwidth(0) > 100
end

local diagnostics = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  sections = { 'error', 'warn', 'info', 'hint' },
  symbols = {
    error = get_icon('DiagnosticError'),
    warn = get_icon('DiagnosticWarn'),
    info = get_icon('DiagnosticInfo'),
    hint = get_icon('DiagnosticHint'),
  },
  colored = true,
  update_in_insert = true,
  cond = hide_in_width,
}

local diff = {
  'diff',
  colored = true,
  symbols = {
    added = get_icon('GitAdd'),
    modified = get_icon('GitChange'),
    removed = get_icon('GitDelete'),
  }, -- changes diff symbols
  cond = hide_in_width,
}

return -- Status line
{
  'nvim-lualine/lualine.nvim',
  lazy = false,
  opts = {
    options = {
      icons_enabled = true,
      globalstatus = vim.o.laststatus == 3,
      theme = 'auto',
      section_separators = {
        left = '',
        right = '',
      },
      component_separators = {
        left = '',
        right = '',
      },
      -- disabled_filetypes = { 'alpha', 'neo-tree' },
      always_divide_middle = true,
    },
    sections = {
      lualine_a = { mode },
      lualine_b = { 'branch' },
      lualine_c = { filename },
      lualine_x = {
        diagnostics,
        diff,
        {
          'encoding',
          cond = hide_in_width,
        },
        {
          'filetype',
          cond = hide_in_width,
        },
      },
      lualine_y = {
        {
          'progress',
          separator = ' ',
          padding = {
            left = 1,
            right = 0,
          },
        },
        {
          'location',
          padding = {
            left = 0,
            right = 1,
          },
        },
      },
      lualine_z = {
        function()
          -- 12-hour format with AM/PM
          return ' ' .. os.date('%I:%M %p')
          -- 24 format
          -- return " " .. os.date("%R")
        end,
      },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { {
        'filename',
        path = 1,
      } },
      lualine_x = { {
        'location',
        padding = 0,
      } },
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    extensions = { 'fugitive', 'nvim-tree', 'quickfix' },
  }
}
