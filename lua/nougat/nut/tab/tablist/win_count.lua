local Item = require("nougat.item")
local tab_store = require("nougat.nut.tab.winlist")._tab_store

local function content(_, ctx)
  local tabid = ctx.tab and ctx.tab.tabid or ctx.tabid
  return tostring(tab_store[tabid].count or 1)
end

local mod = {}

---@param config nougat_item_config__nil
function mod.create(config)
  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = content,
    suffix = config.suffix,
    sep_right = config.sep_right,
  })

  return item
end

return mod
