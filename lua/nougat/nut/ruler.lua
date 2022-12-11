local core = require("nui.bar.core")
local Item = require("nougat.item")

local mod = {}

function mod.create(opts)
  return Item({
    content = core.ruler(),
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
  })
end

return mod
