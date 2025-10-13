local utils = require('sylow.utils')
local get_icon = utils.get_icon

-- Local helper functions for better performance
local function jump_next_todo()
  require('todo-comments').jump_next()
end

local function jump_prev_todo()
  require('todo-comments').jump_prev()
end

-- Key mappings definition
local keys = {
  {
    ']t',
    jump_next_todo,
    desc = 'Next Todo Comment',
  },
  {
    '[t',
    jump_prev_todo,
    desc = 'Previous Todo Comment',
  },
  {
    '<leader>xt',
    '<cmd>Trouble todo toggle<cr>',
    desc = 'Todo (Trouble)',
  },
  {
    '<leader>st',
    '<cmd>TodoTelescope<cr>',
    desc = 'Todo',
  },
  {
    '<leader>sT',
    '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>',
    desc = 'Todo/Fix/Fixme',
  },
}

-- Custom configuration with your icons
local function setup_todo_comments()
  return {
    signs = true,
    sign_priority = 8,
    search = {
      command = 'rg',
      args = {
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
      },
      pattern = [[\b(KEYWORDS):]],
    },
  }
end

return {
  {
    'folke/todo-comments.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope', 'TodoQuickFix', 'TodoLocList' },
    event = { 'BufReadPost', 'BufNewFile' },
    keys = keys,
    opts = setup_todo_comments,
  },
}
--FIX:
--Fix this issue please
--TEST:
--Test this
--PERF:
--Better performance
--HACK:
--Hacking
--NOTE:
--This is a note
--WARN:
--Warning
--TODO:
