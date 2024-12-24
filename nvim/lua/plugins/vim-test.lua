return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux",
  },
  vim.keymap.set("n", "<leader>t", ":TestNearest<CR>", { noremap = true, silent = true, desc = "Run nearest test" }),
  vim.keymap.set("n", "<leader>T", ":TestFile<CR>", { noremap = true, silent = true, desc = "Run all tests in file" }),
  vim.keymap.set("n", "<leader>a", ":TestSuite<CR>", { noremap = true, silent = true, desc = "Run test suite" }),
  vim.keymap.set("n", "<leader>l", ":TestLast<CR>", { noremap = true, silent = true, desc = "Run last test" }),
  vim.keymap.set("n", "<leader>g", ":TestVisit<CR>", { noremap = true, silent = true, desc = "Visit test file" }),
  vim.cmd("let test#strategy = 'vimux'"),
}
