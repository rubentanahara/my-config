local utils = require('sylow.utils')
local get_icon = utils.get_icon

-- Buffer-related mappings
local buffer_mappings = {
  { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous buffer', mode = 'n' },
  { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer', mode = 'n' },
  { '[B', '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer prev', mode = 'n' },
  { ']B', '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer next', mode = 'n' },
  { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = 'Toggle pin', mode = 'n' },
  { '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<cr>', desc = 'Delete non-pinned buffers', mode = 'n' },
  { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Delete other buffers', mode = 'n' },
  { '<leader>br', '<cmd>BufferLineCloseRight<cr>', desc = 'Delete buffers to the right', mode = 'n' },
  { '<leader>bl', '<cmd>BufferLineCloseLeft<cr>', desc = 'Delete buffers to the left', mode = 'n' },
  { '<leader>bd', '<cmd>Bdelete<cr>', desc = 'Delete Buffer', mode = 'n' },
  { '<leader>bD', '<cmd>Bdelete!<cr>', desc = 'Delete Buffer (Force)', mode = 'n' },
}

return {
  {
    'famiu/bufdelete.nvim',
    lazy = false,
  },
  {
    'akinsho/bufferline.nvim',
    lazy = false,
    version = '*',
    keys = buffer_mappings,
    opts = {
      options = {
        mode = 'buffers',
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level)
          local icon_map = {
            error = 'DiagnosticError',
            warning = 'DiagnosticWarn',
            info = 'DiagnosticInfo',
            hint = 'DiagnosticHint',
          }
          local icon_name = icon_map[(level or ''):lower()] or ''
          local icon = get_icon(icon_name)
          return ' ' .. icon .. count
        end,

        -- Offsets configuration
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'Explorer',
            highlight = 'Directory',
            text_align = 'left',
            separator = true,
          },
        },

        -- General options
        always_show_bufferline = true,
        separator_style = 'thin',
        modified_icon = get_icon('FileModified'),
        close_icon = get_icon('BufferClose'),
        left_trunc_marker = '',
        max_name_length = 30,
        -- tab_size = 30,

        -- Display options
        update_in_insert = true,
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        move_wraps_at_ends = true,
        right_mouse_command = 'bdelete! %d',
        right_trunc_marker = get_icon('ArrowRight'),
        show_tab_indicators = false,

        indicator = {
          style = 'icon',
          icon = get_icon('BufferLineIndicator'),
        },

        name_formatter = function(buf)
          return buf.name
        end,
        numbers = function(opts)
          return string.format('%s', opts.ordinal)
        end,
        custom_filter = function(buf_number, _)
          local ft = vim.bo[buf_number].filetype
          if ft == 'neo-tree' then
            return false
          end
          return true
        end,
      },
      highlights = {
        fill = {
          fg = { attribute = 'fg', highlight = 'Normal' },
          bg = { attribute = 'bg', highlight = 'Normal' },
        },
        buffer_visible = {
          fg = { attribute = 'fg', highlight = 'Normal' },
          bg = { attribute = 'bg', highlight = 'Normal' },
        },
        buffer_selected = {
          fg = { attribute = 'fg', highlight = 'Normal' },
          bg = { attribute = 'bg', highlight = 'Normal' },
        },
        separator_selected = {
          fg = { attribute = 'fg', highlight = 'Special' },
          bg = { attribute = 'bg', highlight = 'Normal' },
        },
        separator_visible = {
          fg = { attribute = 'fg', highlight = 'Normal' },
          bg = { attribute = 'bg', highlight = 'StatusLineNC' },
        },
        close_button_selected = {
          fg = { attribute = 'fg', highlight = 'Normal' },
          bg = { attribute = 'bg', highlight = 'Normal' },
        },
        close_button_visible = {
          fg = { attribute = 'fg', highlight = 'Normal' },
          bg = { attribute = 'bg', highlight = 'Normal' },
        },
      },
    },
  },
}
