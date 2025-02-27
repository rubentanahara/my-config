return {
  -- Seamless navigation between tmux panes and vim splits
  {
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>",  "<cmd>TmuxNavigateLeft<cr>",     desc = "Navigate Left" },
      { "<c-j>",  "<cmd>TmuxNavigateDown<cr>",     desc = "Navigate Down" },
      { "<c-k>",  "<cmd>TmuxNavigateUp<cr>",       desc = "Navigate Up" },
      { "<c-l>",  "<cmd>TmuxNavigateRight<cr>",    desc = "Navigate Right" },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate Previous" },
    },
  },

  -- Session management
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      auto_session_enable_last_session = false,
      auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
      auto_session_enabled = true,
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_use_git_branch = true,
    },
  },
}
