local M = {}

local utils = require('sylow.core.utils')
local get_icon = utils.get_icon

function M.apply_default_lsp_settings()
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

  M.formatting = { format_on_save = { enabled = false }, disabled = {} }

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

  if not vim.tbl_isempty(lsp_mappings.v) then
    lsp_mappings.v['<leader>l'] = { desc = utils.get_icon('ActiveLSP') .. 'LSP' }
  end

  utils.set_mappings(lsp_mappings, { buffer = bufnr, silent = true })
end

function M.apply_user_lsp_settings(server_name)
  local lspconfig = require('lspconfig') -- Added missing require

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

  M.capabilities.textDocument.formatting = true

  M.flags = {}

  -- Get the server configuration from lspconfig
  local server_config = lspconfig[server_name] or {}

  local opts = vim.tbl_deep_extend('force', server_config, {
    capabilities = M.capabilities,
    flags = M.flags,
  })

  -- Server-specific configurations
  if server_name == 'omnisharp' then
    local pid = vim.fn.getpid()
    opts.cmd = { 'omnisharp', '--languageserver', '--hostPID', tostring(pid) }
    -- Add on_attach and on_init if you have them defined elsewhere
    -- opts.on_attach = your_on_attach_function
    -- opts.on_init = your_on_init_function
    opts.filetypes = { 'cs', 'vb' }
    opts.root_dir = lspconfig.util.root_pattern('.sln', '.csproj', '.git')
    opts.commands = {
      OmniSharpRestart = {
        function()
          lspconfig.omnisharp.restart()
        end,
        description = 'Restart OmniSharp server',
      },
    }
    opts.settings = {
      omnisharp = {
        enableRoslynAnalyzers = true,
        enableEditorConfigSupport = true,
        enableImportCompletion = true,
        sdkPath = vim.env.MSBuildSDKsPath,
        organizeImportsOnFormat = false,
        enableDecompilationSupport = true,
        enableAsyncCompletion = true,
        supportsFileManipulation = true,
      },
    }
  elseif server_name == 'ts_ls' then
    local function organize_imports()
      local params = {
        command = '_typescript.organizeImports',
        arguments = { vim.api.nvim_buf_get_name(0) },
      }
      vim.lsp.buf.execute_command(params)
    end
    opts.filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
    }

    opts.init_options = {
      preferences = {
        disableSuggestions = false,
      },
    }

    opts.commands = {
      OrganizeImports = {
        organize_imports,
        description = 'Organize Imports',
      },
    }
  elseif server_name == 'jsonls' then
    local schema_loaded, schemastore = pcall(require, 'schemastore')
    if schema_loaded then
      opts.filetypes = { 'json', 'jsonc' }
      opts.settings = {
        json = {
          schemas = schemastore.json.schemas(),
          validate = { enable = true },
        },
      }
    end
  elseif server_name == 'yamlls' then
    local schema_loaded, schemastore = pcall(require, 'schemastore')
    if schema_loaded then
      opts.filetypes = { 'yaml', 'yml' }
      opts.settings = {
        yaml = {
          schemas = schemastore.yaml.schemas(),
        },
      }
    end
  elseif server_name == 'dartls' then
    opts.mason = false
    opts.cmd = { 'dart', 'language-server', '--protocol=lsp' }
    opts.filetypes = { 'dart' }
    opts.init_options = {
      onlyAnalyzeProjectsWithOpenFiles = false,
      suggestFromUnimportedLibraries = true,
      closingLabels = true,
      outline = false,
      flutterOutline = false,
    }
    opts.settings = {
      dart = {
        analysisExcludedFolders = {
          vim.fn.expand('$HOME/AppData/Local/Pub/Cache'),
          vim.fn.expand('$HOME/.pub-cache'),
          vim.fn.expand('/opt/homebrew/'),
          vim.fn.expand('$HOME/tools/flutter/'),
        },
        updateImportsOnRename = true,
        completeFunctionCalls = true,
        showTodos = true,
      },
    }
  elseif server_name == 'kotlin_language_server' then
    opts.filetypes = { 'kotlin' }
    opts.root_dir =
      lspconfig.util.root_pattern('settings.gradle', 'settings.gradle.kts', 'build.gradle', 'build.gradle.kts', '.git')
    opts.single_file_support = true
    opts.init_options = {
      compilerOptions = {
        jvmTarget = '1.8',
      },
      linting = {
        disabledRules = { 'no-wildcard-imports', 'filename' },
      },
    }
  elseif server_name == 'rust_analyzer' then
    -- Rust Analyzer Configuration
    opts.filetypes = { 'rust' }
    opts.root_dir = lspconfig.util.root_pattern('Cargo.toml', 'rust-project.json', '.git')
    opts.single_file_support = true

    opts.settings = {
      ['rust-analyzer'] = {
        -- Cargo settings
        cargo = {
          allFeatures = true, -- Enable all Cargo features
          loadOutDirsFromCheck = true, -- Load OUT_DIR from cargo check
          runBuildScripts = true, -- Run build scripts
          autoreload = true, -- Auto-reload workspace on Cargo.toml changes
        },

        -- Clippy (linter) integration
        checkOnSave = {
          enable = true,
          command = 'clippy', -- Use clippy for linting
          extraArgs = {
            '--all-targets',
            '--all-features',
            '--',
            '-W',
            'clippy::all',
            '-W',
            'clippy::pedantic',
          },
        },

        -- Proc macros support
        procMacro = {
          enable = true,
          attributes = {
            enable = true,
          },
        },

        -- Inlay hints (inline type hints)
        inlayHints = {
          enable = true,
          chainingHints = {
            enable = true,
          },
          closingBraceHints = {
            enable = true,
            minLines = 10,
          },
          closureReturnTypeHints = {
            enable = 'always',
          },
          discriminantHints = {
            enable = 'always',
          },
          lifetimeElisionHints = {
            enable = 'skip_trivial',
            useParameterNames = true,
          },
          parameterHints = {
            enable = true,
          },
          typeHints = {
            enable = true,
            hideClosureInitialization = false,
            hideNamedConstructor = false,
          },
        },

        -- Diagnostics settings
        diagnostics = {
          enable = true,
          experimental = {
            enable = true,
          },
          disabled = {}, -- Add any diagnostics you want to disable here
        },

        -- Completion settings
        completion = {
          autoimport = {
            enable = true,
          },
          autoself = {
            enable = true,
          },
          callable = {
            snippets = 'fill_arguments', -- Auto-fill function arguments
          },
          postfix = {
            enable = true, -- Enable postfix completions (.if, .match, etc.)
          },
          privateEditable = {
            enable = false,
          },
        },

        -- Hover actions
        hover = {
          actions = {
            enable = true,
            implementations = {
              enable = true,
            },
            references = {
              enable = true,
            },
            run = {
              enable = true,
            },
            debug = {
              enable = true,
            },
          },
          documentation = {
            enable = true,
          },
          links = {
            enable = true,
          },
        },

        -- Lens (codelens) settings
        lens = {
          enable = true,
          debug = {
            enable = true,
          },
          implementations = {
            enable = true,
          },
          references = {
            adt = {
              enable = true,
            },
            enumVariant = {
              enable = true,
            },
            method = {
              enable = true,
            },
            trait = {
              enable = true,
            },
          },
          run = {
            enable = true,
          },
        },

        -- Assist (code actions) settings
        assist = {
          importGranularity = 'module',
          importPrefix = 'by_self',
        },

        -- Semantic highlighting
        semanticHighlighting = {
          strings = {
            enable = true,
          },
        },

        -- Workspace settings
        workspace = {
          symbol = {
            search = {
              kind = 'all_symbols',
            },
          },
        },
      },
    }

    -- Rust-specific commands
    opts.commands = {
      RustAnalyzerRestart = {
        function()
          lspconfig.rust_analyzer.manager.try_add_wrapper()
        end,
        description = 'Restart rust-analyzer server',
      },
    }
  end

  return opts
end

function M.setup(server)
  local lspconfig = require('lspconfig') -- Added missing require
  local opts = M.apply_user_lsp_settings(server)

  -- Setup the LSP server
  lspconfig[server].setup(opts)
end

return M
