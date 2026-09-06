vim.api.nvim_create_autocmd('OptionSet', {
  group = vim.api.nvim_create_augroup('markview_wrap_rerender', { clear = true }),
  pattern = 'wrap',
  callback = function()
    if vim.bo.filetype == 'markdown' then
      vim.cmd('Markview render')
    end
  end,
})
