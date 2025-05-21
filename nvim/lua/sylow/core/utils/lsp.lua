local M = {}

local utils = require('sylow.core.utils')
local get_icon = utils.get_icon
local stored_handlers = {}

------------------------------------------
-- LSP Configuration
------------------------------------------

--- Apply default settings for diagnostics, formatting, and lsp capabilities
--- @return nil
function M.apply_default_lsp_settings()
  -- Icons
  -- Apply the icons defined in ../icons/icons.lua
  local signs = {
    { name = 'DiagnosticSignError', text = get_icon('DiagnosticError'), texthl = 'DiagnosticSignError' },
    { name = 'DiagnosticSignWarn', text = get_icon('DiagnosticWarn'), texthl = 'DiagnosticSignWarn' },
    { name = 'DiagnosticSignHint', text = get_icon('DiagnosticHint'), texthl = 'DiagnosticSignHint' },
    { name = 'DiagnosticSignInfo', text = get_icon('DiagnosticInfo'), texthl = 'DiagnosticSignInfo' },
    { name = 'DapStopped', text = get_icon('DapStopped'), texthl = 'DiagnosticWarn' },
    { name = 'DapBreakpoint', text = get_icon('DapBreakpoint'), texthl = 'DiagnosticInfo' },
    { name = 'DapBreakpointRejected', text = get_icon('DapBreakpointRejected'), texthl = 'DiagnosticError' },
    { name = 'DapBreakpointCondition', text = get_icon('DapBreakpointCondition'), texthl = 'DiagnosticInfo' },
    { name = 'DapLogPoint', text = get_icon('DapLogPoint'), texthl = 'DiagnosticInfo' },
  }
  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, sign)
  end

  -- Apply default lsp hover borders
  -- Applies the option lsp_round_borders_enabled from ../options.lua
  M.lsp_hover_config = vim.g.lsp_round_borders_enabled and { border = 'rounded', silent = true } or {}

  local default_diagnostics = {
    virtual_text = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = get_icon('DiagnosticError'),
        [vim.diagnostic.severity.HINT] = get_icon('DiagnosticHint'),
        [vim.diagnostic.severity.WARN] = get_icon('DiagnosticWarn'),
        [vim.diagnostic.severity.INFO] = get_icon('DiagnosticInfo'),
      },
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = 'minimal',
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    },
  }

  -- Apply default diagnostics
  -- Applies the option diagnostics_mode from ../1-options.lua
  M.diagnostics = {
    -- diagnostics off
    [0] = vim.tbl_deep_extend(
      'force',
      default_diagnostics,
      { underline = false, virtual_text = false, signs = false, update_in_insert = false }
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
  local lsp_mappings = require('sylow.core.mappings').lsp_mappings(client, bufnr)

  -- Add LSP label to visual mode if mappings exist
  if not vim.tbl_isempty(lsp_mappings.v) then
    lsp_mappings.v['<leader>l'] = { desc = utils.get_icon('ActiveLSP', true) .. 'LSP' }
  end

  -- Apply the mappings to the buffer
  utils.set_mappings(lsp_mappings, { buffer = bufnr })
end

------------------------------------------
-- LSP Server Configuration
------------------------------------------
function M.apply_user_lsp_settings(server_name)
  print(tostring(M.apply_user_lsp_settings(server_name)))
  local server = require('lspconfig')[server_name]

  M.capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Enhanced completion capabilities
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

  -- Folding capabilities
  M.capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  -- Setup flags and merge with server options
  M.flags = {}
  local opts = vim.tbl_deep_extend('force', server, {
    capabilities = M.capabilities,
    flags = M.flags,
  })

  -- Server-specific configurations
  if server_name == 'jsonls' then
    -- Add JSON schema support
    local schema_loaded, schemastore = pcall(require, 'schemastore')
    if schema_loaded then
      opts.settings = {
        json = {
          schemas = schemastore.json.schemas(),
          validate = { enable = true },
        },
      }
    end
  elseif server_name == 'yamlls' then
    -- Add YAML schema support
    local schema_loaded, schemastore = pcall(require, 'schemastore')
    if schema_loaded then
      opts.settings = {
        yaml = {
          schemas = schemastore.yaml.schemas(),
        },
      }
    end
  end

  -- Preserve original on_attach and extend with our mappings
  local old_on_attach = server.on_attach
  opts.on_attach = function(client, bufnr)
    if type(old_on_attach) == 'function' then
      old_on_attach(client, bufnr)
    end

    -- Apply our custom mappings
    M.apply_user_lsp_mappings(client, bufnr)
  end

  return opts
end

function M.setup(server)
  -- Get custom settings for the server
  local opts = M.apply_user_lsp_settings(server)

  -- Get the setup handler
  local setup_handler = stored_handlers[server] or require('lspconfig')[server].setup(opts)

  -- Apply settings using the handler if available
  if setup_handler then
    setup_handler(server, opts)
  end
end

return M
