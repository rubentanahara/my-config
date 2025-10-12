local utils = require('sylow.core.utils')

local function execute_normal_n(count)
  vim.cmd(('execute("normal! " . %d . "n")'):format(count or vim.v.count1))
  utils.start_hlslens()
end

local function execute_normal_N(count)
  vim.cmd(('execute("normal! " . %d . "N")'):format(count or vim.v.count1))
  utils.start_hlslens()
end

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
  utils.start_hlslens()
    end,
    desc = 'Search word under cursor forward with HLSLens',
    mode = { 'n', 'x', 'o' },
  },
  {
    '#',
    function()
      vim.cmd('normal! #')
  utils.start_hlslens()
    end,
    desc = 'Search word under cursor backward with HLSLens',
    mode = { 'n', 'x', 'o' },
  },
  {
    'g*',
    function()
      vim.cmd('normal! g*')
  utils.start_hlslens()
    end,
    desc = 'Search partial word under cursor forward with HLSLens',
    mode = { 'n', 'x', 'o' },
  },
  {
    'g#',
    function()
      vim.cmd('normal! g#')
  utils.start_hlslens()
    end,
    desc = 'Search partial word under cursor backward with HLSLens',
    mode = { 'n', 'x', 'o' },
  },
}

local function setup_hlslens()
  return {
    calm_down = true,
    nearest_only = true,
    build_position = 'top_right', -- top_left, top_right, bottom_left, bottom_right
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
  },
}
