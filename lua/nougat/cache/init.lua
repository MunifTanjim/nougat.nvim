local on_event = require("nougat.util").on_event

local mod = {}

local registry = { buf = {}, win = {}, tab = {} }

---@param cache_type 'buf'|'win'|'tab'
---@param name string
---@param default_value? table
function mod.create_store(cache_type, name, default_value)
  if registry[cache_type][name] then
    error("already created")
  end

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

---@param type 'buf'|'win'|'tab'
---@param name string
---@param id integer
---@return any
function mod.get(type, name, id)
  return registry[type][name][id]
end

---@param type 'buf'|'win'|'tab'
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

on_event("TabClosed", function()
  vim.schedule(function()
    local active_tabid = {}
    for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
      active_tabid[tabid] = true
    end

    for _, storage in pairs(registry.tab) do
      for tabid in pairs(storage) do
        if not active_tabid[tabid] then
          storage[tabid] = nil
        end
      end
    end
  end)
end)

return mod
