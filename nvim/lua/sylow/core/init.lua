local M = {}

local CONFIG_SOURCES = {
	'sylow.core.options',
	'sylow.core.autocmds',
	'sylow.core.lazy',
	'sylow.core.mappings'
}

function M.init()
	return require('sylow.core.utils').load_sources(CONFIG_SOURCES)
end

return M
