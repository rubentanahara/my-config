-- Local helper functions for better performance
local function start_hlslens()
  require('hlslens').start()
end

local function execute_normal_n(count)
  vim.cmd(('execute("normal! " . %d . "n")'):format(count or vim.v.count1))
  start_hlslens()
end

local function execute_normal_N(count)
  vim.cmd(('execute("normal! " . %d . "N")'):format(count or vim.v.count1))
  start_hlslens()
end

-- Key mappings definition with proper lazy.nvim format
local keys = {
  {
    'n',
    execute_normal_n,
    desc = 'Next search result with HLSLens',
    mode = { 'n', 'x', 'o' },
  },
  {
    'N',
    execute_normal_N,
    desc = 'Previous search result with HLSLens',
    mode = { 'n', 'x', 'o' },
  },
  {
    '*',
    function()
      vim.cmd('normal! *')
      start_hlslens()
    end,
    desc = 'Search word under cursor forward with HLSLens',
    mode = { 'n', 'x', 'o' },
  },
  {
    '#',
    function()
      vim.cmd('normal! #')
      start_hlslens()
    end,
    desc = 'Search word under cursor backward with HLSLens',
    mode = { 'n', 'x', 'o' },
  },
  {
    'g*',
    function()
      vim.cmd('normal! g*')
      start_hlslens()
    end,
    desc = 'Search partial word under cursor forward with HLSLens',
    mode = { 'n', 'x', 'o' },
  },
  {
    'g#',
    function()
      vim.cmd('normal! g#')
      start_hlslens()
    end,
    desc = 'Search partial word under cursor backward with HLSLens',
    mode = { 'n', 'x', 'o' },
  },
}

-- Configuration options
local function setup_hlslens()
  return {
    calm_down = true,
    nearest_only = true,
    -- Optional additional configuration
    build_position = 'top_right', -- top_left, top_right, bottom_left, bottom_right
    -- Enable floating window for search count
    override_lens = function(render, posList, nearest, idx, relIdx)
      local sfw = vim.v.searchforward == 1
      local indicator, text, chunks
      local absRelIdx = math.abs(relIdx)
      if absRelIdx > 1 then
        indicator = ('%d%s'):format(absRelIdx, sfw ~= (relIdx > 1) and '▲' or '▼')
      elseif absRelIdx == 1 then
        indicator = sfw ~= (relIdx == 1) and '▲' or '▼'
      else
        indicator = ''
      end

      local lnum, col = unpack(posList[idx])
      if nearest then
        local cnt = #posList
        if indicator ~= '' then
          text = ('[%s %d/%d]'):format(indicator, idx, cnt)
        else
          text = ('[%d/%d]'):format(idx, cnt)
        end
        chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLensNear' } }
      else
        text = ('[%s %d]'):format(indicator, idx)
        chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
      end
      render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
    end,
  }
end

return {
  {
    'kevinhwang91/nvim-hlslens',
    event = 'VeryLazy',
    keys = keys,
    opts = setup_hlslens,
    config = function(_, opts)
      require('hlslens').setup(opts)

      -- Optional: Enhance search experience with autocommands
      local augroup = vim.api.nvim_create_augroup('HlslensConfig', {})
      
      vim.api.nvim_create_autocmd('CmdlineEnter', {
        group = augroup,
        pattern = { '/', '?' },
        callback = function()
          vim.opt.cmdheight = 1
        end,
      })

      vim.api.nvim_create_autocmd('CmdlineLeave', {
        group = augroup,
        pattern = { '/', '?' },
        callback = function()
          vim.opt.cmdheight = 0
          -- Ensure hlslens is started after search
          vim.defer_fn(start_hlslens, 10)
        end,
      })
    end,
  },
}
