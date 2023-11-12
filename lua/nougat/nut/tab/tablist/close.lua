local core = require("nougat.core")
local Item = require("nougat.item")

-- re-used table
local o_label_opts = { tabnr = nil, close = true }

local function get_content(item, ctx)
  local config = item:config(ctx)
  o_label_opts.tabnr = ctx.tab.tabnr
  return core.label(config.text, o_label_opts)
end

local mod = {}

function mod.create(opts)
  local item = Item({
    priority = opts.priority,
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = get_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_deep_extend("force", {
      text = "X",
    }, opts.config or {}),
    on_click = opts.on_click,
    context = opts.context,
  })

  return item
end

return mod
