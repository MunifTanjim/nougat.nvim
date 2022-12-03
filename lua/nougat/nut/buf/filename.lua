local Item = require("nougat.item")
local create_cache_store = require("nougat.cache").create_store

local cache_store = create_cache_store("buf", "nut.buf.filename", { v = nil })

local augroup = vim.api.nvim_create_augroup("nougat.nut.buf.filename", { clear = true })

vim.api.nvim_create_autocmd("BufFilePost", {
  group = augroup,
  callback = function(info)
    cache_store[info.buf].v = nil
  end,
})

local function get_content(item, ctx)
  local cache = item.cache[ctx.bufnr][ctx.ctx.breakpoint]

  if not cache.v then
    local config = item:config(ctx)
    cache.v = vim.fn.expand("%" .. config.modifier)
  end

  return cache.v
end

local mod = {}

function mod.create(opts)
  local item = Item({
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_extend("force", {
      modifier = ":.",
    }, opts.config or {}),
  })

  item.cache = cache_store

  item.content = get_content

  return item
end

return mod
