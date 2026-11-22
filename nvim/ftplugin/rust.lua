local function map(lhs, command, desc)
  vim.keymap.set('n', lhs, command, { buffer = true, desc = desc })
end

map('<leader>Rt', '<cmd>RustLsp testables<cr>', 'Rust testables')
map('<leader>RT', '<cmd>RustLsp! testables<cr>', 'Rust re-run last test')
map('<leader>Rd', '<cmd>RustLsp debuggables<cr>', 'Rust debuggables')
map('<leader>RD', '<cmd>RustLsp! debuggables<cr>', 'Rust re-debug last')
map('<leader>Rr', '<cmd>RustLsp runnables<cr>', 'Rust runnables')
map('<leader>Ra', '<cmd>botright split | terminal cargo test --workspace<cr>', 'Rust test all')
