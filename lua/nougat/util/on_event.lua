local augroup = vim.api.nvim_create_augroup("nougat.on_event", { clear = true })

---@type table<string, (fun(info:table):nil)[]>
local autocmd_cb_store = {}

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
    end

    if not autocmd_cb_store[ev] then
      autocmd_cb_store[ev] = {}

      vim.api.nvim_create_autocmd(event_name, {
        group = augroup,
        pattern = pattern,
        callback = function(info)
          local cbs = info.event == "User" and autocmd_cb_store["User " .. info.match] or autocmd_cb_store[info.event]

          for _, cb in ipairs(cbs) do
            cb(info)
          end
        end,
        desc = "[nougat] util.on_event - " .. ev,
      })
    end

    autocmd_cb_store[ev][#autocmd_cb_store[ev] + 1] = callback
  end
end

return on_event
