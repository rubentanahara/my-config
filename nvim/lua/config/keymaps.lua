-- GENERAL
-- INSERT
vim.keymap.set("i", "jk", "<ESC>", { noremap = true, silent = true, desc = "Exit edit mode" })
vim.keymap.set("i", "<C-b>", "<ESC>^i", { noremap = true, silent = true, desc = "Beggining of line" })
vim.keymap.set("i", "<C-e>", "<ESC>$a", { noremap = true, silent = true, desc = "End of line" })
vim.keymap.set("i", "<C-w>l", "<Left>", { noremap = true, silent = true, desc = "Move Left" })
vim.keymap.set("i", "<C-w>k", "<Up>", { noremap = true, silent = true, desc = "Move Up" })
vim.keymap.set("i", "<C-w>j", "<Down>", { noremap = true, silent = true, desc = "Move Down" })
vim.keymap.set("i", "<C-w>h", "<Right>", { noremap = true, silent = true, desc = "Move Right" })

-- NORMAL
vim.keymap.set("n", "<C-j>", ":m .+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
vim.keymap.set("n", "<C-k>", ":m .-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })
vim.keymap.set("n", "<C-s>", ":w<CR>", { noremap = true, silent = true, desc = "Save File" })
vim.keymap.set("n", "<C-q>", ":wqa<CR>", { noremap = true, silent = true, desc = "Save and quit" })
vim.keymap.set(
  "n",
  "x",
  '"_x',
  { noremap = true, silent = true, desc = "Delete single character without copying into register" }
)
vim.keymap.set("n", "+", "<C-a>", { noremap = true, silent = true, desc = "Increment" })
vim.keymap.set("n", "-", "<C-x>", { noremap = true, silent = true, desc = "Decrement" })

vim.keymap.set("n", "ss", ":split<CR>", { noremap = true, silent = true, desc = "Horizontal Window Split" })
vim.keymap.set("n", "sv", ":vsplit<CR>", { noremap = true, silent = true, desc = "Vertical Window Split" })

vim.keymap.set("n", "<C-w><up>", ":resize +3<CR>", { noremap = true, silent = true, desc = "Resize Horizontal Up" })
vim.keymap.set("n", "<C-w><down>", ":resize -3<CR>", { noremap = true, silent = true, desc = "Resize Horizontal Down" })
vim.keymap.set(
  "n",
  "<C-w><left>",
  ":vertical resize +3<CR>",
  { noremap = true, silent = true, desc = "Resize Vertical Left" }
)
vim.keymap.set(
  "n",
  "<C-w><right>",
  ":vertical resize -3<CR>",
  { noremap = true, silent = true, desc = "Resize Vertical Right" }
)

vim.keymap.set(
  "n",
  "<leader>z",
  "<C-\\><C-n>|:DogeGenerate<CR>",
  { noremap = true, silent = true, desc = "Generate docs" }
)

vim.keymap.set(
  "t",
  "<leader>tre",
  "<C-\\><C-n>|:FloatermToggle<CR>",
  { noremap = true, silent = true, desc = "Show float terminal in terminal mode" }
)
vim.keymap.set(
  "n",
  "<leader>tre",
  "<C-\\><C-n>|:FloatermToggle<CR>",
  { noremap = true, silent = true, desc = "Show Float terminal in normal mode" }
)
vim.keymap.set(
  "t",
  "<leader>tp",
  "<C-\\><C-n>|:FloatermPrev<CR>",
  { noremap = true, silent = true, desc = "Prev terminal" }
)
vim.keymap.set(
  "t",
  "<leader>tn",
  "<C-\\><C-n>|:FloatermNext<CR>",
  { noremap = true, silent = true, desc = "Next terminal" }
)

vim.keymap.set("n", "wh", "<C-w>h")
vim.keymap.set("n", "wk", "<C-w>k")
vim.keymap.set("n", "wj", "<C-w>j")
vim.keymap.set("n", "wl", "<C-w>l")

--VISUAL
vim.keymap.set(
  "x",
  "<C-j>",
  ":move '>+1<CR>gv-gv",
  { noremap = true, silent = true, desc = "Move lines down in visual mode" }
)
vim.keymap.set(
  "x",
  "<C-k>",
  ":move '<-2<CR>gv-gv",
  { noremap = true, silent = true, desc = "Move lines up in visual mode" }
)

vim.keymap.set(
  "n",
  "<leader>gb",
  ":Gitsigns blame_line<CR>",
  { noremap = true, silent = true, desc = "Quemador de gente" }
)

local function wrapInConsoleLog()
  local mode = vim.api.nvim_get_mode().mode
  local text

  if mode == "n" then
    text = vim.api.nvim_get_current_line()
    local logStatement = "console.log(" .. text:gsub("%s+", "") .. ");"
    local lineNumber = vim.api.nvim_win_get_cursor(0)[1] -- Get the current line number
    vim.api.nvim_buf_set_lines(0, lineNumber - 1, lineNumber, false, { logStatement })
  else
    return
  end
end

vim.keymap.set(
  { "n", "v" },
  "<leader>cz",
  wrapInConsoleLog,
  { noremap = true, silent = true, desc = "Wrap in console.log" }
)

-- Key mappings for neotest
-- Run the nearest test
vim.api.nvim_set_keymap(
  "n",
  "<leader>tn",
  ":lua require('neotest').run.run()<CR>",
  { noremap = true, silent = true, desc = "Run nearest test" }
)

-- Run all tests in the current file
vim.api.nvim_set_keymap(
  "n",
  "<leader>tf",
  ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
  { noremap = true, silent = true, desc = "Run all tests in current file" }
)

-- Toggle the test summary window
vim.api.nvim_set_keymap(
  "n",
  "<leader>ts",
  ":lua require('neotest').summary.toggle()<CR>",
  { noremap = true, silent = true, desc = "Toggle test summary window" }
)

-- Open the output of the last test run
vim.api.nvim_set_keymap(
  "n",
  "<leader>to",
  ":lua require('neotest').output.open({ enter = true })<CR>",
  { noremap = true, silent = true, desc = "Open test output window" }
)

-- Key mappings for debugging with nvim-dap
-- Toggle a breakpoint at the current line
vim.api.nvim_set_keymap(
  "n",
  "<leader>db",
  ":lua require('dap').toggle_breakpoint()<CR>",
  { noremap = true, silent = true, desc = "Toggle breakpoint" }
)

-- Continue execution until the next breakpoint
vim.api.nvim_set_keymap(
  "n",
  "<leader>dc",
  ":lua require('dap').continue()<CR>",
  { noremap = true, silent = true, desc = "Continue execution" }
)

-- Step into the function under the cursor
vim.api.nvim_set_keymap(
  "n",
  "<leader>di",
  ":lua require('dap').step_into()<CR>",
  { noremap = true, silent = true, desc = "Step into function" }
)

-- Step over the function under the cursor
vim.api.nvim_set_keymap(
  "n",
  "<leader>do",
  ":lua require('dap').step_over()<CR>",
  { noremap = true, silent = true, desc = "Step over function" }
)

-- Step out of the current function
vim.api.nvim_set_keymap(
  "n",
  "<leader>du",
  ":lua require('dap').step_out()<CR>",
  { noremap = true, silent = true, desc = "Step out of function" }
)

-- Open the REPL for nvim-dap
vim.api.nvim_set_keymap(
  "n",
  "<leader>dr",
  ":lua require('dap').repl.open()<CR>",
  { noremap = true, silent = true, desc = "Open REPL" }
)
