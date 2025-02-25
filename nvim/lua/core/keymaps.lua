local M = {}

function M.setup()
  local map = vim.keymap.set

  -- Exit insert mode
  map("i", "jk", "<ESC>", { noremap = true, silent = true, desc = "Exit insert mode" })

  -- Save and close
  map("n", "<C-s>", ":w<CR>", { noremap = true, silent = true, desc = "Save File" })
  map("n", "<C-q>", ":wqa<CR>", { noremap = true, silent = true, desc = "Save and quit" })

  -- Navigate within insert mode
  map("i", "<C-b>", "<ESC>^i", { noremap = true, silent = true, desc = "Go to beginning of line" })
  map("i", "<C-e>", "<ESC>$a", { noremap = true, silent = true, desc = "Go to end of line" })

  -- Better window navigation
  map("n", "<c-j>", ":m .+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
  map("n", "<c-k>", ":m .-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })

  -- Clipboard operations
  map({ "n", "v" }, "<leader>y", [["+y]], { noremap = true, silent = true, desc = "Yank to system clipboard" })
  map({ "n", "v" }, "<leader>Y", [["+Y]], { noremap = true, silent = true, desc = "Yank line to system clipboard" })
  map({ "n", "v" }, "<leader>p", [["+p]], { noremap = true, silent = true, desc = "Paste from system clipboard" })
  map({ "n", "v" }, "<leader>P", [["+P]], { noremap = true, silent = true, desc = "Paste from system clipboard before cursor" })
  map("x", "<leader>P", [["_dP]], { noremap = true, silent = true, desc = "Paste and keep register" })

  -- Delete to void register
  map({ "n", "v" }, "<leader>d", [["_d]], { noremap = true, silent = true, desc = "Delete to void register" })

  -- Resize with arrows
  map("n", "<C-Up>", ":resize -2<CR>", { noremap = true, silent = true, desc = "Decrease window height" })
  map("n", "<C-Down>", ":resize +2<CR>", { noremap = true, silent = true, desc = "Increase window height" })
  map("n", "<C-Left>", ":vertical resize -2<CR>", { noremap = true, silent = true, desc = "Decrease window width" })
  map("n", "<C-Right>", ":vertical resize +2<CR>", { noremap = true, silent = true, desc = "Increase window width" })

  -- Better indenting
  map("v", "<", "<gv", { noremap = true, silent = true, desc = "Indent left" })
  map("v", ">", ">gv", { noremap = true, silent = true, desc = "Indent right" })

  -- Move selected line / block of text in visual mode
  map("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move line down" })
  map("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move line up" })

  -- Better paste
  map("v", "p", '"_dP', { noremap = true, silent = true, desc = "Better paste" })

  -- Clear search with <esc>
  map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { noremap = true, silent = true, desc = "Clear hlsearch and escape" })

  -- Save file
  map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { noremap = true, silent = true, desc = "Save file" })

  -- Better movement
  map("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll down and center" })
  map("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll up and center" })

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

  --VISUAL
  map(
    "x",
    "<C-j>",
    ":move '>+1<CR>gv-gv",
    { noremap = true, silent = true, desc = "Move lines down in visual mode" }
  )
  map(
    "x",
    "<C-k>",
    ":move '<-2<CR>gv-gv",
    { noremap = true, silent = true, desc = "Move lines up in visual mode" }
  )
end

return M
