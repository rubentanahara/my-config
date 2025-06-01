return {
  'mfussenegger/nvim-dap',
  dependencies = {
    {
      'jbyuki/one-small-step-for-vimkind',
      config = function()
        local dap = require('dap')

        dap.adapters['pwa-node'] = function(callback, conf)
          local adapter = {
            type = 'server',
            host = conf.host or '127.0.0.1',
            port = conf.port or 8123,
          }

          if conf.start_neovim then
            local dap_run = dap.run
            dap.run = function(c)
              adapter.port = c.port
              adapter.host = c.host
            end
            require('osv').run_this()
            dap.run = dap_run
          end

          callback(adapter)
        end

        for _, language in ipairs { 'typescript', 'javascript' } do
          dap.configurations[language] = {
            {
              type = 'pwa-node',
              request = 'launch',
              name = 'Launch file',
              program = '${file}',
              cwd = '${workspaceFolder}',
              runtimeExecutable = 'node',
            },
          }
        end
      end,
    },
  },
}
