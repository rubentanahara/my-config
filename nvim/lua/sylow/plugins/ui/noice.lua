local utils = require('sylow.utils')
local get_icon = utils.get_icon

return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {
    presets = { inc_rename = true, lsp_doc_border = true },
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
    },
    routes = {
      {
        filter = {
          event = 'msg_show',
          any = {
            { find = '%d+L, %d+B' },
            { find = '; after #%d+' },
            { find = '; before #%d+' },
          },
        },
        view = 'mini',
      },
    },
    cmdline = {
      enabled = true,
      format = {
        cmdline = { icon = get_icon('Terminal') },
        search_down = { icon = get_icon('Find') },
        search_up = { icon = get_icon('Find') },
        filter = { icon = '$' },
        lua = { icon = '☾' },
        help = { icon = '?' },
      },
    },
    format = {
      level = {
        icons = {
          error = get_icon('DiagnosticError'),
          warn = get_icon('DiagnosticWarn'),
          info = get_icon('DiagnosticInfo'),
        },
      },
    },
    popupmenu = {
      kind_icons = false,
    },
    inc_rename = {
      cmdline = {
        format = {
          IncRename = { icon = get_icon('MasonPending') },
        },
      },
    },
  },
  keys = {
    { "<leader>sn", "", desc = "+noice"},
    { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
    { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
    { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
    { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
    { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
    { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
  },
  config = function(_, opts)
    -- HACK: noice shows messages from before it was enabled,
    -- but this is not ideal when Lazy is installing plugins,
    -- so clear the messages in this case.
    if vim.o.filetype == 'lazy' then
      vim.cmd([[messages clear]])
    end
    require('noice').setup(opts)
  end,
}
