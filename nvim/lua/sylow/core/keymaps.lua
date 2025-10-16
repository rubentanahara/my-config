local utils = require('sylow.utils')
local ui = require('sylow.utils.ui')
local maps = utils.get_mappings_template()

maps.i['jk'] = { '<ESC>', desc = 'Exit insert mode' }
maps.n['j'] = { "v:count == 0 ? 'gj' : 'j'", expr = true, desc = 'Move cursor down' }
maps.n['k'] = { "v:count == 0 ? 'gk' : 'k'", expr = true, desc = 'Move cursor up' }
maps.n['0'] = { '^', desc = 'First non-blank character' }
maps.i['<C-b>'] = { '<ESC>^i', desc = 'Beginning of line' }
maps.i['<C-e>'] = { '<ESC>$a', desc = 'End of line' }
maps.n['ss'] = { '<cmd>split<cr>', desc = 'Split horizontal' }
maps.n['sv'] = { '<cmd>vsplit<cr>', desc = 'Split vertical' }
maps.n['<leader>se'] = { '<C-w>=', desc = 'Equalize splits' }
maps.n['<leader>sc'] = { '<cmd>close<cr>', desc = 'Close current split' }
maps.n['gg'] = {
  function()
    utils.without_animation(function()
      if vim.v.count > 0 then
        vim.cmd('normal! ' .. vim.v.count .. 'gg')
      else
        vim.cmd('normal! gg0')
      end
    end)
  end,
  desc = 'Go to first line and column',
}
maps.n['G'] = {
  function()
    utils.without_animation(function()
      vim.cmd('normal! G$')
    end)
  end,
  desc = 'Go to last line and column',
}
maps.x['gg'] = {
  function()
    utils.without_animation(function()
      if vim.v.count > 0 then
        vim.cmd('normal! ' .. vim.v.count .. 'gg')
      else
        vim.cmd('normal! gg0')
      end
    end)
  end,
  desc = 'Go to first line and column (visual)',
}
maps.x['G'] = {
  function()
    utils.without_animation(function()
      vim.cmd('normal! G$')
    end)
  end,
  desc = 'Go to last line and column (visual)',
}
maps.n['<leader><CR>'] = { utils.clear_search, desc = 'Clear search highlight' }
maps.n['<C-s>'] = { '<cmd>w<cr>', desc = 'Save file' }
maps.n['<C-q>'] = { '<cmd>q<cr>', desc = 'Quit' }
maps.n['<leader>n'] = { '<cmd>enew<cr>', desc = 'New file' }
maps.n['gx'] = { utils.open_with_program, desc = 'Open file under cursor' }

maps.n['<A-j>'] = { ":m '.+1<CR>gv==", desc = 'Move selection down' }
maps.n['<A-k>'] = { ":m '.-2<CR>gv==", desc = 'Move selection up' }
maps.v['<A-j>'] = { ":m '>+1<CR>gv=gv", desc = 'Move selection down' }
maps.v['<A-k>'] = { ":m '<-2<CR>gv=gv", desc = 'Move selection up' }
maps.v['<'] = { '<gv', desc = 'Unindent line' }
maps.v['>'] = { '>gv', desc = 'Indent line' }
maps.x['<S-Tab>'] = { '<gv', desc = 'Unindent line' }
maps.x['<Tab>'] = { '>gv', desc = 'Indent line' }
maps.x['<'] = { '<gv', desc = 'Unindent line' }
maps.x['>'] = { '>gv', desc = 'Indent line' }
maps.n['x'] = {
  function()
    if vim.fn.col '.' == 1 then
      local line = vim.fn.getline '.'
      if line:match '^%s*$' then
        vim.api.nvim_feedkeys('"_dd', 'n', false)
        vim.api.nvim_feedkeys('$', 'n', false)
      else
        vim.api.nvim_feedkeys('"_x', 'n', false)
      end
    else
      vim.api.nvim_feedkeys('"_x', 'n', false)
    end
  end,
  desc = 'Delete character (no yank)',
}
maps.n['X'] = {
  function()
    if vim.fn.col '.' == 1 then
      local line = vim.fn.getline '.'
      if line:match '^%s*$' then
        vim.api.nvim_feedkeys('"_dd', 'n', false)
        vim.api.nvim_feedkeys('$', 'n', false)
      else
        vim.api.nvim_feedkeys('"_X', 'n', false)
      end
    else
      vim.api.nvim_feedkeys('"_X', 'n', false)
    end
  end,
  desc = 'Delete character backward (no yank)',
}
maps.x['x'] = { '"_x', desc = 'Delete without yanking' }
maps.x['X'] = { '"_X', desc = 'Delete backward without yanking' }
maps.v['p'] = { 'P', desc = 'Paste without yanking' }
maps.v['P'] = { 'p', desc = 'Paste and yank' }
maps.n['+'] = { '<C-a>', desc = 'Increment number' }
maps.n['-'] = { '<C-x>', desc = 'Decrement number' }
maps.n['gcb'] = { 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', desc = 'Comment below' }
maps.n['gca'] = { 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', desc = 'Comment above' }
maps.n['<leader>zc'] = { 'zc', desc = 'Close fold' }
maps.n['<leader>zo'] = { 'zo', desc = 'Open fold' }
maps.n['<leader>za'] = { 'za', desc = 'Toggle fold' }
maps.n['<leader>zC'] = { 'zM', desc = 'Close all folds' }
maps.n['<leader>zA'] = { 'zR', desc = 'Open all folds' }
maps.n['<leader>zX'] = { 'zx', desc = 'Update folds' }
maps.n['[z'] = { '[z', desc = 'Go to start of current fold' }
maps.n[']z'] = { ']z', desc = 'Go to end of current fold' }
maps.n['[d'] = { vim.diagnostic.get_prev, desc = 'Previous diagnostic' }
maps.n[']d'] = { vim.diagnostic.get_next, desc = 'Next diagnostic' }
maps.n['gl'] = { vim.diagnostic.open_float, desc = 'Show diagnostic' }
maps.n['<leader>xd'] = { vim.diagnostic.open_float, desc = 'Line diagnostics' }
maps.n['<leader>ub'] = { ui.toggle_background, desc = 'Background' }
maps.n['<leader>tn'] = { ui.change_number, desc = 'Toggle line numbers' }
maps.n['<leader>ti'] = { ui.set_indent, desc = 'Set indentation' }
maps.n['<leader>ts'] = { ui.toggle_spell, desc = 'Toggle spell check' }
maps.n['<leader>tw'] = { ui.toggle_wrap, desc = 'Toggle word wrap' }
maps.n['<leader>tc'] = { ui.toggle_conceal, desc = 'Toggle conceal' }
maps.n['<leader>tf'] = { ui.toggle_autoformat, desc = 'Toggle autoformat' }
maps.n['<leader>td'] = { ui.toggle_diagnostics, desc = 'Toggle diagnostics' }
maps.n['<leader>tg'] = { ui.toggle_signcolumn, desc = 'Toggle signcolumn' }
maps.n['<leader>tl'] = { ui.toggle_statusline, desc = 'Toggle statusline' }
maps.n['<leader>tP'] = { ui.toggle_paste, desc = 'Toggle paste mode' }
maps.n['<leader>tt'] = { ui.toggle_tabline, desc = 'Toggle tabline' }
maps.n['<leader>tu'] = { ui.toggle_url_effect, desc = 'Toggle URL highlight' }
maps.n['<leader>ty'] = { ui.toggle_buffer_syntax, desc = 'Toggle syntax highlight (buffer)' }
maps.n['<leader>th'] = { ui.toggle_foldcolumn, desc = 'Toggle foldcolumn' }
maps.n['<leader>tN'] = { ui.toggle_ui_notifications, desc = 'UI notifications' }
maps.n['<leader>tz'] = { ui.toggle_zen_mode, desc = 'Zen mode' }
maps.n['<leader>pl'] = { '<cmd>Lazy<cr>', desc = 'Open Lazy' }

utils.set_mappings(maps, { silent = true, noremap = true })
