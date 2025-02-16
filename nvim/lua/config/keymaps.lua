-- ===========================
-- Neovim Keymaps Configuration
-- ===========================

-- ===========================
-- Options
-- ===========================
local opts = { noremap = true, silent = true }

-- ===========================
-- Helper Functions
-- ===========================
-- (Optional) Define helper functions here if needed

-- ===========================
-- General Keymaps
-- ===========================

-- Exit insert mode
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Navigate within insert mode
vim.keymap.set("i", "<C-b>", "<ESC>^i", { desc = "Go to beginning of line" })
vim.keymap.set("i", "<C-e>", "<ESC>$a", { desc = "Go to end of line" })

-- ===========================
-- Normal Mode Keymaps
-- ===========================

-- **Movement and Editing**

-- Move line up/down
vim.keymap.set("n", "<c-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<c-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- Save and quit
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<C-q>", ":wqa<CR>", { desc = "Save and quit" })

-- Delete single character without copying into register
vim.keymap.set("n", "x", [["_x]], { desc = "Delete single character without yanking" })

-- **Increment/Decrement**

-- Increment/decrement numbers
vim.keymap.set("n", "+", "<C-a>", { desc = "Increment number" })
vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement number" })

-- **Window Management**

-- Split windows
vim.keymap.set("n", "ss", ":split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "sv", ":vsplit<CR>", { desc = "Vertical split" })

-- Resize windows
vim.keymap.set("n", "<C-w>h", "<C-w><", { desc = "Resize window narrower" })
vim.keymap.set("n", "<C-w>l", "<C-w>>", { desc = "Resize window wider" })
vim.keymap.set("n", "<C-w>k", "<C-w>+", { desc = "Increase window height" })
vim.keymap.set("n", "<C-w>j", "<C-w>-", { desc = "Decrease window height" })

-- Navigate to next/previous diagnostic
vim.keymap.set("n", "<C-j>", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<C-k>", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })

-- ===========================
-- Visual Mode Keymaps
-- ===========================

-- Move selected lines up/down
vim.keymap.set("x", "<C-j>", ":move '>+1<CR>gv-gv", { desc = "Move selected lines down" })
vim.keymap.set("x", "<C-k>", ":move '<-2<CR>gv-gv", { desc = "Move selected lines up" })

-- ===========================
-- Additional Useful Keymaps
-- ===========================

-- **Navigation**

-- Jump to start/end of file
vim.keymap.set("n", "gh", "gg", { desc = "Go to start of file" })
vim.keymap.set("n", "gl", "G", { desc = "Go to end of file" })

-- **Editing**

-- Indent/unindent in visual mode
vim.keymap.set("x", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent right" })

-- **Clipboard**

-- Yank to system clipboard
vim.keymap.set("n", "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("x", "<leader>y", [["+y]], { desc = "Yank to system clipboard" })

-- Paste from system clipboard
vim.keymap.set("n", "<leader>p", [["+p]], { desc = "Paste from system clipboard" })
vim.keymap.set("x", "<leader>p", [["+p]], { desc = "Paste from system clipboard" })

-- ===========================
-- End of Keymaps Configuration
-- ===========================
