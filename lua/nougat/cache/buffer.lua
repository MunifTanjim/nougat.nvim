local create_store = require("nougat.cache").create_store

local default_value = {}

local store = create_store("buf", "buffer", default_value)

local subscribe = {
  filetype = function()
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("nougat.cache.buffer.filetype", { clear = true }),
      callback = function(params)
        local bufnr = params.buf
        store[bufnr].filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
      end,
      desc = "[nougat] cache.buffer.filetype",
    })
  end,
  modified = function()
    default_value.modified = false

    vim.api.nvim_create_autocmd("BufModifiedSet", {
      group = vim.api.nvim_create_augroup("nougat.cache.buffer.modified", { clear = true }),
      callback = function(params)
        local bufnr = params.buf
        store[bufnr].modified = vim.api.nvim_buf_get_option(bufnr, "modified")
      end,
      desc = "[nougat] cache.buffer.modified",
    })
  end,
}

local enabled_key = {}

local mod = {
  store = store,
}

function mod.enable(key)
  if enabled_key[key] then
    return
  end

  if not subscribe[key] then
    error("missing subscribe")
  end

  subscribe[key]()

  enabled_key[key] = true
end

return mod
