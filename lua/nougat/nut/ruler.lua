local core = require("nougat.core")
local Item = require("nougat.item")

--luacheck: push no max line length

---@class nougat.nut.ruler_config: nougat_item_config__nil
---@field content? nil

--luacheck: pop

local mod = {}

---@param config? nougat.nut.ruler_config
function mod.create(config)
  config = config or {}
  return Item({
    priority = config.priority,
    hidden = config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = core.ruler(),
    suffix = config.suffix,
    sep_right = config.sep_right,
    on_click = config.on_click,
    context = config.context,
  })
end

return mod
