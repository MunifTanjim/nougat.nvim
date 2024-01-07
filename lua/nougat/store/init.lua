local mod = {}

---@class NougatStore: table
---@field type ''
---@field clear fun(store: table):nil
---@field name string

---@class NougatBufStore: NougatStore
---@field type 'buf'
---@field clear fun(store: table, bufnr: integer):nil
---@field [integer] table|table<integer, table>
---
---@class NougatWinStore: NougatStore
---@field type 'win'
---@field clear fun(store: table, winid: integer):nil
---@field [integer] table|table<integer, table>
---
---@class NougatTabStore: NougatStore
---@field type 'tab'
---@field clear fun(store: table, tabid: integer):nil
---@field [integer] table|table<integer, table>

local registry = {
  ---@type table<string, table>
  [""] = {},
  ---@type table<string, NougatBufStore>
  buf = {},
  ---@type table<string, NougatWinStore>
  win = {},
  ---@type table<string, NougatTabStore>
  tab = {},
}

---@param type 'buf'|'win'|'tab'
---@param id integer
local function clear_all_bound_store_for_id(type, id)
  for _, store in pairs(registry[type]) do
    store[id] = nil
  end
end

local function on_buf_wipeout(info)
  local bufnr = info.buf
  vim.schedule(function()
    clear_all_bound_store_for_id("buf", bufnr)
  end)
end

local function on_win_closed(info)
  local winid = tonumber(info.match)
  if winid then
    vim.schedule(function()
      clear_all_bound_store_for_id("win", winid)
    end)
  end
end

local function on_tab_closed()
  vim.schedule(function()
    local active_tabid = {}
    for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
      active_tabid[tabid] = true
    end

    for _, store in pairs(registry.tab) do
      for tabid in pairs(store) do
        if type(tabid) == "number" and not active_tabid[tabid] then
          store[tabid] = nil
        end
      end
    end
  end)
end

local setup_bound_store_clear = {
  buf = function()
    require("nougat.util.on_event")("BufWipeout", on_buf_wipeout)
  end,
  win = function()
    require("nougat.util.on_event")("WinClosed", on_win_closed)
  end,
  tab = function()
    require("nougat.util.on_event")("TabClosed", on_tab_closed)
  end,
}

---@param store NougatStore
---@param id integer
local function clear_bound_store_for_id(store, id)
  local value = store[id]
  if value then
    for key in pairs(value) do
      value[key] = nil
    end
  end
end

local default_value = {}

---@param store_type 'buf'|'win'|'tab'
---@param name string
---@param value? table
---@return NougatBufStore|NougatWinStore|NougatTabStore
local function create_bound_store(store_type, name, value)
  setup_bound_store_clear[store_type]()

  value = value or default_value

  if registry[store_type][name] then
    local store = registry[store_type][name]
    if store._value ~= value then
      error(store_type .. " store already created with different value")
    end
    return store
  end

  local store = setmetatable({
    type = store_type,
    name = name,
    clear = clear_bound_store_for_id,
    _value = value,
  }, {
    __index = function(store, id)
      return rawset(
        store,
        id,
        setmetatable(vim.deepcopy(value) --[[@as table]], {
          __index = function(id_store, key)
            if type(key) == "number" then
              return rawset(id_store, key, vim.deepcopy(value))[key]
            end
            if value[key] ~= nil then
              return rawset(id_store, key, vim.deepcopy(value[key]))[key]
            end
          end,
        })
      )[id]
    end,
  })

  registry[store_type][name] = store

  return store
end

--luacov: disable

---@deprecated
---@param type 'buf'|'win'|'tab'
---@param name string
---@param id integer
---@return any
function mod._get(type, name, id)
  return registry[type][name][id]
end

--luacov: enable

---@param target_type? ''|'buf'|'win'|'tab'
---@param target_name? string
function mod._clear(target_type, target_name)
  -- wait a bit for pending tasks
  vim.wait(10)

  for store_type, store_by_name in pairs(registry) do
    if store_type == (target_type or store_type) then
      for name, store in pairs(store_by_name) do
        if name == (target_name or name) then
          if store_type == "" then
            ---@cast store NougatStore
            store:clear()
          else
            for id in pairs(store) do
              if type(id) == "number" then
                store[id] = nil
              end
            end
          end
        end
      end
    end
  end
end

---@param target_type? ''|'buf'|'win'|'tab'
---@param target_name? string
function mod._cleanup(target_type, target_name)
  -- wait a bit for pending tasks
  vim.wait(10)

  for store_type, store_by_name in pairs(registry) do
    if store_type == (target_type or store_type) then
      for name in pairs(store_by_name) do
        if name == (target_name or name) then
          store_by_name[name] = nil
        end
      end
    end
  end
end

local is_reserved_top_level_key = { clear = true, name = true, type = true }

local function default_clear(store)
  for key, val in pairs(store) do
    if type(val) == "table" then
      for k in pairs(val) do
        val[k] = nil
      end
    else
      store[key] = nil
    end
  end
end

---@generic T: table
---@param name string
---@param value T
---@param config? { clear?: (fun(store: T):nil) }
---@return T|NougatStore store
function mod.Store(name, value, config)
  if registry[""][name] then
    local store = registry[""][name]
    if store ~= value then
      error("store already created with different value")
    end
    return store
  end

  for key in pairs(is_reserved_top_level_key) do
    assert(type(value[key]) == "nil", "found reserved top-level key: " .. key)
  end

  config = config or {}

  local store = setmetatable(value, {
    __index = {
      type = "",
      name = name,
      clear = config.clear or default_clear,
    },
    __newindex = function(tbl, key, val)
      if is_reserved_top_level_key[key] then
        error("not allowed to set reserved top-level key: " .. key)
      end
      rawset(tbl, key, val)
    end,
  })

  registry[""][name] = store

  return store
end

---@param name string
---@param value? table
---@return NougatBufStore
function mod.BufStore(name, value)
  return create_bound_store("buf", name, value)
end

---@param name string
---@param value? table
---@return NougatWinStore
function mod.WinStore(name, value)
  return create_bound_store("win", name, value)
end

---@param name string
---@param value? table
---@return NougatTabStore
function mod.TabStore(name, value)
  return create_bound_store("tab", name, value)
end

return mod
