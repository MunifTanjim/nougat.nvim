local create_store = require("nougat.cache").create_store

local severity = vim.deepcopy(vim.diagnostic.severity)
severity.COMBINED = severity.ERROR + severity.WARN + severity.INFO + severity.HINT

local store = create_store("buf", "diagnostic", {
  [severity.ERROR] = 0,
  [severity.WARN] = 0,
  [severity.INFO] = 0,
  [severity.HINT] = 0,
  [severity.COMBINED] = 0,
})

local hooks = {
  on_update = {},
}

local augroup = vim.api.nvim_create_augroup("nougat.cache.diagnostic", { clear = true })

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = augroup,
  callback = function(params)
    local bufnr = params.buf

    vim.schedule(function()
      local error, warn, info, hint = 0, 0, 0, 0

      local diagnostics = vim.diagnostic.get(bufnr)

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

      local cache = store[bufnr]

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

      for i = 1, #hooks.on_update do
        hooks.on_update[i](cache, bufnr)
      end
    end)
  end,
  desc = "[nougat] cache.diagnostic",
})

local mod = {
  severity = severity,
  store = store,
}

---@param event 'update'
---@param callback fun(cache: table, bufnr: integer)
function mod.on(event, callback)
  if event == "update" then
    hooks.on_update[#hooks.on_update + 1] = callback
  end
end

return mod
