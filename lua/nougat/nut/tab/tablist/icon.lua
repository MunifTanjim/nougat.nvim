--luacheck: push no max line length

---@class nougat.nut.tab.tablist.icon_config: nougat_item_config__function
---@field config? nil

--luacheck: pop

local mod = {}

---@param config nougat.nut.tab.tablist.icon_config
function mod.create(config)
  local item = require("nougat.nut.buf.filetype_icon").create({
    priority = config.priority,
    prepare = config.prepare,
    hidden = config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = config.content,
    suffix = config.suffix,
    sep_right = config.sep_right,
    on_click = config.on_click,
    context = config.context,
    ---@param ctx nougat.nut.tab.tablist_ctx
    _get_bufnr = function(ctx)
      return ctx.tab.bufnr
    end,
  })

  return item
end

return mod
