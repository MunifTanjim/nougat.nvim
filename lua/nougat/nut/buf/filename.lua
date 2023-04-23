local Item = require("nougat.item")
local create_cache_store = require("nougat.cache").create_store
local on_event = require("nougat.util").on_event

local cache_store = create_cache_store("buf", "nut.buf.filename", { v = nil })

on_event("BufFilePost", function(info)
  local cache = cache_store[info.buf]
  for key in pairs(cache) do
    cache[key] = nil
  end
end)

local function get_content(item, ctx)
  local cache = item.cache[ctx.bufnr][ctx.ctx.breakpoint]

  if not cache.v then
    local config = item:config(ctx)
    cache.v = vim.fn.expand("%" .. config.modifier)
    if #cache.v == 0 then
      cache.v = config.unnamed
    elseif config.format then
      cache.v = config.format(cache.v, ctx)
    end
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
    content = get_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_extend("force", {
      modifier = ":.",
      format = nil,
      unnamed = "[No Name]",
    }, opts.config or {}),
    on_click = opts.on_click,
    context = opts.context,
  })

  item.cache = cache_store

  return item
end

return mod
