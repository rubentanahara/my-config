local core = require('sylow.core.init')
local ok = core.init()

if not ok then
  vim.notify('Configuration initialization failed', vim.log.levels.ERROR)
end
