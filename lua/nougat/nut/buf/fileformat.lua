local Item = require("nougat.item")

local function get_content(item, ctx)
  local fileformat = vim.bo[ctx.bufnr].fileformat
  return item:config(ctx).text[fileformat] or fileformat
end

local mod = {}

function mod.create(opts)
  local item = Item({
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_extend("force", {
      text = {},
    }, opts.config or {}),
  })

  item.content = get_content

  return item
end

return mod
