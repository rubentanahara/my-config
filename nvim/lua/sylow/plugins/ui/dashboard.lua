local utils = require('sylow.utils')
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
          icon = get_icon('Find'),
          key = 'f',
        },
        {
          action = 'e $MYVIMRC',
          desc = ' Config',
          icon = get_icon('Vim'),
          key = 'c',
        },
        {
          action = 'qa',
          desc = ' Quit',
          icon = get_icon('BufferClose'),
          key = 'q',
        },
      },
      footer = function()
        local stats = require('lazy').stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

        local lines = {}
        local win_height = vim.api.nvim_win_get_height(0)
        local used_lines = 3 + 1 + (7 * 2)
        local padding_lines = math.max(3, win_height - used_lines)

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
}
