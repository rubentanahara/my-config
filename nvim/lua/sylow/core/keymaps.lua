local utils = require("sylow.core.utils")
local is_available = utils.is_available
local maps = utils.get_mappings_template()

maps.i['jk'] = { '<ESC>', desc = 'Exit insert mode' }
maps.n['j'] = { "v:count == 0 ? 'gj' : 'j'", expr = true, desc = 'Move cursor down' }
maps.n['k'] = { "v:count == 0 ? 'gk' : 'k'", expr = true, desc = 'Move cursor up' }
maps.n['0'] = { '^', desc = 'First non-blank character' }
maps.i['<C-b>'] = { '<ESC>^i', desc = 'Beginning of line' }
maps.i['<C-e>'] = { '<ESC>$a', desc = 'End of line' }
-- Window splitting
maps.n['ss'] = { '<cmd>split<cr>', desc = 'Split horizontal' }
maps.n['sv'] = { '<cmd>vsplit<cr>', desc = 'Split vertical' }
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

maps.n['<esc>'] = { '<cmd>noh<cr><esc>', desc = 'Clear search highlight' }
maps.n['<leader><CR>'] = { utils.clear_search, desc = 'Clear search highlight' }

maps.n['<C-s>'] = { '<cmd>w<cr>', desc = 'Save file' }
maps.n['<C-q>'] = { '<cmd>q<cr>', desc = 'Quit' }
maps.n['<leader>n'] = { '<cmd>enew<cr>', desc = 'New file' }
maps.n['gx'] = { utils.open_with_program, desc = 'Open file under cursor' }
-- Thank you primeagen!
maps.v['J'] = { ":m '>+1<CR>gv=gv", desc = 'Move line up' }
maps.v['K'] = { ":m '>-2<CR>gv=gv", desc = 'Move line down' }
--
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

if is_available('gitsigns.nvim') then
  maps.n[']g'] = {
    function()
      require('gitsigns').nav_hunk('next')
    end,
    desc = 'Next Git hunk',
  }
  maps.n['[g'] = {
    function()
      require('gitsigns').nav_hunk('prev')
    end,
    desc = 'Previous Git hunk',
  }
  maps.n['<leader>gl'] = {
    function()
      require('gitsigns').blame_line()
    end,
    desc = 'View Git blame',
  }
  maps.n['<leader>gL'] = {
    function()
      require('gitsigns').blame_line { full = true }
    end,
    desc = 'View full Git blame',
  }
  maps.n['<leader>gp'] = {
    function()
      require('gitsigns').preview_hunk()
    end,
    desc = 'Preview Git hunk',
  }
  maps.n['<leader>gh'] = {
    function()
      require('gitsigns').reset_hunk()
    end,
    desc = 'Reset Git hunk',
  }
  maps.n['<leader>gr'] = {
    function()
      require('gitsigns').reset_buffer()
    end,
    desc = 'Reset Git buffer',
  }
  maps.n['<leader>gs'] = {
    function()
      require('gitsigns').stage_hunk()
    end,
    desc = 'Stage Git hunk',
  }
  maps.n['<leader>gS'] = {
    function()
      require('gitsigns').stage_buffer()
    end,
    desc = 'Stage Git buffer',
  }
  maps.n['<leader>gu'] = {
    function()
      require('gitsigns').undo_stage_hunk()
    end,
    desc = 'Unstage Git hunk',
  }
  maps.n['<leader>gd'] = {
    function()
      require('gitsigns').diffthis()
    end,
    desc = 'View Git diff',
  }
end

if is_available('vim-fugitive') then
  maps.n['<leader>gP'] = {
    function()
      vim.cmd(':GBrowse')
    end,
    desc = 'Open in github ',
  }
end

-- Toggle folds
maps.n['<leader>zc'] = { 'zc', desc = 'Close fold' }
maps.n['<leader>zo'] = { 'zo', desc = 'Open fold' }
maps.n['<leader>za'] = { 'za', desc = 'Toggle fold' }
maps.n['<leader>zC'] = { 'zM', desc = 'Close all folds' }
maps.n['<leader>zA'] = { 'zR', desc = 'Open all folds' }
maps.n['<leader>zX'] = { 'zx', desc = 'Update folds' }

-- Fold navigation
maps.n['[z'] = { '[z', desc = 'Go to start of current fold' }
maps.n[']z'] = { ']z', desc = 'Go to end of current fold' }

-- Window splitting
maps.n['ss'] = { '<cmd>split<cr>', desc = 'Split horizontal' }
maps.n['sv'] = { '<cmd>vsplit<cr>', desc = 'Split vertical' }
maps.n['[d'] = { vim.diagnostic.goto_prev, desc = 'Previous diagnostic' }
maps.n[']d'] = { vim.diagnostic.goto_next, desc = 'Next diagnostic' }
maps.n['gl'] = { vim.diagnostic.open_float, desc = 'Show diagnostic' }
maps.n['<leader>xd'] = { vim.diagnostic.open_float, desc = 'Line diagnostics' }

--TODO: Make the file for ui stuff
-- maps.n['<leader>ub'] = { ui.toggle_background, desc = 'Background' }
-- maps.n['<leader>tn'] = { ui.change_number, desc = 'Toggle line numbers' }
-- maps.n['<leader>ti'] = { ui.set_indent, desc = 'Set indentation' }
-- maps.n['<leader>ts'] = { ui.toggle_spell, desc = 'Toggle spell check' }
-- maps.n['<leader>tw'] = { ui.toggle_wrap, desc = 'Toggle word wrap' }
-- maps.n['<leader>tc'] = { ui.toggle_conceal, desc = 'Toggle conceal' }
-- maps.n['<leader>tf'] = { ui.toggle_autoformat, desc = 'Toggle autoformat' }
-- maps.n['<leader>td'] = { ui.toggle_diagnostics, desc = 'Toggle diagnostics' }
-- maps.n['<leader>tg'] = { ui.toggle_signcolumn, desc = 'Toggle signcolumn' }
-- maps.n['<leader>tl'] = { ui.toggle_statusline, desc = 'Toggle statusline' }
-- maps.n['<leader>tP'] = { ui.toggle_paste, desc = 'Toggle paste mode' }
-- maps.n['<leader>tt'] = { ui.toggle_tabline, desc = 'Toggle tabline' }
-- maps.n['<leader>tu'] = { ui.toggle_url_effect, desc = 'Toggle URL highlight' }
-- maps.n['<leader>ty'] = { ui.toggle_buffer_syntax, desc = 'Toggle syntax highlight (buffer)' }
-- maps.n['<leader>th'] = { ui.toggle_foldcolumn, desc = 'Toggle foldcolumn' }
-- maps.n['<leader>tN'] = { ui.toggle_ui_notifications, desc = 'UI notifications' }
-- if is_available('zen-mode.nvim') then
--   maps.n['<leader>tz'] = { ui.toggle_zen_mode, desc = 'Zen mode' }
-- end

maps.n['<leader>pl'] = { '<cmd>Lazy<cr>', desc = 'Open Lazy' }

utils.set_mappings(maps, { silent = true, noremap = true })

