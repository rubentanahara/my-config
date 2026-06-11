local M = {}

function M.patch_cmp_nvim_lsp()
  local ok, source = pcall(require, 'cmp_nvim_lsp.source')
  if not ok then
    return
  end

  source._call_client_method = function(self, method_name, ...)
    if method_name == 'is_stopped' then
      return self.client:is_stopped()
    end
    local method_func = self.client[method_name]
    if not method_func then
      return nil
    end
    return method_func(self.client, ...)
  end
end

function M.patch_copilot_cmp()
  local path = vim.fn.stdpath('data') .. '/lazy/copilot-cmp/lua/copilot_cmp/source.lua'
  if vim.fn.filereadable(path) ~= 1 then
    return
  end

  package.preload['copilot_cmp.source'] = function()
    local chunk, err = loadfile(path)
    if not chunk then
      error(err)
    end
    local mod = chunk()
    mod.is_available = function(self)
      if self.client:is_stopped() or self.client.name ~= 'copilot' then
        return false
      end

      local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
      return next(get_clients({
        bufnr = vim.api.nvim_get_current_buf(),
        id = self.client.id,
      })) ~= nil
    end
    package.loaded['copilot_cmp.source'] = mod
    return mod
  end

  package.loaded['copilot_cmp.source'] = nil
end

function M.apply()
  M.patch_cmp_nvim_lsp()
  M.patch_copilot_cmp()
end

return M
