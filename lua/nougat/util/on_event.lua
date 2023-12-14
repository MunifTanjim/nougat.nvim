local Store = require("nougat.store").Store

local augroup = vim.api.nvim_create_augroup("nougat.util.on_event", { clear = true })

local store = Store("nougat.util.on_event", {
  ---@type table<string, (fun(info:table):nil)[]>
  cb_store = {},
  ---@type table<string, (fun(info:table):nil)[]>
  option_set_cb_store = {},
  ---@type integer
  option_set_autocmd_id = nil,
}, {
  clear = function(store)
    vim.api.nvim_clear_autocmds({ group = augroup })
    for key in pairs(store.cb_store) do
      store.cb_store[key] = nil
    end
    for key in pairs(store.option_set_cb_store) do
      store.option_set_cb_store[key] = nil
    end
    store.option_set_autocmd_id = nil
  end,
})

local cb_store = store.cb_store
local option_set_cb_store = store.option_set_cb_store

local function option_set_callback(info)
  for _, callback in ipairs(option_set_cb_store[info.match]) do
    callback(info)
  end
end

---@param event string|string[]
---@param callback (fun(info:table):nil)
local function on_event(event, callback)
  if type(event) == "string" then
    event = { event }
  end

  for _, ev in ipairs(event) do
    local event_name = ev
    local pattern

    if string.sub(ev, 1, 5) == "User " then
      event_name = "User"
      pattern = string.sub(ev, 6)
    elseif string.sub(ev, 1, 10) == "OptionSet " then
      event_name = "OptionSet"
      pattern = string.sub(ev, 11)
    end

    if event_name == "OptionSet" then
      if not option_set_cb_store[pattern] then
        option_set_cb_store[pattern] = {}
      end

      if not option_set_cb_store[pattern][callback] then
        option_set_cb_store[pattern][callback] = true
        table.insert(option_set_cb_store[pattern], callback)
      end

      local autocmd_id = vim.api.nvim_create_autocmd(event_name, {
        group = augroup,
        pattern = table.concat(vim.tbl_keys(option_set_cb_store), ","),
        callback = option_set_callback,
        desc = "[nougat] util.on_event - " .. event_name,
      })

      if store.option_set_autocmd_id then
        vim.api.nvim_del_autocmd(store.option_set_autocmd_id)
      end

      store.option_set_autocmd_id = autocmd_id
    else
      if not cb_store[ev] then
        cb_store[ev] = {}

        vim.api.nvim_create_autocmd(event_name, {
          group = augroup,
          pattern = pattern,
          callback = function(info)
            local cbs = info.event == "User" and cb_store["User " .. info.match] or cb_store[info.event]

            for _, cb in ipairs(cbs) do
              cb(info)
            end
          end,
          desc = "[nougat] util.on_event - " .. ev,
        })
      end

      if not cb_store[ev][callback] then
        cb_store[ev][callback] = true
        table.insert(cb_store[ev], callback)
      end
    end
  end
end

return on_event
