local utils = require('sylow.utils')
local ui = require('sylow.utils.ui')
local is_available = utils.is_available
local get_icon = utils.get_icon

local M = {}

local function get_lsp_mappings(client, bufnr)
  local function has_capability(capability, filter)
    for _, lsp_client in ipairs(vim.lsp.get_clients(filter)) do
      if lsp_client.supports_method(capability, '') then
        return true
      end
    end
    return false
  end

  local lsp_mappings = require('sylow.utils').get_mappings_template()

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

  if is_available('mason-lspconfig.nvim') then
    lsp_mappings.n['<leader>li'] = { '<cmd>LspInfo<cr>', desc = 'LSP information' }
  end

  lsp_mappings.n['<leader>la'] = {
    function()
      vim.lsp.buf.code_action()
    end,
    desc = 'LSP code action',
  }

  lsp_mappings.v['<leader>la'] = lsp_mappings.n['<leader>la']
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

  lsp_mappings.n['<leader>lf'] = {
    function()
      vim.lsp.buf.format(M.format_opts)
      vim.cmd('checktime') -- Sync buffer with changes
    end,
    desc = 'Format buffer',
  }

  lsp_mappings.v['<leader>lf'] = lsp_mappings.n['<leader>lf']

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
    vim.lsp.buf.format(M.format_opts)
  end, { desc = 'Format file with LSP' })

  local autoformat = M.formatting.format_on_save
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })

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
          vim.lsp.buf.format(vim.tbl_deep_extend('force', M.format_opts, { bufnr = bufnr }))
        end
      end,
    })
  end

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

  lsp_mappings.n['<leader>lL'] = {
    function()
      vim.api.nvim_command(':LspRestart')
    end,
    desc = 'LSP refresh',
  }

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

  lsp_mappings.n['gI'] = {
    function()
      vim.lsp.buf.implementation()
    end,
    desc = 'Goto implementation of current symbol',
  }

  lsp_mappings.n['gT'] = {
    function()
      vim.lsp.buf.type_definition()
    end,
    desc = 'Goto definition of current type',
  }

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

  local lsp_hover_config = M.lsp_hover_config
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

  lsp_mappings.n['<leader>lr'] = {
    function()
      vim.lsp.buf.rename()
    end,
    desc = 'Rename current symbol',
  }

  if vim.b.inlay_hints_enabled == nil then
    vim.b.inlay_hints_enabled = vim.g.inlay_hints_enabled
  end
  if vim.b.inlay_hints_enabled then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  lsp_mappings.n['<leader>uH'] = {
    function()
      ui.toggle_buffer_inlay_hints(bufnr)
    end,
    desc = 'LSP inlay hints (buffer)',
  }

  if vim.g.semantic_tokens_enabled then
    vim.b[bufnr].semantic_tokens_enabled = true
    lsp_mappings.n['<leader>uY'] = {
      function()
        require('sylow.utils.ui').toggle_buffer_semantic_tokens(bufnr)
      end,
      desc = 'LSP semantic highlight (buffer)',
    }
  else
    client.server_capabilities.semanticTokensProvider = nil
  end

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

function M.apply_default_lsp_settings()
  local signs = {
    { name = 'DiagnosticSignError',    text = get_icon('DiagnosticError'),        texthl = 'DiagnosticSignError' },
    { name = 'DiagnosticSignWarn',     text = get_icon('DiagnosticWarn'),         texthl = 'DiagnosticSignWarn' },
    { name = 'DiagnosticSignHint',     text = get_icon('DiagnosticHint'),         texthl = 'DiagnosticSignHint' },
    { name = 'DiagnosticSignInfo',     text = get_icon('DiagnosticInfo'),         texthl = 'DiagnosticSignInfo' },
    { name = 'DapStopped',             text = get_icon('DapStopped'),             texthl = 'DiagnosticWarn' },
    { name = 'DapBreakpoint',          text = get_icon('DapBreakpoint'),          texthl = 'DiagnosticInfo' },
    { name = 'DapBreakpointRejected',  text = get_icon('DapBreakpointRejected'),  texthl = 'DiagnosticError' },
    { name = 'DapBreakpointCondition', text = get_icon('DapBreakpointCondition'), texthl = 'DiagnosticInfo' },
    { name = 'DapLogPoint',            text = get_icon('DapLogPoint'),            texthl = 'DiagnosticInfo' },
  }
  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, sign)
  end

  M.lsp_hover_config = vim.g.lsp_round_borders_enabled and { border = 'rounded', silent = true } or {}

  local default_diagnostics = {
    virtual_lines = false,
    virtual_text = true,
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = 'minimal',
      border = 'rounded',
      source = true,
      header = '',
      prefix = '',
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = get_icon('DiagnosticError'),
        [vim.diagnostic.severity.HINT] = get_icon('DiagnosticHint'),
        [vim.diagnostic.severity.WARN] = get_icon('DiagnosticWarn'),
        [vim.diagnostic.severity.INFO] = get_icon('DiagnosticInfo'),
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
        [vim.diagnostic.severity.WARN] = 'WarningMsg',
      },
      active = signs,
    },
  }

  M.diagnostics = {
    -- diagnostics off
    [0] = vim.tbl_deep_extend(
      'force',
      default_diagnostics,
      { underline = true, virtual_text = true, signs = false, update_in_insert = false }
    ),
    -- status only
    vim.tbl_deep_extend('force', default_diagnostics, { virtual_text = false, signs = false }),
    -- virtual text off, signs on
    vim.tbl_deep_extend('force', default_diagnostics, { virtual_text = false }),
    -- all diagnostics on
    default_diagnostics,
  }
  vim.diagnostic.config(M.diagnostics[vim.g.diagnostics_mode])

  M.formatting = { format_on_save = { enabled = true }, disabled = {} }

  if type(M.formatting.format_on_save) == 'boolean' then
    M.formatting.format_on_save = { enabled = M.formatting.format_on_save }
  end

  M.format_opts = vim.deepcopy(M.formatting)
  M.format_opts.disabled = nil
  M.format_opts.format_on_save = nil
  M.format_opts.filter = function(client)
    local filter = M.formatting.filter
    local disabled = M.formatting.disabled or {}
    -- check if client is fully disabled or filtered by function
    return not (vim.tbl_contains(disabled, client.name) or (type(filter) == 'function' and not filter(client)))
  end
end

function M.apply_user_lsp_mappings(client, bufnr)
  local lsp_mappings = get_lsp_mappings(client, bufnr)
  local server_name = client.name

  if server_name ~= 'copilot' then
    local icon = utils.icons.LSP_SERVERS_ICONS[server_name] or get_icon('LSPActive')
    lsp_mappings.v = lsp_mappings.v or {}
    lsp_mappings.v['<leader>l'] = { desc = icon .. ' ' .. server_name }
  end

  utils.set_mappings(lsp_mappings, { buffer = bufnr, silent = true })
end

function M.apply_user_lsp_settings(server_name)
  local lspconfig = require('lspconfig')

  -- Base capabilities
  M.capabilities = vim.lsp.protocol.make_client_capabilities()
  M.capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
  M.capabilities.textDocument.completion.completionItem.snippetSupport = true
  M.capabilities.textDocument.completion.completionItem.preselectSupport = true
  M.capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  M.capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  M.capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  M.capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
  M.capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
  M.capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }
  M.capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  M.flags = {}

  local server_config = lspconfig[server_name] or {}
  local opts = vim.tbl_deep_extend('force', server_config, {
    capabilities = M.capabilities,
    flags = M.flags,
  })

  if server_name == 'lua_ls' then
    opts.settings = {
      Lua = {
        completion = {
          callSnippet = "Replace"
        },
        diagnostics = {
          globals = { 'vim' }
        },
        workspace = {
          checkThirdParty = false
        }
      }
    }
  elseif server_name == 'rust_analyzer' then
    opts.settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
        },
        checkOnSave = {
          enable = true,
          command = 'clippy',
        },
      }
    }
  -- elseif server_name == 'roslyn' then
  --   opts.settings = {
  --     roslyn = {
  --       handlers = {
  --         ["textDocument/definition"] = function(...)
  --           return require("omnisharp_extended").handler(...)
  --         end,
  --       },
  --       keys = {
  --         {
  --           "gd",
  --           utils.is_available("telescope.nvim") and function()
  --             require("omnisharp_extended").telescope_lsp_definitions()
  --           end or function()
  --             require("omnisharp_extended").lsp_definitions()
  --           end,
  --           desc = "Goto Definition",
  --         },
  --       },
  --       enable_roslyn_analyzers = true,
  --       organize_imports_on_format = true,
  --       enable_import_completion = true,
  --       filetypes = { 'cs', 'vb', 'csproj', 'sln', 'slnx', 'props', 'csx', 'targets', 'tproj', 'slngen', 'fproj' },
  --     }
  --   }
  end

  return opts
end

return M
