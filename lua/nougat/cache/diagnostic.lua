local BufStore = require("nougat.store").BufStore
local Store = require("nougat.store").Store
local on_event = require("nougat.util").on_event

local severity = vim.deepcopy(vim.diagnostic.severity)
---@cast severity -nil|unknown
severity.COMBINED = severity.ERROR + severity.WARN + severity.INFO + severity.HINT

local store = Store("nougat.cache.diagnostic", {
  ---@type (fun(cache: table, bufnr: integer):nil)[]
  on_update_cbs = {},
})

local buf_store = BufStore("nougat.cache.diagnostic", {
  [severity.ERROR] = 0,
  [severity.WARN] = 0,
  [severity.INFO] = 0,
  [severity.HINT] = 0,
  [severity.COMBINED] = 0,
})

local on_update_cbs = store.on_update_cbs

local function handle_diagnostic_changed(params)
  local bufnr = params.buf

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_buf_get_option(bufnr, "buftype") ~= "" then
      return
    end

    local diagnostics = vim.diagnostic.get(bufnr)

    local error, warn, info, hint = 0, 0, 0, 0

    for idx = 1, #diagnostics do
      local diagnostic = diagnostics[idx]
      if diagnostic.severity == severity.ERROR then
        error = error + 1
      elseif diagnostic.severity == severity.WARN then
        warn = warn + 1
      elseif diagnostic.severity == severity.INFO then
        info = info + 1
      elseif diagnostic.severity == severity.HINT then
        hint = hint + 1
      end
    end

    local cache = buf_store[bufnr]

    if cache[severity.ERROR] ~= error then
      cache[severity.ERROR] = error
    end
    if cache[severity.WARN] ~= warn then
      cache[severity.WARN] = warn
    end
    if cache[severity.INFO] ~= info then
      cache[severity.INFO] = info
    end
    if cache[severity.HINT] ~= hint then
      cache[severity.HINT] = hint
    end
    cache[severity.COMBINED] = error + warn + info + hint

    for i = 1, #on_update_cbs do
      on_update_cbs[i](cache, bufnr)
    end
  end)
end

local mod = {
  severity = severity,
  store = buf_store,
}

function mod.enable()
  on_event("DiagnosticChanged", handle_diagnostic_changed)
end

---@param event 'change'
---@param callback fun(cache: table, bufnr: integer)
function mod.on(event, callback)
  --luacov: disable
  if event == "update" then
    vim.deprecate("nougat.cache.diagnostic.on parameter event 'update'", "'change'", "0.5.0", "nougat.nvim")
    event = "change"
  end
  --luacov: enable

  if event == "change" and not on_update_cbs[callback] then
    on_update_cbs[callback] = true
    on_update_cbs[#on_update_cbs + 1] = callback
  end
end

return mod
