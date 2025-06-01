local utils = require('sylow.core.utils')
local ui = require('sylow.core.utils.ui')
local is_available = utils.is_available

local M = {}

local function create_mapping_table()
  return utils.get_mappings_template()
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

  if is_available('zen-mode.nvim') then
    maps.n['<leader>tz'] = { ui.toggle_zen_mode, desc = 'Zen mode' }
  end

  maps.n['<leader>pl'] = { '<cmd>Lazy<cr>', desc = 'Open Lazy' }

  return maps
end

function M.lsp_mappings(client, bufnr)
  -- Helper function to check if any active LSP clients
  -- given a filter provide a specific capability.
  -- @param capability string The server capability to check for (example: "documentFormattingProvider").
  -- @param filter vim.lsp.get_clients.filter|nil A valid get_clients filter (see function docs).
  -- @return boolean # `true` if any of the clients provide the capability.
  local function has_capability(capability, filter)
    for _, lsp_client in ipairs(vim.lsp.get_clients(filter)) do
      if lsp_client.supports_method(capability) then
        return true
      end
    end
    return false
  end

  local lsp_mappings = require('sylow.core.utils').get_mappings_template()

  -- Diagnostics
  lsp_mappings.n['<leader>ld'] = {
    function()
      vim.diagnostic.open_float()
    end,
    desc = 'Hover diagnostics',
  }
  lsp_mappings.n['[d'] = {
    function()
      vim.diagnostic.jump({ count = -1 })
    end,
    desc = 'Previous diagnostic',
  }
  lsp_mappings.n[']d'] = {
    function()
      vim.diagnostic.jump({ count = 1 })
    end,
    desc = 'Next diagnostic',
  }

  -- Diagnostics
  lsp_mappings.n['gl'] = {
    function()
      vim.diagnostic.open_float()
    end,
    desc = 'Hover diagnostics',
  }
  if is_available('telescope.nvim') then
    lsp_mappings.n['<leader>lD'] = {
      function()
        require('telescope.builtin').diagnostics()
      end,
      desc = 'Diagnostics',
    }
  end

  -- LSP info
  if is_available('mason-lspconfig.nvim') then
    lsp_mappings.n['<leader>li'] = { '<cmd>LspInfo<cr>', desc = 'LSP information' }
  end

  if is_available('none-ls.nvim') then
    lsp_mappings.n['<leader>lI'] = { '<cmd>NullLsInfo<cr>', desc = 'Null-ls information' }
  end

  -- Code actions
  lsp_mappings.n['<leader>la'] = {
    function()
      vim.lsp.buf.code_action()
    end,
    desc = 'LSP code action',
  }
  lsp_mappings.v['<leader>la'] = lsp_mappings.n['<leader>la']

  -- Codelens
  utils.add_autocmds_to_buffer('lsp_codelens_refresh', bufnr, {
    events = { 'InsertLeave' },
    desc = 'Refresh codelens',
    callback = function(args)
      if client.supports_method('textDocument/codeLens') then
        if vim.g.codelens_enabled then
          vim.lsp.codelens.refresh({ bufnr = args.buf })
        end
      end
    end,
  })
  if client.supports_method('textDocument/codeLens') then -- on LspAttach
    if vim.g.codelens_enabled then
      vim.lsp.codelens.refresh({ bufnr = 0 })
    end
  end

  lsp_mappings.n['<leader>ll'] = {
    function()
      vim.lsp.codelens.run()
      vim.lsp.codelens.refresh({ bufnr = 0 })
    end,
    desc = 'LSP CodeLens run',
  }
  lsp_mappings.n['<leader>uL'] = {
    function()
      ui.toggle_codelens()
    end,
    desc = 'CodeLens',
  }

  -- Formatting (keymapping)
  local formatting = require('sylow.core.utils.lsp').formatting
  local format_opts = require('sylow.core.utils.lsp').format_opts
  lsp_mappings.n['<leader>lf'] = {
    function()
      vim.lsp.buf.format(format_opts)
      vim.cmd('checktime') -- Sync buffer with changes
    end,
    desc = 'Format buffer',
  }
  lsp_mappings.v['<leader>lf'] = lsp_mappings.n['<leader>lf']

  -- Formatting (command)
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
    vim.lsp.buf.format(format_opts)
  end, { desc = 'Format file with LSP' })

  -- Autoformatting (autocmd)
  local autoformat = formatting.format_on_save
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })

  -- guard clauses
  local is_autoformat_enabled = autoformat.enabled
  local is_filetype_allowed = vim.tbl_isempty(autoformat.allow_filetypes or {})
    or vim.tbl_contains(autoformat.allow_filetypes, filetype)
  local is_filetype_ignored = vim.tbl_isempty(autoformat.ignore_filetypes or {})
    or not vim.tbl_contains(autoformat.ignore_filetypes, filetype)

  if is_autoformat_enabled and is_filetype_allowed and is_filetype_ignored then
    utils.add_autocmds_to_buffer('lsp_auto_format', bufnr, {
      events = 'BufWritePre', -- Trigger before save
      desc = 'Autoformat on save',
      callback = function()
        -- guard clause: has_capability
        if not has_capability('textDocument/formatting', { bufnr = bufnr }) then
          utils.del_autocmds_from_buffer('lsp_auto_format', bufnr)
          return
        end

        -- Get autoformat setting (buffer or global)
        local autoformat_enabled = vim.b.autoformat_enabled or vim.g.autoformat_enabled
        local has_no_filter = not autoformat.filter
        local passes_filter = autoformat.filter and autoformat.filter(bufnr)

        -- Use these variables in the if condition
        if autoformat_enabled and (has_no_filter or passes_filter) then
          vim.lsp.buf.format(vim.tbl_deep_extend('force', format_opts, { bufnr = bufnr }))
        end
      end,
    })
  end

  -- Highlight references when cursor holds
  utils.add_autocmds_to_buffer('lsp_document_highlight', bufnr, {
    {
      events = { 'CursorHold', 'CursorHoldI' },
      desc = 'highlight references when cursor holds',
      callback = function()
        if has_capability('textDocument/documentHighlight', { bufnr = bufnr }) then
          vim.lsp.buf.document_highlight()
        end
      end,
    },
    {
      events = { 'CursorMoved', 'CursorMovedI', 'BufLeave' },
      desc = 'clear references when cursor moves',
      callback = function()
        vim.lsp.buf.clear_references()
      end,
    },
  })

  -- Other LSP mappings
  lsp_mappings.n['<leader>lL'] = {
    function()
      vim.api.nvim_command(':LspRestart')
    end,
    desc = 'LSP refresh',
  }

  -- Goto definition / declaration
  lsp_mappings.n['gd'] = {
    function()
      vim.lsp.buf.definition()
    end,
    desc = 'Goto definition of current symbol',
  }
  lsp_mappings.n['gD'] = {
    function()
      vim.lsp.buf.declaration()
    end,
    desc = 'Goto declaration of current symbol',
  }

  -- Goto implementation
  lsp_mappings.n['gI'] = {
    function()
      vim.lsp.buf.implementation()
    end,
    desc = 'Goto implementation of current symbol',
  }

  -- Goto type definition
  lsp_mappings.n['gT'] = {
    function()
      vim.lsp.buf.type_definition()
    end,
    desc = 'Goto definition of current type',
  }

  -- Goto references
  lsp_mappings.n['<leader>lR'] = {
    function()
      vim.lsp.buf.references()
    end,
    desc = 'Hover references',
  }
  lsp_mappings.n['gr'] = {
    function()
      vim.lsp.buf.references()
    end,
    desc = 'References of current symbol',
  }

  -- Goto help
  local lsp_hover_config = require('sylow.core.utils.lsp').lsp_hover_config
  lsp_mappings.n['gh'] = {
    function()
      vim.lsp.buf.hover(lsp_hover_config)
    end,
    desc = 'Hover help',
  }
  lsp_mappings.n['gH'] = {
    function()
      vim.lsp.buf.signature_help(lsp_hover_config)
    end,
    desc = 'Signature help',
  }

  lsp_mappings.n['<leader>lh'] = {
    function()
      vim.lsp.buf.hover(lsp_hover_config)
    end,
    desc = 'Hover help',
  }
  lsp_mappings.n['<leader>lH'] = {
    function()
      vim.lsp.buf.signature_help(lsp_hover_config)
    end,
    desc = 'Signature help',
  }

  -- Goto man
  lsp_mappings.n['gm'] = {
    function()
      vim.api.nvim_feedkeys('K', 'n', false)
    end,
    desc = 'Hover man',
  }
  lsp_mappings.n['<leader>lm'] = {
    function()
      vim.api.nvim_feedkeys('K', 'n', false)
    end,
    desc = 'Hover man',
  }

  -- Rename symbol
  lsp_mappings.n['<leader>lr'] = {
    function()
      vim.lsp.buf.rename()
    end,
    desc = 'Rename current symbol',
  }

  -- Toggle inlay hints
  if vim.b.inlay_hints_enabled == nil then
    vim.b.inlay_hints_enabled = vim.g.inlay_hints_enabled
  end
  if vim.b.inlay_hints_enabled then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
  lsp_mappings.n['<leader>uH'] = {
    function()
      require('sylow.core.utils.ui').toggle_buffer_inlay_hints(bufnr)
    end,
    desc = 'LSP inlay hints (buffer)',
  }

  -- Toggle semantic tokens
  if vim.g.semantic_tokens_enabled then
    vim.b[bufnr].semantic_tokens_enabled = true
    lsp_mappings.n['<leader>uY'] = {
      function()
        require('sylow.core.utils.ui').toggle_buffer_semantic_tokens(bufnr)
      end,
      desc = 'LSP semantic highlight (buffer)',
    }
  else
    client.server_capabilities.semanticTokensProvider = nil
  end

  -- LSP based search
  lsp_mappings.n['<leader>lS'] = {
    function()
      vim.lsp.buf.workspace_symbol()
    end,
    desc = 'Search symbol in workspace',
  }
  lsp_mappings.n['gS'] = {
    function()
      vim.lsp.buf.workspace_symbol()
    end,
    desc = 'Search symbol in workspace',
  }

  -- LSP telescope
  if is_available('telescope.nvim') then -- setup telescope mappings if available
    if lsp_mappings.n.gd then
      lsp_mappings.n.gd[1] = function()
        require('telescope.builtin').lsp_definitions()
      end
    end
    if lsp_mappings.n.gI then
      lsp_mappings.n.gI[1] = function()
        require('telescope.builtin').lsp_implementations()
      end
    end
    if lsp_mappings.n.gr then
      lsp_mappings.n.gr[1] = function()
        require('telescope.builtin').lsp_references()
      end
    end
    if lsp_mappings.n['<leader>lR'] then
      lsp_mappings.n['<leader>lR'][1] = function()
        require('telescope.builtin').lsp_references()
      end
    end
    if lsp_mappings.n.gy then
      lsp_mappings.n.gy[1] = function()
        require('telescope.builtin').lsp_type_definitions()
      end
    end
    if lsp_mappings.n['<leader>lS'] then
      lsp_mappings.n['<leader>lS'][1] = function()
        vim.ui.input({ prompt = 'Symbol Query: (leave empty for word under cursor)' }, function(query)
          if query then
            -- word under cursor if given query is empty
            if query == '' then
              query = vim.fn.expand('<cword>')
            end
            require('telescope.builtin').lsp_workspace_symbols({
              query = query,
              prompt_title = ('Find word (%s)'):format(query),
            })
          end
        end)
      end
    end
    if lsp_mappings.n['gS'] then
      lsp_mappings.n['gS'][1] = function()
        vim.ui.input({ prompt = 'Symbol Query: (leave empty for word under cursor)' }, function(query)
          if query then
            -- word under cursor if given query is empty
            if query == '' then
              query = vim.fn.expand('<cword>')
            end
            require('telescope.builtin').lsp_workspace_symbols({
              query = query,
              prompt_title = ('Find word (%s)'):format(query),
            })
          end
        end)
      end
    end
  end

  return lsp_mappings
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
