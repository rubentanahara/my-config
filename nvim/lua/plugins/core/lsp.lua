return {
  -- Goto Preview
  {
    "rmagatti/goto-preview",
    keys = {
      { "<leader>pd", function() require("goto-preview").goto_preview_definition() end, desc = "Preview Definition" },
      { "<leader>pt", function() require("goto-preview").goto_preview_type_definition() end, desc = "Preview Type Definition" },
      { "<leader>pi", function() require("goto-preview").goto_preview_implementation() end, desc = "Preview Implementation" },
      { "<leader>pr", function() require("goto-preview").goto_preview_references() end, desc = "Preview References" },
      { "<leader>pc", function() require("goto-preview").close_all_win() end, desc = "Close Previews" },
    },
    opts = {
      width = 120,
      height = 15,
      border = { "↖", "─", "↗", "│", "↘", "─", "↙", "│" },
      default_mappings = false,
      debug = false,
      opacity = nil,
      resizing_mappings = false,
      post_open_hook = nil,
      references = {
        telescope = require("telescope.themes").get_dropdown({ hide_preview = false })
      },
      focus_on_open = true,
      dismiss_on_move = false,
      force_close = true,
      bufhidden = "wipe",
      stack_floating_preview_windows = true,
      preview_window_title = { enable = true, position = "left" },
    },
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/neodev.nvim", opts = {} },
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Diagnostic signs
      local diagnostic_signs = {
        { name = "DiagnosticSignError", text = "󰅚" },
        { name = "DiagnosticSignWarn", text = "󰀪" },
        { name = "DiagnosticSignHint", text = "󰌶" },
        { name = "DiagnosticSignInfo", text = "" },
      }
      for _, sign in ipairs(diagnostic_signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
      end

      -- Diagnostic configuration
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- LSP handlers configuration
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = "rounded" }
      )

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = "rounded" }
      )

      -- LSP servers configuration
      local lspconfig = require("lspconfig")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
      )

      local function on_attach(client, bufnr)
        -- Keymaps
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
        map("n", "gr", vim.lsp.buf.references, "Goto References")
        map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
        map("n", "gI", vim.lsp.buf.implementation, "Goto Implementation")
        map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
        map("n", "gK", vim.lsp.buf.signature_help, "Signature Documentation")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
        map({ "n", "v" }, "<leader>cf", vim.lsp.buf.format, "Format")

        -- Autoformat on save
        if client.supports_method("textDocument/formatting") then
          local augroup = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {})
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                bufnr = bufnr,
                filter = function(c)
                  return c.id == client.id
                end,
              })
            end,
          })
        end
      end

      -- Server configurations
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
              completion = { callSnippet = "Replace" },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
        tsserver = {},
        html = {},
        cssls = {},
        tailwindcss = {},
      }

      -- Setup servers
      for server, config in pairs(servers) do
        config.capabilities = capabilities
        config.on_attach = on_attach
        lspconfig[server].setup(config)
      end
    end,
  },

  -- Mason
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        -- Formatters
        "stylua",
        "shfmt",
        "black",
        "prettier",
        
        -- Linters
        "ruff",
        
        -- LSP
        "pyright",
        "lua-language-server",
        "typescript-language-server",
        "html-lsp",
        "css-lsp",
        "tailwindcss-language-server",
      },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      max_concurrent_installers = 10,
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
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
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_installation = true,
    },
  },
} 