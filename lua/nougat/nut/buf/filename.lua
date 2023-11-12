local Item = require("nougat.item")

local function get_content(item, ctx)
  local config = item:config(ctx)
  local v = vim.fn.expand("%" .. config.modifier)
  if #v == 0 then
    v = config.unnamed
  elseif config.format then
    v = config.format(v, ctx)
  end
  return v
end

local mod = {}

function mod.create(opts)
  local item = Item({
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = get_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_extend("force", {
      modifier = ":.",
      format = nil,
      unnamed = "[No Name]",
    }, opts.config or {}),
    on_click = opts.on_click,
    context = opts.context,
    cache = {
      scope = "buf",
      invalidate = "BufFilePost",
    },
  })

  return item
end

return mod
