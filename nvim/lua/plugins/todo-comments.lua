-- Highlight todo, notes, etc in comments
-- TODO: Testing
-- FIXME: Testing
-- NOTE: Testing
-- HACK: Testing
-- XXX: Testing
-- BUG: Testing
-- OPTIMIZE: Testing
-- WARNING: Testing
-- INFO: Testing
-- PERFORMANCE: Testing
return {
  "folke/todo-comments.nvim",
  event = "VimEnter",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = { signs = false },
}
