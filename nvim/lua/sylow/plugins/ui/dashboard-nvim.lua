local utils = require('sylow.core.utils')
local get_icon = utils.get_icon

return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  opts = {
    theme = 'doom',
    hide = {
      statusline = false,
      tabline = false,
      winbar = false,
    },
    config = {
      header = {
        '																																									 ',
        '  ███╗███████╗██╗   ██╗██╗      ██████╗ ██╗    ██╗   ██████╗ ███████╗██╗   ██╗███╗',
        '  ██╔╝██╔════╝╚██╗ ██╔╝██║     ██╔═══██╗██║    ██║   ██╔══██╗██╔════╝██║   ██║╚██║',
        '  ██║ ███████╗ ╚████╔╝ ██║     ██║   ██║██║ █╗ ██║   ██║  ██║█████╗  ██║   ██║ ██║',
        '  ██║ ╚════██║  ╚██╔╝  ██║     ██║   ██║██║███╗██║   ██║  ██║██╔══╝  ╚██╗ ██╔╝ ██║',
        '  ███╗███████║   ██║   ███████╗╚██████╔╝╚███╔███╔╝██╗██████╔╝███████╗ ╚████╔╝ ███║',
        '  ╚══╝╚══════╝   ╚═╝   ╚══════╝ ╚═════╝  ╚══╝╚══╝ ╚═╝╚═════╝ ╚══════╝  ╚═══╝  ╚══╝',
        '                                                                                  ',
      },
      center = {
        {
          action = 'Telescope find_files',
          desc = ' Find file',
          icon = ' ',
          key = 'f',
        },
        {
          action = 'e $MYVIMRC',
          desc = ' Config',
          icon = get_icon('Vim'),
          key = 'c',
        },
        {
          action = 'Lazy',
          desc = ' Lazy',
          icon = get_icon('Lazy'),
          key = 'l',
        },
        {
          action = 'qa',
          desc = ' Quit',
          icon = ' ',
          key = 'q',
        },
      },
      footer = function()
        local stats = require('lazy').stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

        local lines = {}
        local win_height = vim.api.nvim_win_get_height(0)

        local used_lines = 8 + 1 + (7 * 2) + 1
        local padding_lines = math.max(1, win_height - used_lines)

        for _ = 1, padding_lines do
          table.insert(lines, '')
        end

        table.insert(
          lines,
          '⚡️  Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms'
        )

        return lines
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'dashboard',
      callback = function()
        vim.opt.cursorline = false
        vim.opt.cursorcolumn = false
        vim.opt.fillchars:append('eob: ')
      end,
    })

    -- Actualizar footer al cambiar tamaño de ventana
    vim.api.nvim_create_autocmd('VimResized', {
      pattern = '*',
      callback = function()
        if vim.bo.filetype == 'dashboard' then
          vim.cmd('doautocmd FileType dashboard')
        end
      end,
    })
  end,
}
