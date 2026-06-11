return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim' },
    },
    build = 'make tiktoken',
    cmd = {
      'CopilotChat',
      'CopilotChatToggle',
      'CopilotChatReset',
      'CopilotChatModels',
      'CopilotChatPrompts',
      'CopilotChatExplain',
      'CopilotChatReview',
      'CopilotChatFix',
      'CopilotChatOptimize',
      'CopilotChatDocs',
      'CopilotChatTests',
      'CopilotChatCommit',
    },
    opts = {
      model = 'claude-sonnet-4.6',
      temperature = 0.1,
      auto_insert_mode = true,
      window = {
        layout = 'vertical',
        width = 0.4,
        border = 'rounded',
        title = 'Copilot Chat',
      },
    },
    keys = {
      { '<leader>aa', '<cmd>CopilotChatToggle<cr>', mode = { 'n', 'v' }, desc = 'Toggle Chat' },
      { '<leader>ax', '<cmd>CopilotChatReset<cr>', mode = { 'n', 'v' }, desc = 'Reset Chat' },
      {
        '<leader>aM',
        function()
          require('CopilotChat').select_model()
        end,
        desc = 'Select Model',
      },
      {
        '<leader>ap',
        function()
          require('CopilotChat').select_prompt()
        end,
        mode = { 'n', 'v' },
        desc = 'Prompt Actions',
      },
      {
        '<leader>aq',
        function()
          local input = vim.fn.input('Quick Chat: ')
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        desc = 'Quick Chat (buffer)',
      },
      { '<leader>ae', '<cmd>CopilotChatExplain<cr>', mode = { 'n', 'v' }, desc = 'Explain Code' },
      { '<leader>ar', '<cmd>CopilotChatReview<cr>', mode = { 'n', 'v' }, desc = 'Review Code' },
      { '<leader>aF', '<cmd>CopilotChatFix<cr>', mode = { 'n', 'v' }, desc = 'Fix Code' },
      { '<leader>ao', '<cmd>CopilotChatOptimize<cr>', mode = { 'n', 'v' }, desc = 'Optimize Code' },
      { '<leader>ad', '<cmd>CopilotChatDocs<cr>', mode = { 'n', 'v' }, desc = 'Generate Docs' },
      { '<leader>at', '<cmd>CopilotChatTests<cr>', mode = { 'n', 'v' }, desc = 'Generate Tests' },
      { '<leader>am', '<cmd>CopilotChatCommit<cr>', desc = 'Commit Message' },
    },
  },
}
