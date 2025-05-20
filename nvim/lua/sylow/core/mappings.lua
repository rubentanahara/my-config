local utils = require('sylow.core.utils')
local ui = require('sylow.core.utils.ui')
local is_available = utils.is_available

local M = {}

local function create_mapping_table()
  return utils.get_mappings_template()
end

local function has_capability(client, feature)
  return client and client.server_capabilities[feature .. 'Provider'] or false
end

local function without_animation(func)
  vim.g.minianimate_disable = true
  local result = func()
  vim.g.minianimate_disable = false
  return result
end

local function setup_mappings()
  local maps = create_mapping_table()

  maps.n['j'] = { "v:count == 0 ? 'gj' : 'j'", expr = true, desc = 'Move cursor down' }
  maps.n['k'] = { "v:count == 0 ? 'gk' : 'k'", expr = true, desc = 'Move cursor up' }

  maps.n['0'] = { '^', desc = 'First non-blank character' }
  maps.i['<C-b>'] = { '<ESC>^i', desc = 'Beginning of line' }
  maps.i['<C-e>'] = { '<ESC>$a', desc = 'End of line' }

  maps.n['gg'] = {
    function()
      without_animation(function()
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
      without_animation(function()
        vim.cmd('normal! G$')
      end)
    end,
    desc = 'Go to last line and column',
  }

  maps.x['gg'] = {
    function()
      without_animation(function()
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
      without_animation(function()
        vim.cmd('normal! G$')
      end)
    end,
    desc = 'Go to last line and column (visual)',
  }

  maps.i['jk'] = { '<ESC>', desc = 'Exit insert mode' }
  maps.n['<esc>'] = { '<cmd>noh<cr><esc>', desc = 'Clear search highlight' }
  maps.n['<leader><CR>'] = { ui.clear_search, desc = 'Clear search highlight' }

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

  if vim.fn.executable 'lazygit' == 1 then -- if lazygit exists, show it
    maps.n['<leader>gg'] = {
      function()
        local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ';')
        if git_dir ~= '' then
          vim.cmd("TermExec cmd='lazygit && exit'")
        else
          utils.notify('Not a git repository', vim.log.levels.WARN)
        end
      end,
      desc = 'ToggleTerm lazygit',
    }
  end

  if is_available('aerial.nvim') then
    maps.n['<leader>i'] = {
      function()
        require('aerial').toggle()
      end,
      desc = 'Aerial',
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

  if is_available('mini.autopairs') then
    maps.n['<leader>ta'] = { ui.toggle_autopairs, desc = 'Toggle autopairs' }
  end

  if is_available('lsp_signature.nvim') then
    maps.n['<leader>tp'] = { ui.toggle_lsp_signature, desc = 'Togle LSP signature' }
  end

  if is_available('nvim-cmp') then
    maps.n['<leader>uC'] = { ui.toggle_cmp, desc = 'Toggle autocompletion' }
  end

  if is_available('zen-mode.nvim') then
    maps.n['<leader>tz'] = { ui.toggle_zen_mode, desc = 'Zen mode' }
  end

  maps.n['<leader>pl'] = { '<cmd>Lazy<cr>', desc = 'Open Lazy' }

  return maps
end

function M.lsp_mappings(client, bufnr)
  local has_declaration = has_capability(client, 'declaration')
  local has_definition = has_capability(client, 'definition')
  local has_hover = has_capability(client, 'hover')
  local has_implementation = has_capability(client, 'implementation')
  local has_references = has_capability(client, 'references')
  local has_rename = has_capability(client, 'rename')
  local has_typeDefinition = has_capability(client, 'typeDefinition')
  local has_workspace_symbol = has_capability(client, 'workspaceSymbol')
  local has_formatting = has_capability(client, 'documentFormatting')
  local has_codeAction = has_capability(client, 'codeAction')
  local has_signatureHelp = has_capability(client, 'signatureHelp')

  local mappings = utils.get_mappings_template()

  -- Basic LSP mappings
  if has_declaration then
    mappings.n['gD'] = { vim.lsp.buf.declaration, desc = 'Go to declaration' }
  end

  if has_definition then
    mappings.n['gd'] = { vim.lsp.buf.definition, desc = 'Go to definition' }
  end

  if has_hover then
    mappings.n['K'] = { vim.lsp.buf.hover, desc = 'Hover information' }
  end

  if has_implementation then
    mappings.n['gI'] = { vim.lsp.buf.implementation, desc = 'Go to implementation' }
  end

  if has_references then
    mappings.n['gr'] = { vim.lsp.buf.references, desc = 'Go to references' }
  end

  if has_rename then
    mappings.n['<leader>cr'] = { vim.lsp.buf.rename, desc = 'Rename symbol' }
  end

  if has_typeDefinition then
    mappings.n['gT'] = { vim.lsp.buf.type_definition, desc = 'Go to type definition' }
  end

  if has_workspace_symbol then
    mappings.n['<leader>ls'] = { vim.lsp.buf.workspace_symbol, desc = 'Workspace symbols' }
  end

  if has_formatting then
    mappings.n['<leader>lf'] = { vim.lsp.buf.format, desc = 'Format document' }
    mappings.v['<leader>lf'] = { vim.lsp.buf.format, desc = 'Format selection' }
  end

  if has_codeAction then
    mappings.n['<leader>la'] = { vim.lsp.buf.code_action, desc = 'Code actions' }
    mappings.v['<leader>la'] = { vim.lsp.buf.code_action, desc = 'Code actions' }
  end

  if has_signatureHelp then
    mappings.n['<leader>lh'] = { vim.lsp.buf.signature_help, desc = 'Signature help' }
    mappings.i['<C-k>'] = { vim.lsp.buf.signature_help, desc = 'Signature help' }
  end

  -- Label for LSP section in visual mode
  if not vim.tbl_isempty(mappings.v) then
    mappings.v['<leader>l'] = { name = '+lsp' }
  end

  -- Diagnostics
  mappings.n['<leader>ld'] = { vim.diagnostic.open_float, desc = 'Line diagnostics' }
  mappings.n['[d'] = { vim.diagnostic.goto_prev, desc = 'Previous diagnostic' }
  mappings.n[']d'] = { vim.diagnostic.goto_next, desc = 'Next diagnostic' }
  mappings.n['<leader>lq'] = { vim.diagnostic.setloclist, desc = 'Diagnostics list' }

  return mappings
end

function M.setup()
  local success = true

  local maps = setup_mappings()

  local ok, err = pcall(function()
    utils.set_mappings(maps, { silent = true, noremap = true })
  end)

  if not ok then
    vim.notify('Failed to configure keymaps: ' .. tostring(err), vim.log.levels.ERROR)
    success = false
  end

  return success
end

return M
