return {
  'stevearc/aerial.nvim',
  event = 'User BaseFile',
  opts = {
    filter_kind = require('sylow.core.icons.icons').LSP_KINDS,
    open_automatic = false, -- Open if the buffer is compatible
    nerd_font = true,
    autojump = true,
    link_folds_to_tree = false,
    link_tree_to_folds = false,
    attach_mode = 'global',
    backends = { 'lsp', 'treesitter', 'markdown', 'man' },
    disable_max_lines = vim.g.big_file.lines,
    disable_max_size = vim.g.big_file.size,
    layout = {
      resize_to_content = false,
      win_opts = {
        winhl = 'Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB',
        signcolumn = 'yes',
        statuscolumn = ' ',
      },
    },
    show_guides = true,
    guides = {
      mid_item = '├╴',
      last_item = '└╴',
      nested_top = '│ ',
      whitespace = '  ',
    },
    keymaps = {
      ['[y'] = 'actions.prev',
      [']y'] = 'actions.next',
      ['[Y'] = 'actions.prev_up',
      [']Y'] = 'actions.next_up',
      ['{'] = false,
      ['}'] = false,
      ['[['] = false,
      [']]'] = false,
    },
  },
  config = function(_, opts)
    require('aerial').setup(opts)
    -- HACK: The first time you open aerial on a session, close all folds.
    -- vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter' }, {
    --   desc = 'Aerial: When aerial is opened, close all its folds.',
    --   callback = function()
    --     local is_aerial = vim.bo.filetype == 'aerial'
    --     local is_ufo_available = require('sylow.core.utils').is_available('nvim-ufo')
    --     if is_ufo_available and is_aerial and vim.b.new_aerial_session == nil then
    --       vim.b.new_aerial_session = false
    --       require('aerial').tree_set_collapse_level(0, 0)
    --     end
    --   end,
    -- })
  end,
}
