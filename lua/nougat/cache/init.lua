local on_event = require("nougat.util").on_event

local mod = {}

local registry = { buf = {}, win = {} }

---@param cache_type 'buf'|'win'
---@param name string
---@param default_value? table
function mod.create_store(cache_type, name, default_value)
  default_value = default_value or {}
  local storage = setmetatable({}, {
    __index = function(storage, id)
      return rawset(
        storage,
        id,
        setmetatable(vim.deepcopy(default_value), {
          __index = function(cache, key)
            if type(key) == "number" then
              return rawset(cache, key, vim.deepcopy(default_value))[key]
            end
            if default_value[key] ~= nil then
              return rawset(cache, key, default_value[key])[key]
            end
          end,
        })
      )[id]
    end,
  })

  registry[cache_type][name] = storage

  return storage
end

---@param type 'buf'|'win'
---@param name string
---@param id integer
---@return any
function mod.get(type, name, id)
  return registry[type][name][id]
end

---@param type 'buf'|'win'
---@param id integer
local function clear_cache(type, id)
  for _, storage in pairs(registry[type]) do
    storage[id] = nil
  end
end

on_event("BufWipeout", function(info)
  local bufnr = info.buf
  vim.schedule(function()
    clear_cache("buf", bufnr)
  end)
end)

on_event("WinClosed", function(info)
  local winid = tonumber(info.match)
  if winid then
    vim.schedule(function()
      clear_cache("win", winid)
    end)
  end
end)

return mod
