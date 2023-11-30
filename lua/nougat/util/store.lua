local mod = {}

local store_by_name = {}

local k_clear = -1

---@param store string|table
function mod.clear(store)
  if type(store) == "string" then
    store = store_by_name[store]
  end
  store[k_clear](store)
end

function mod.clear_all()
  for _, store in pairs(store_by_name) do
    mod.clear(store)
  end
end

---@generic S: table
---@param name string
---@param store S
---@param clear fun(store:table):nil
---@return S store
function mod.register(name, store, clear)
  store[k_clear] = clear
  store_by_name[name] = store
  return store
end

return mod
