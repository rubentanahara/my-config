return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-jest',
      'nvim-neotest/neotest-plenary',
    },
    opts = {
      -- Can be a list of adapters like what neotest expects,
      -- or a list of adapter names,
      -- or a table of adapter names, mapped to adapter configs.
      -- The adapter will then be automatically loaded with the config.
      adapters = {
        ['neotest-plenary'] = {},
        ['neotest-jest'] = {
          jestConfigFile = function()
            local file = vim.fn.expand('%:p')
            if string.find(file, '/packages/') then
              return string.match(file, '(.-/[^/]+/)src') .. 'jest.config.ts'
            end
            return vim.fn.getcwd() .. '/jest.config.ts'
          end,
          cwd = function()
            local file = vim.fn.expand('%:p')
            if string.find(file, '/packages/') then
              return string.match(file, '(.-/[^/]+/)src')
            end
            return vim.fn.getcwd()
          end,
        },
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          if require('lazyvim.util').has('trouble.nvim') then
            require('trouble').open({ mode = 'quickfix', focus = false })
          else
            vim.cmd('copen')
          end
        end,
      },
    },
    config = function(_, opts)
      local neotest_ns = vim.api.nvim_create_namespace('neotest')
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            -- Replace newline and tab characters with space for more compact diagnostics
            local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
            return message
          end,
        },
      }, neotest_ns)

      if require('lazyvim.util').has('trouble.nvim') then
        opts.consumers = opts.consumers or {}
        -- Refresh and auto close trouble after running tests
        ---@type neotest.Consumer
        opts.consumers.trouble = function(client)
          client.listeners.results = function(adapter_id, results, partial)
            if partial then
              return
            end
            local tree = assert(client:get_position(nil, { adapter = adapter_id }))

            local failed = 0
            for pos_id, result in pairs(results) do
              if result.status == 'failed' and tree:get_key(pos_id) then
                failed = failed + 1
              end
            end
            vim.schedule(function()
              local trouble = require('trouble')
              if trouble.is_open() then
                trouble.refresh()
                if failed == 0 then
                  trouble.close()
                end
              end
            end)
            return {}
          end
        end
      end

      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters or {}) do
          if type(name) == 'number' then
            if type(config) == 'string' then
              config = require(config)
            end
            adapters[#adapters + 1] = config
          elseif config ~= false then
            local adapter = require(name)
            if type(config) == 'table' and not vim.tbl_isempty(config) then
              local meta = getmetatable(adapter)
              if adapter.setup then
                adapter.setup(config)
              elseif meta and meta.__call then
                adapter(config)
              else
                error('Adapter ' .. name .. ' does not support setup')
              end
            end
            adapters[#adapters + 1] = adapter
          end
        end
        opts.adapters = adapters
      end

      require('neotest').setup(opts)
    end,
  -- stylua: ignore
    keys = {
      { ";tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File" },
      { ";tr", function() require("neotest").run.run() end, desc = "Run Nearest" },
      { ";tT", function() require("neotest").run.run(vim.loop.cwd()) end, desc = "Run All Test Files" },
      { ";tl", function() require("neotest").run.run_last() end, desc = "Run Last" },
      { ";ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      { ";to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
      { ";tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
      { ";tS", function() require("neotest").run.stop() end, desc = "Stop" },
    },
  },
}
