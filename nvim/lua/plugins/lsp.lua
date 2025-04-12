return {

  -- Mason
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Open Mason' } },
    build = ':MasonUpdate',
    opts = {
      ensure_installed = {
        -- Formatters
        'stylua',
        'shfmt',
        'black',
        'prettier',
        'prettierd',
        'rustywind',
        'csharpier',
        'dart-debug-adapter',
        'rustfmt',
        'ktlint',

        -- Linters
        'ruff',
        'eslint_d',
        'shellcheck',
        'markdownlint',
        'jsonlint',
        'yamllint',
        'stylelint',
        'cspell',
        'ktlint',
        'codelldb',
        'luacheck',
        'htmlhint',

        -- LSP
        'pyright',
        'lua-language-server',
        'typescript-language-server',
        'html-lsp',
        'css-lsp',
        'gopls',
        'tailwindcss-language-server',
        'rust-analyzer',
        'csharp-language-server',
        'omnisharp',
        'dart-debug-adapter',
        'yaml-language-server',
        'bash-language-server',
        'eslint-lsp',
        'json-lsp',
        'emmet-ls',
        'angular-language-server',
        'kotlin-language-server',

        -- Debug Adapters
        'js-debug-adapter',
        'node-debug2-adapter',
        'chrome-debug-adapter',
        'netcoredbg',
        'codelldb',
        'dart-debug-adapter',
        'kotlin-debug-adapter',
      },
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
      max_concurrent_installers = 10,
    },
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require 'mason-registry'
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- Mason LSP config
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      automatic_installation = true,
    },
  },
  -- Goto Preview
  {
    'rmagatti/goto-preview',
    keys = {
      {
        '<leader>pd',
        function()
          require('goto-preview').goto_preview_definition()
        end,
        desc = 'Preview Definition',
      },
      {
        '<leader>pt',
        function()
          require('goto-preview').goto_preview_type_definition()
        end,
        desc = 'Preview Type Definition',
      },
      {
        '<leader>pi',
        function()
          require('goto-preview').goto_preview_implementation()
        end,
        desc = 'Preview Implementation',
      },
      {
        '<leader>pr',
        function()
          require('goto-preview').goto_preview_references()
        end,
        desc = 'Preview References',
      },
      {
        '<leader>pc',
        function()
          require('goto-preview').close_all_win()
        end,
        desc = 'Close Previews',
      },
    },
    opts = {
      width = 120,
      height = 15,
      border = { '↖', '─', '↗', '│', '↘', '─', '↙', '│' },
      default_mappings = false,
      debug = false,
      opacity = nil,
      resizing_mappings = false,
      post_open_hook = nil,
      references = {
        telescope = require('telescope.themes').get_dropdown { hide_preview = false },
      },
      focus_on_open = false,
      dismiss_on_move = true,
      force_close = true,
      bufhidden = 'wipe',
      stack_floating_preview_windows = true,
      preview_window_title = { enable = true, position = 'left' },
    },
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'folke/neodev.nvim', opts = {} },
      'mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'b0o/schemastore.nvim',
    },
    config = function()
      -- Diagnostic signs
      local diagnostic_signs = {
        { name = 'DiagnosticSignError', text = '󰅚' },
        { name = 'DiagnosticSignWarn', text = '󰀪' },
        { name = 'DiagnosticSignHint', text = '󰌶' },
        { name = 'DiagnosticSignInfo', text = '' },
      }
      for _, sign in ipairs(diagnostic_signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = '' })
      end

      -- Diagnostic configuration
      vim.diagnostic.config {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = 'if_many',
          prefix = '●',
        },
        severity_sort = true,
        float = {
          focusable = true,
          style = 'minimal',
          border = 'rounded',
          source = 'always',
          header = '',
          prefix = '',
        },
      }

      -- LSP handlers configuration
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })

      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help,
        { border = 'rounded' })

      -- LSP servers configuration
      local lspconfig = require 'lspconfig'
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local function on_attach(client, bufnr)
        -- Keymaps
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map('n', 'gd', vim.lsp.buf.definition, 'Goto Definition')
        map('n', 'gr', vim.lsp.buf.references, 'Goto References')
        map('n', 'gD', vim.lsp.buf.declaration, 'Goto Declaration')
        map('n', 'gI', vim.lsp.buf.implementation, 'Goto Implementation')
        map('n', 'K', vim.lsp.buf.hover, 'Hover Documentation')
        map('n', 'gK', vim.lsp.buf.signature_help, 'Signature Documentation')
        map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
        map('n', '<leader>cr', vim.lsp.buf.rename, 'Rename')
        map({ 'n', 'v' }, '<leader>cf', vim.lsp.buf.format, 'Format')
      end

      local dartExcludedFolders = {
        vim.fn.expand '$HOME/AppData/Local/Pub/Cache',
        vim.fn.expand '$HOME/.pub-cache',
        vim.fn.expand '/opt/homebrew/',
        vim.fn.expand '$HOME/tools/flutter/',
      }
      -- Server configurations
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              diagnostics = { globals = { 'vim' } },
              workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
              completion = { callSnippet = 'Replace' },
            },
          },
        },
        gopls = {
          capabilities = capabilities,
          cmd = { 'gopls' },
          filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
          root_dir = 'auto',
          settings = {
            gopls = {
              analysis = {
                unusedparams = true,
              },
              completeUnimported = true,
              usePlaceholders = true,
              updateImportsOnRename = true,
              completeFunctionCalls = true,
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'basic',
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'workspace',
              },
            },
          },
        },
        tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        html = {},
        cssls = {},
        tailwindcss = {},
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = {
                command = 'clippy',
              },
              inlayHints = {
                chainingHints = true,
                parameterHints = true,
                typeHints = true,
              },
            },
          },
        },
        csharp_ls = {},
        omnisharp = {
          capabilities = capabilities,
          filetypes = { 'cs' },
          cmd = { 'omnisharp' },
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
          enable_import_completion = true,
          sdk_include_prereleases = true,
          analyze_open_documents_only = false,
          enable_ms_build_load_projects_on_demand = true,
          enable_editorconfig_support = true,
          enable_package_restore = true,
          on_attach = function(client, bufnr)
            -- Call the default on_attach function
            on_attach(client, bufnr)

            -- Check if easy-dotnet is available
            local has_dotnet, dotnet = pcall(require, 'easy-dotnet')
            if has_dotnet then
              -- Add specific keymaps for C# files
              local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
              end

              -- Add C# specific keymaps
              map('n', '<leader>dt', function()
                dotnet.test()
              end, 'Run .NET Tests')
              map('n', '<leader>dr', function()
                dotnet.run()
              end, 'Run .NET Project')
              map('n', '<leader>db', function()
                dotnet.build()
              end, 'Build .NET Project')
            end
          end,
        },
        dcmls = {
          capabilities = capabilities,
          cmd = {
            'dcm',
            'start-server',
          },
          filetypes = { 'dart', 'yaml' },
          settings = {
            dart = {
              analysisExcludedFolders = dartExcludedFolders,
            },
          },
        },
        dartls = {
          capabilities = capabilities,
          cmd = { 'dart', 'language-server', '--protocol=lsp' },
          filetypes = { 'dart' },
          init_options = {
            closingLabels = true,
            flutterOutline = true,
            onlyAnalyzeProjectsWithOpenFiles = false,
            outline = true,
            suggestFromUnimportedLibraries = true,
          },
          settings = {
            dart = {
              updateImportsOnRename = true,
              completeFunctionCalls = true,
              showTodos = true,
              analysisExcludedFolders = dartExcludedFolders,
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
                ['https://json.schemastore.org/github-action.json'] = '/.github/actions/*/action.yml',
                ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] =
                '*docker-compose*.yml',
                ['https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json'] =
                '*k8s*.yml',
              },
              validate = true,
              format = { enable = true },
            },
          },
        },
        bashls = {},
        eslint = {
          settings = {
            packageManager = 'npm',
            experimental = {
              useFlatConfig = false,
            },
            workingDirectories = { mode = 'auto' },
            codeAction = {
              disableRuleComment = {
                enable = true,
                location = 'separateLine',
              },
              showDocumentation = {
                enable = true,
              },
            },
            format = true,
            nodePath = '',
            onIgnoredFiles = 'off',
            problems = {
              shortenToSingleLine = false,
            },
            quiet = false,
            rulesCustomizations = {},
            run = 'onType',
            useESLintClass = false,
            validate = 'on',
          },
          on_attach = function(client, bufnr)
            -- Disable formatting for ESLint (we'll use prettier instead)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false

            -- Check if we're in a React Native project
            local is_react_native = false
            local package_json = vim.fn.findfile('package.json', vim.fn.expand '%:p:h' .. ';')

            if package_json ~= '' then
              local content = vim.fn.readfile(package_json)
              local package_content = table.concat(content, '\n')
              if package_content:match 'react%-native' then
                is_react_native = true
              end
            end

            -- For React Native projects, be more lenient with ESLint
            if is_react_native then
              -- Add a command to fix all auto-fixable ESLint errors
              vim.api.nvim_buf_create_user_command(bufnr, 'EslintFixAll', function()
                vim.cmd 'EslintFixAll'
              end, { desc = 'Fix all auto-fixable ESLint errors' })
            end
          end,
        },
        jsonls = {
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },
        emmet_ls = {
          filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'svelte' },
        },
        angularls = {},
      }

      -- Setup servers
      for server, config in pairs(servers) do
        config.capabilities = capabilities
        config.on_attach = on_attach
        lspconfig[server].setup(config)
      end
    end,
  },
}
