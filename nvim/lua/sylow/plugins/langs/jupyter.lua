local function magma_init_python()
  vim.cmd([[
    MagmaInit python3
    MagmaEvaluateArgument a=5
  ]])
end

local function magma_init_csharp()
  vim.cmd([[
    MagmaInit .net-csharp
    MagmaEvaluateArgument Microsoft.DotNet.Interactive.Formatting.Formatter.SetPreferredMimeTypesFor(typeof(System.Object),"text/plain");
  ]])
end

return {
  {
    'dccsillag/magma-nvim',
    ft = { 'python', 'quarto', 'r', 'julia', 'cs', 'fsharp' },
    build = ':UpdateRemotePlugins',
    init = function()
      vim.g.magma_automatically_open_output = false
      vim.g.magma_image_provider = 'kitty'
      vim.g.magma_wrap_output = true
      vim.g.magma_output_window_borders = true
      vim.g.magma_cell_highlight_group = 'CursorLine'
    end,
    config = function()
      vim.api.nvim_create_user_command('MagmaInitPython', magma_init_python, {})
      vim.api.nvim_create_user_command('MagmaInitCSharp', magma_init_csharp, {})
    end,
    keys = {
      {
        '<localleader>r',
        function()
          return vim.fn.nvim_exec('MagmaEvaluateOperator', true)
        end,
        expr = true,
        silent = true,
        desc = 'Magma evaluate operator',
      },
      { '<localleader>rr', '<cmd>MagmaEvaluateLine<cr>', desc = 'Magma evaluate line' },
      { '<localleader>r', '<cmd><C-u>MagmaEvaluateVisual<cr>', mode = 'x', desc = 'Magma evaluate visual' },
      { '<localleader>rc', '<cmd>MagmaReevaluateCell<cr>', desc = 'Magma reevaluate cell' },
      { '<localleader>rd', '<cmd>MagmaDelete<cr>', desc = 'Magma delete cell' },
      { '<localleader>ro', '<cmd>MagmaShowOutput<cr>', desc = 'Magma show output' },
      { '<localleader>rq', '<cmd>noautocmd MagmaEnterOutput<cr>', desc = 'Magma enter output' },
      { '<leader>yi', '<cmd>MagmaInit<cr>', desc = 'Magma init kernel' },
      { '<leader>yI', '<cmd>MagmaInitPython<cr>', desc = 'Magma init Python kernel' },
      { '<leader>yC', '<cmd>MagmaInitCSharp<cr>', desc = 'Magma init C# kernel' },
      { '<leader>yF', '<cmd>MagmaInitFSharp<cr>', desc = 'Magma init F# kernel' },
      { '<leader>yd', '<cmd>MagmaDeinit<cr>', desc = 'Magma deinit' },
      { '<leader>yq', '<cmd>MagmaInterrupt<cr>', desc = 'Magma interrupt kernel' },
      { '<leader>yR', '<cmd>MagmaRestart<cr>', desc = 'Magma restart kernel' },
      { '<leader>ys', '<cmd>MagmaSave<cr>', desc = 'Magma save session' },
      { '<leader>yl', '<cmd>MagmaLoad<cr>', desc = 'Magma load session' },
    },
  },
}
