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
