local core = require("nougat.core")
local Item = require("nougat.item")

-- re-used tables
local o_label_opts = { tabnr = nil }
local o_label_parts = {}

---@param ctx nougat.nut.tab.tablist_ctx
local function content(_, ctx)
  o_label_opts.tabnr = ctx.tab.tabnr
  local parts_len = core.add_label(tostring(ctx.tab.tabnr), o_label_opts, o_label_parts, 0)
  return table.concat(o_label_parts, nil, 1, parts_len)
end

local hl = {}

function hl.diagnostic()
  return require("nougat.nut.tab.tablist.label").hl.diagnostic()
end

local mod = {
  hl = hl,
}

---@param config nougat_item_config__nil
function mod.create(config)
  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    hl = config.hl,
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
