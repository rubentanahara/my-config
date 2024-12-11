return {
  {
    -- Flutter tools for Neovim
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- Optional UI enhancement
    },
    config = function()
      require("flutter-tools").setup({
        -- Configure Flutter tools
        widget_guides = {
          enabled = true, -- Highlights widget tree
        },
        lsp = {
          color = { -- Show LSP errors/warnings with colors
            enabled = true,
            background = true,
          },
          settings = {
            dart = {
              lineLength = 100, -- Example setting
            },
          },
        },
      })
    end,
  },
  {
    -- Snippets support
    "L3MON4D3/LuaSnip",
  },
  {
    -- Debugging
    "mfussenegger/nvim-dap",
    dependencies = {
      "theHamsta/nvim-dap-virtual-text",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local dap = require("dap")
      require("dapui").setup()
      -- Configure Dart Debug Adapter
      dap.adapters.dart = {
        type = "executable",
        command = "dart",
        args = { "debug_adapter" },
      }
      dap.configurations.dart = {
        {
          type = "dart",
          request = "launch",
          name = "Launch Flutter",
          program = "${workspaceFolder}/lib/main.dart",
        },
      }
    end,
  },
}
