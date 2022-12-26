local Item = require("nougat.item")

local function get_content(item, ctx)
  return item:config(ctx).text
end

local function hidden(_, ctx)
  return not vim.bo[ctx.ctx.tab.bufnr].modified
end

local mod = {}

function mod.create(opts)
  local item = Item({
    hidden = hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_deep_extend("force", {
      text = "+",
    }, opts.config or {}),
  })

  item.content = get_content

  return item
end

return mod
