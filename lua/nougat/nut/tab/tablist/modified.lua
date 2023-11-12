local Item = require("nougat.item")

local buffer_cache = require("nougat.cache.buffer")

buffer_cache.enable("modified")

local buffer_cache_store = buffer_cache.store

local function get_content(item, ctx)
  return item:config(ctx).text
end

local function hidden(_, ctx)
  return not buffer_cache_store[ctx.tab.bufnr].modified
end

local mod = {}

function mod.create(opts)
  local item = Item({
    priority = opts.priority,
    hidden = hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = get_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_deep_extend("force", {
      text = "+",
    }, opts.config or {}),
    on_click = opts.on_click,
    context = opts.context,
  })

  return item
end

return mod
