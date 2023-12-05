local Item = require("nougat.item")

--luacheck: push no max line length

---@class nougat.nut.buf.filetype_config: nougat_item_config__vim_expr
---@field content? nil
---@field expand? nil
---@field type? nil

--luacheck: pop

local mod = {}

---@param config nougat.nut.buf.filetype_config
function mod.create(config)
  return Item({
    priority = config.priority,
    type = "vim_expr",
    is_vimscript = true,
    hidden = config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = "&filetype",
    suffix = config.suffix,
    sep_right = config.sep_right,
    on_click = config.on_click,
    context = config.context,
  })
end

return mod
