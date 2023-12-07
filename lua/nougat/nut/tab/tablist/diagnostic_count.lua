local Item = require("nougat.item")
local label_hl = require("nougat.nut.tab.tablist.label").hl
local diagnostic_cache = require("nougat.cache.diagnostic")

--luacheck: push no max line length

---@class nougat.nut.tab.tablist.diagnostic_count_config: nougat_item_config__nil
---@field content? nil
---@field hidden? nil
---@field hl? nil

--luacheck: pop

local severity, cache_store = diagnostic_cache.severity, diagnostic_cache.store

---@param ctx nougat.nut.tab.tablist_ctx
local function hidden(_, ctx)
  return cache_store[ctx.tab.bufnr][severity.COMBINED] == 0
end

---@param ctx nougat.nut.tab.tablist_ctx
local function content(_, ctx)
  local count = cache_store[ctx.tab.bufnr][severity.COMBINED]
  return count > 0 and tostring(count) or ""
end

local mod = {}

---@param config nougat.nut.tab.tablist.diagnostic_count_config
function mod.create(config)
  diagnostic_cache.enable()

  local item = Item({
    priority = config.priority,
    hidden = hidden,
    hl = label_hl.diagnostic(),
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = content,
    suffix = config.suffix,
    sep_right = config.sep_right,
    on_click = config.on_click,
    context = config.context,
  })

  return item
end

return mod
