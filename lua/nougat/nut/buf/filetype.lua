local Item = require("nougat.item")

local mod = {}

function mod.create(opts)
  return Item({
    priority = opts.priority,
    type = "vim_expr",
    is_vimscript = true,
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = "&filetype",
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    on_click = opts.on_click,
    context = opts.context,
  })
end

return mod
