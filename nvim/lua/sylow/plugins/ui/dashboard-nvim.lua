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
        '                                                     ',
        '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ',
        '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
        '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
        '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
        '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
        '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
        '                                                     ',
      },
      center = {
        {
          action = 'Telescope find_files',
          desc = ' Find file',
          icon = ' ',
          key = 'f',
        },
        {
          action = 'ene | startinsert',
          desc = ' New file',
          icon = get_icon('GreeterNew'),
          key = 'n',
        },
        {
          action = 'Telescope oldfiles',
          desc = ' Recent files',
          icon = get_icon('GreeterRecent'),
          key = 'r',
        },
        {
          action = 'Telescope live_grep',
          desc = ' Find text',
          icon = ' ',
          key = 'g',
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

        -- Calcular líneas en blanco dinámicamente
        local lines = {}
        local win_height = vim.api.nvim_win_get_height(0)

        -- Calcular cuántas líneas necesitamos
        -- Estimación: header (8) + espacio (1) + center (7×2) + espacio para footer (1)
        local used_lines = 8 + 1 + (7 * 2) + 1
        local padding_lines = math.max(1, win_height - used_lines)

        -- Añadir líneas en blanco
        for _ = 1, padding_lines do
          table.insert(lines, '')
        end

        -- Añadir línea de stats
        table.insert(
          lines,
          '⚡️  Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms'
        )

        return lines
      end,
    },
  },
  init = function()
    -- Ocultar cursor en el dashboard
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
