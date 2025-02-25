return {
   -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
    {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    },
  },
{
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace",
      },
    },
  },
	{
		'phaazon/hop.nvim',
		-- event = "VeryLazy",
		branch = 'v2', -- optional but strongly recommended
		enabled = false,
		-- lazy = false,
		keys = {
			{ "s",  ":HopChar2<cr>", "Hop Char2" },
			{ "S",  ":HopWord<cr>",  "Hop Char2" },
			{ "ls", ":HopLine<cr>",  "Hop Line" },
		},
		opts = {
			keys = 'etovxqpdygfblzhckisuran'
		}
		-- config = function()
		-- you can configure Hop the way you like here; see :h hop-config
		-- require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }

		-- vim.api.nvim_set_keymap("n", "s", ":HopChar2<cr>", { silent = true })
		-- vim.api.nvim_set_keymap("n", "S", ":HopWord<cr>", { silent = true })
		-- vim.keymap.set('', 'ls', ":HopLine<CR>", { desc = 'Hop Line', silent = true })
		-- end
	},
{
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
}
