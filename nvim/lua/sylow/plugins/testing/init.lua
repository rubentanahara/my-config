--  TESTING -----------------------------------------------------------------
--  Run tests inside of nvim [unit testing]
--  https://github.com/nvim-neotest/neotest
--
--
--  MANUAL:
--  -- Unit testing:
--  To tun an unit test you can run any of these commands:
--
--    :Neotest run      -- Runs the nearest test to the cursor.
--    :Neotest stop     -- Stop the nearest test to the cursor.
--    :Neotest run file -- Run all tests in the file.
--
--  -- E2e and Test Suite
--  Normally you will prefer to open your e2e framework GUI outside of nvim.
--  But you have the next commands in ../base/3-autocmds.lua:
--
--    :TestNodejs    -- Run all tests for this nodejs project.
--    :TestNodejsE2e -- Run the e2e tests/suite for this nodejs project.
return {
  {
    'nvim-neotest/neotest',
    cmd = { 'Neotest' },
    dependencies = {
      'sidlatau/neotest-dart',
      'Issafalcon/neotest-dotnet',
      'jfpedroza/neotest-elixir',
      'fredrikaverpil/neotest-golang',
      'rcasia/neotest-java',
      'nvim-neotest/neotest-jest',
      'olimorris/neotest-phpunit',
      'nvim-neotest/neotest-python',
      'rouge8/neotest-rust',
      'lawrence-laz/neotest-zig',
    },
    opts = function()
      return {
        -- your neotest config here
        adapters = {
          require('neotest-dart'),
          require('neotest-dotnet'),
          require('neotest-elixir'),
          require('neotest-golang'),
          require('neotest-java'),
          require('neotest-jest'),
          require('neotest-phpunit'),
          require('neotest-python'),
          require('neotest-rust'),
          require('neotest-zig'),
        },
      }
    end,
    config = function(_, opts)
      -- get neotest namespace (api call creates or returns namespace)
      local neotest_ns = vim.api.nvim_create_namespace 'neotest'
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
            return message
          end,
        },
      }, neotest_ns)
      require('neotest').setup(opts)
    end,
  },

  --  Shows a float panel with the [code coverage]
  --  https://github.com/andythigpen/nvim-coverage
  --
  --  Your project must generate coverage/lcov.info for this to work.
  --
  --  On jest, make sure your packages.json file has this:
  --  "tests": "jest --coverage"
  --
  --  If you use other framework or language, refer to nvim-coverage docs:
  --  https://github.com/andythigpen/nvim-coverage/blob/main/doc/nvim-coverage.txt
  {
    'andythigpen/nvim-coverage',
    cmd = {
      'Coverage',
      'CoverageLoad',
      'CoverageLoadLcov',
      'CoverageShow',
      'CoverageHide',
      'CoverageToggle',
      'CoverageClear',
      'CoverageSummary',
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      summary = {
        min_coverage = 80.0, -- passes if higher than
      },
    },
    config = function(_, opts)
      require('coverage').setup(opts)
    end,
  },
}
