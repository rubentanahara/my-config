local utils = require('sylow.core.utils')
local get_icon = utils.get_icon

-- Buffer-related mappings
local buffer_mappings = {
  n = {
    ['<S-h>'] = { '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous buffer' },
    ['<S-l>'] = { '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
    ['[B'] = { '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer prev' },
    [']B'] = { '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer next' },

    ['<leader>bp'] = { '<cmd>BufferLineTogglePin<cr>', desc = 'Toggle pin' },
    ['<leader>bP'] = { '<cmd>BufferLineGroupClose ungrouped<cr>', desc = 'Delete non-pinned buffers' },
    ['<leader>bo'] = { '<cmd>BufferLineCloseOthers<cr>', desc = 'Delete other buffers' },
    ['<leader>br'] = { '<cmd>BufferLineCloseRight<cr>', desc = 'Delete buffers to the right' },
    ['<leader>bl'] = { '<cmd>BufferLineCloseLeft<cr>', desc = 'Delete buffers to the left' },
    ['<leader>bd'] = { '<cmd>Bdelete<cr>', desc = 'Delete Buffer' },
    ['<leader>bD'] = { '<cmd>Bdelete!<cr>', desc = 'Delete Buffer (Force)' },
  },
}

utils.set_mappings(buffer_mappings, { noremap = true, silent = true })

local function setup_bufferline()
  local bufferline = require('bufferline')
  bufferline.setup({
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
      tab_size = 20,

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
  })
end

return {
  {
    'akinsho/bufferline.nvim',
    lazy = false,
    version = '*',
    dependencies = {
      'famiu/bufdelete.nvim', -- Move bufdelete as a dependency
    },
    config = function()
      setup_bufferline()

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'neo-tree',
        callback = function(opts)
          vim.schedule(function()
            vim.api.nvim_buf_set_option(opts.buf, 'buflisted', false)
          end)
        end,
      })
    end,
  },
}
