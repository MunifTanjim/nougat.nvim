local Item = require("nougat.item")
local label_hl = require("nougat.nut.tab.tablist.label").hl

local diagnostic_cache = require("nougat.cache.diagnostic")
local severity, cache_store = diagnostic_cache.severity, diagnostic_cache.store

local function hidden(_, ctx)
  return cache_store[ctx.tab.bufnr][severity.COMBINED] == 0
end

local function content(_, ctx)
  local count = cache_store[ctx.tab.bufnr][severity.COMBINED]
  return count > 0 and tostring(count) or ""
end

local mod = {}

function mod.create(opts)
  local item = Item({
    priority = opts.priority,
    hidden = hidden,
    hl = label_hl.diagnostic(),
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    on_click = opts.on_click,
    context = opts.context,
  })

  return item
end

return mod
