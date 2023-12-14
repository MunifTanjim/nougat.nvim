--luacov: disable
local store = require("nougat.store")

local mod = {}

---@deprecated
---@param type 'buf'|'win'|'tab'
---@param name string
---@param id integer
---@return any
function mod.get(type, name, id)
  vim.deprecate("require('nougat.cache').get", "[n/a]", "0.5.0", "nougat.nvim")
  return store._get(type, name, id)
end

-- Use `require("nougat.store")` instead.
---@deprecated
---@param store_type 'buf'|'win'|'tab'
---@param name string
---@param value? table
function mod.create_store(store_type, name, value)
  vim.deprecate(
    "require('nougat.cache').create_store",
    "require('nougat.store').{Buf,Win,Tab}Store",
    "0.5.0",
    "nougat.nvim"
  )
  if store_type == "buf" then
    return store.BufStore(name, value)
  elseif store_type == "win" then
    return store.WinStore(name, value)
  elseif store_type == "tab" then
    return store.TabStore(name, value)
  end
end

return mod
--luacov: enable
