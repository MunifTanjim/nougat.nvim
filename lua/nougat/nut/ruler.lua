local core = require("nougat.core")
local Item = require("nougat.item")

local mod = {}

function mod.create(opts)
  return Item({
    priority = opts.priority,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = core.ruler(),
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    on_click = opts.on_click,
    context = opts.context,
  })
end

return mod
