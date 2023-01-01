local create_store = require("nougat.cache").create_store

local default_value = {}

local store = create_store("buf", "buffer", default_value)

local hooks = {}

local subscribe = {
  filetype = function()
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("nougat.cache.buffer.filetype", { clear = true }),
      callback = function(params)
        local bufnr, filetype = params.buf, params.match
        store[bufnr].filetype = filetype
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
  gitstatus = function()
    hooks["gitstatus.change"] = {}

    local provider
    if pcall(require, "gitsigns") then
      provider = "gitsigns"
    end

    if not provider then
      return
    end

    if provider == "gitsigns" then
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("nougat.cache.buffer.gitstatus", { clear = true }),
        pattern = "GitSignsUpdate",
        callback = function(params)
          local bufnr = params.buf

          vim.schedule(function()
            local status = vim.fn.getbufvar(bufnr, "gitsigns_status_dict", false)
            if not status then
              store[bufnr].gitstatus = nil
              return
            end

            local cache = store[bufnr].gitstatus
            if not cache then
              cache = {}
              store[bufnr].gitstatus = cache
            end

            cache.added = status.added or 0
            cache.changed = status.changed or 0
            cache.removed = status.removed or 0
            cache.total = cache.added + cache.changed + cache.removed

            for i = 1, #hooks["gitstatus.change"] do
              hooks["gitstatus.change"][i](cache, bufnr)
            end
          end)
        end,
        desc = "[nougat] cache.buffer.gitstatus",
      })
    end
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

function mod.on(event, callback)
  if not hooks[event] then
    return
  end

  hooks[event][#hooks[event] + 1] = callback
end

return mod
