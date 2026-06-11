return {
  {
    'jubnzv/mdeval.nvim',
    ft = { 'markdown', 'markdown.pandoc', 'vimwiki', 'org', 'norg' },
    cmd = { 'MdEval', 'MdEvalClean' },
    keys = {
      { '<leader>ce', '<cmd>MdEval<cr>', desc = 'MdEval (run code block)' },
      { '<leader>cE', '<cmd>MdEvalClean<cr>', desc = 'MdEval (clean results)' },
    },
    opts = {
      -- skip the per-run prompt; matches the one-keypress flow used for sniprun
      require_confirmation = false,
      -- seconds before a block is killed (wraps gtimeout); guards against hangs since io.popen blocks
      exec_timeout = 30,
    },
  },
}
