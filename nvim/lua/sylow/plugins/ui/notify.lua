local utils = require('sylow.core.utils')

return {
  'rcarriga/nvim-notify',
  event = 'User BaseDefered',
  opts = function()
    return {
      timeout = 3500,
      fps = 144,
      render = 'wrapped-compact',
      stages = 'slide',
      top_down = false,
      icons = {
        DEBUG = utils.get_icon('Debugger'),
        ERROR = utils.get_icon('DiagnosticError'),
        INFO = utils.get_icon('DiagnosticInfo'),
        TRACE = utils.get_icon('DiagnosticHint'),
        WARN = utils.get_icon('DiagnosticWarn'),
      },
      max_height = function()
        return math.floor(vim.o.lines * 0.5)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.5)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 175 })
        if not vim.g.notifications_enabled then
          vim.api.nvim_win_close(win, true)
        end
        if not package.loaded['nvim-treesitter'] then
          pcall(require, 'nvim-treesitter')
        end
        vim.wo[win].conceallevel = 3
        local buf = vim.api.nvim_win_get_buf(win)
        if not pcall(vim.treesitter.start, buf, 'markdown') then
          vim.bo[buf].syntax = 'markdown'
        end
        vim.wo[win].spell = false
      end,
    }
  end,
  config = function(_, opts)
    local notify = require('notify')
    notify.setup(opts)
    vim.notify = notify
  end,
}
