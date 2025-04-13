local M = {}
local utils = require("base.utils")
local get_icon = utils.get_icon
local is_available = utils.is_available
local ui = require("base.utils.ui")
local maps = require("base.utils").get_mappings_template()

-- icons displayed on which-key.nvim ---------------------------------------
local icons = {
  f = { desc = get_icon("Find", true) .. " Find" },
  p = { desc = get_icon("Packages", true) .. " Packages" },
  l = { desc = get_icon("LSP", true) .. " LSP" },
  u = { desc = get_icon("UI", true) .. " UI" },
  b = { desc = get_icon("Buffer", true) .. " Buffers" },
  bs = { desc = get_icon("Sort", true) .. " Sort Buffers" },
  c = { desc = get_icon("Run", true) .. " Compiler" },
  d = { desc = get_icon("Debugger", true) .. " Debugger" },
  tt = { desc = get_icon("Test", true) .. " Test" },
  dc = { desc = get_icon("Docs", true) .. " Docs" },
  g = { desc = get_icon("Git", true) .. " Git" },
  S = { desc = get_icon("Session", true) .. " Session" },
  t = { desc = get_icon("Terminal", true) .. " Terminal" },
}

function M.setup()
  local map = vim.keymap.set

  map("n", "<leader>l", ":Lazy<CR>", {
    noremap = true,
    silent = true,
    desc = "Open Lazy (Lazy.nvim)",
  })

  map("n", "<leader>lc", ":LazyConfig<CR>", {
    noremap = true,
    silent = true,
    desc = "Open Lazy Config (Lazy.nvim)",
  })

  map("n", "<leader>li", ":LazyInstall<CR>", {
    noremap = true,
    silent = true,
    desc = "Install Lazy Plugins (Lazy.nvim)",
  })

  map("n", "<leader>lu", ":LazyUpdate<CR>", {
    noremap = true,
    silent = true,
    desc = "Update Lazy Plugins (Lazy.nvim)",
  })

  map("n", "<leader>ld", ":LazyDebug<CR>", {
    noremap = true,
    silent = true,
    desc = "Debug Lazy Plugins (Lazy.nvim)",
  })

  -- Toggle line numbers
  map("n", "<leader>ln", ":set nu!<CR>", { noremap = true, silent = true, desc = "Toggle Line Numbers" })

  -- Exit insert mode
  map("i", "jk", "<ESC>", { noremap = true, silent = true, desc = "Exit insert mode" })

  -- Save and close
  map("n", "<C-s>", ":w<CR>", { noremap = true, silent = true, desc = "Save File" })
  map("n", "<C-q>", ":wqa<CR>", { noremap = true, silent = true, desc = "Save and quit" })

  -- quit
  map("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "Quit All Force" })

  -- Navigate within insert mode
  map("i", "<C-b>", "<ESC>^i", { noremap = true, silent = true, desc = "Go to beginning of line" })
  map("i", "<C-e>", "<ESC>$a", { noremap = true, silent = true, desc = "Go to end of line" })

  -- better up/down
  map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
  map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
  map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
  map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

  -- Move Lines
  map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
  map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
  map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
  map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
  map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
  map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

  -- Clipboard operations
  map({ "n", "v" }, "<leader>y", [["+y]], { noremap = true, silent = true, desc = "Yank to system clipboard" })
  map({ "n", "v" }, "<leader>Y", [["+Y]], { noremap = true, silent = true, desc = "Yank line to system clipboard" })

  -- Delete to void register
  map({ "n", "v" }, "<leader>d", [["_d]], { noremap = true, silent = true, desc = "Delete to void register" })

  -- Resize window using <ctrl> arrow keys
  map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
  map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
  map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
  map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

  -- Better indenting
  -- map("v", "<", "<gv", { noremap = true, silent = true, desc = "Indent left" })
  -- map("v", ">", ">gv", { noremap = true, silent = true, desc = "Indent right" })

  -- Move selected line / block of text in visual mode
  -- map("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move line down" })
  -- map("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move line up" })

  -- Better paste
  map("v", "p", '"_dP', { noremap = true, silent = true, desc = "Better paste" })

  -- Clear search with <esc>
  map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { noremap = true, silent = true, desc = "Clear hlsearch and escape" })

  -- save file
  map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

  --keywordprg
  map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

  -- Clear search, diff update and redraw
  -- taken from runtime/lua/_editor.lua
  map(
    "n",
    "<leader>ur",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Redraw / Clear hlsearch / Diff Update" }
  )

  -- Diagnostic keymaps
  map("n", "[d", vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = "Previous diagnostic" })
  map("n", "]d", vim.diagnostic.goto_next, { noremap = true, silent = true, desc = "Next diagnostic" })
  map("n", "gl", vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Show diagnostic" })

  -- Windows
  map("n", "ss", ":split<CR>", { noremap = true, silent = true, desc = "Horizontal Window Split" })
  map("n", "sv", ":vsplit<CR>", { noremap = true, silent = true, desc = "Vertical Window Split" })

  -- Window resizing
  map("n", "<C-w><up>", ":resize +3<CR>", { noremap = true, silent = true, desc = "Resize Horizontal Up" })
  map("n", "<C-w><down>", ":resize -3<CR>", { noremap = true, silent = true, desc = "Resize Horizontal Down" })
  map("n", "<C-w><left>", ":vertical resize +3<CR>", { noremap = true, silent = true, desc = "Resize Vertical Left" })
  map("n", "<C-w><right>", ":vertical resize -3<CR>", { noremap = true, silent = true, desc = "Resize Vertical Right" })

  -- Useful keymaps
  map("n", "x", '"_x', { noremap = true, silent = true, desc = "Delete single character without copying into register" })
  map("n", "+", "<C-a>", { noremap = true, silent = true, desc = "Increment" })
  map("n", "-", "<C-x>", { noremap = true, silent = true, desc = "Decrement" })

  -- commenting
  map("n", "gcb", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
  map("n", "gca", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })
end

utils.set_mappings(maps)
return M
