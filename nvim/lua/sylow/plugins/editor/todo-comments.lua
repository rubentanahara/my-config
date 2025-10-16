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
    keywords = {
      FIX = {
        icon = " ", -- icon used for the sign, and in search results
        color = "error", -- can be a hex color, or a named color (see below)
        alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
        signs = false, -- configure signs for some keywords individually
      },
      TODO = { icon = " ", color = "info", alt = { "Personal" } },
      HACK = { icon = " ", color = "warning", alt = { "DON SKIP" } },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO", "READ", "COLORS", "Custom" } },
      TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      FORGETNOT = { icon = " ", color = "hint" },
    },
    -- Patterns for hl markdown support
    highlight = {
      multiline = true,
      multiline_pattern = "^.",
      multiline_context = 10,
      before = "",
      keyword = "wide",
      after = "fg",
      pattern = {
        [[.*<(KEYWORDS)\s*:]],                      -- default pattern
        [[<!--\s*(KEYWORDS)\s*:.*-->]],             -- HTML comments with colon
        [[<!--\s*(KEYWORDS)\s*.*-->]],              -- HTML comments without colon
      },
      comments_only = false,                        -- highlighting outside of comments
    },
    search = {
      command = "rg",
      args = {
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
      },
      pattern = [[\b(KEYWORDS)\b]],
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
