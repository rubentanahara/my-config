local function splitstr(str)
  local result = {}
  for match in (str .. ' '):gmatch('(.-) ') do
    if match ~= '' then
      table.insert(result, match)
    end
  end
  return result
end

local function get_args(config)
  local args = type(config.args) == 'function' and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
  local args_str = type(args) == 'table' and table.concat(args, ' ') or args --[[@as string]]

  config = vim.deepcopy(config)
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input('Run with args: ', args_str)) --[[@as string]]
    if config.type and config.type == 'java' then
      return new_args
    end
    return splitstr(new_args)
  end
  return config
end

local function get_dap_keys()
  return {
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
    { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
    { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
    { "<leader>dj", function() require("dap").down() end, desc = "Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "Session" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
  }
end

local function get_dapui_keys()
  return {
    { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
    { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
  }
end

local function setup_dap()
  vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

  local vscode = require('dap.ext.vscode')
  local json = require('plenary.json')
  vscode.json_decode = function(str)
    return vim.json.decode(json.json_strip_comments(str))
  end
end

local function setup_dapui(_, opts)
  local dap = require('dap')
  local dapui = require('dapui')
  dapui.setup(opts)

  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end
end

local function setup_mason_dap()
  return {
    automatic_installation = true,
    handlers = {},
    ensure_installed = {},
  }
end

return {
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    keys = get_dap_keys,
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = setup_dap,
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = { 'mfussenegger/nvim-dap' },
    opts = {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
      only_first_definition = true,
      all_references = false,
      display_callback = function(variable, buf, stackframe, node, options)
        if options.virt_text_pos == 'inline' then
          return ' = ' .. variable.value
        else
          return variable.name .. ' = ' .. variable.value
        end
      end,
      virt_text_pos = 'eol',
      all_frames = false,
      virt_lines = false,
      virt_text_win_col = nil,
    },
    config = function(_, opts)
      require('nvim-dap-virtual-text').setup(opts)
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    keys = get_dapui_keys,
    opts = {
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      expand_lines = true,
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 10,
          position = "bottom",
        },
      },
      floating = {
        max_height = nil,
        max_width = nil,
        border = "single",
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      windows = { indent = 1 },
      render = {
        max_type_length = nil,
        max_value_lines = 100,
      },
    },
    config = setup_dapui,
  },
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = { 
      'williamboman/mason.nvim',
      'mfussenegger/nvim-dap',
    },
    cmd = { 'DapInstall', 'DapUninstall' },
    opts = setup_mason_dap,
    config = function(_, opts)
      require('mason-nvim-dap').setup(opts)
    end,
  },
}
