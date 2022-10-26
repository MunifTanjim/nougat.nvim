local mod = {}

local registry = { buf = {}, win = {} }

---@param type 'buf'|'win'
---@param name string
---@param default_value? any
function mod.create_store(type, name, default_value)
  local storage = setmetatable({}, {
    __index = function(storage, id)
      rawset(storage, id, default_value == nil and {} or vim.deepcopy(default_value))
      return storage[id]
    end,
  })

  registry[type][name] = storage

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

local augroup = vim.api.nvim_create_augroup("nougat.cache", { clear = true })

vim.api.nvim_create_autocmd("BufWipeout", {
  group = augroup,
  callback = function(info)
    local bufnr = info.buf
    vim.schedule(function()
      clear_cache("buf", bufnr)
    end)
  end,
  desc = "[nougat] cache cleanup (buf)",
})

vim.api.nvim_create_autocmd("WinClosed", {
  group = augroup,
  callback = function(info)
    local winid = tonumber(info.match)
    if winid then
      vim.schedule(function()
        clear_cache("win", winid)
      end)
    end
  end,
  desc = "[nougat] cache cleanup (win)",
})

return mod
