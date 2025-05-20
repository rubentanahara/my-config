return {
  'kevinhwang91/nvim-hlslens',
  event = 'VeryLazy',
  opts = {
    calm_down = true,
    nearest_only = true,
  },
  keys = {
    { 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]] },
    { 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]] },
    { '*', [[*<Cmd>lua require('hlslens').start()<CR>]] },
    { '#', [[#<Cmd>lua require('hlslens').start()<CR>]] },
    { 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]] },
    { 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]] },
  },
}
