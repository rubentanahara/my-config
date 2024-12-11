  -- Highlight todo, notes, etc in comments
  -- TODO: Testing
  return { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } }
