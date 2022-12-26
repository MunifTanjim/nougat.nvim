local Item = require("nougat.item")

local function get_content(item, ctx)
  local text = item:config(ctx).text
  return table.concat({
    vim.bo[ctx.bufnr].fileencoding,
    vim.bo[ctx.bufnr].bomb and text.bomb or "",
    vim.bo[ctx.bufnr].endofline and "" or text.noendofline,
  })
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
      text = {
        bomb = "[BOM]",
        noendofline = "[!EOL]",
      },
    }, opts.config or {}),
    on_click = opts.on_click,
    context = opts.context,
  })

  return item
end

return mod
