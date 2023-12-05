local mod = {}

local store_by_name = {}
local clear_by_store = {}

---@param store string|table
function mod.clear(store)
  if type(store) == "string" then
    store = store_by_name[store]
  end
  clear_by_store[store](store)
end

function mod.clear_all()
  for _, store in pairs(store_by_name) do
    mod.clear(store)
  end
end

---@generic S: table
---@param name string
---@param store S
---@param clear fun(store:S):nil
---@return S store
function mod.register(name, store, clear)
  store_by_name[name] = store
  clear_by_store[store] = clear
  return store
end

return mod
