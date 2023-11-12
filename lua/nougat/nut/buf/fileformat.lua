local Item = require("nougat.item")

local function get_content(item, ctx)
  local fileformat = vim.api.nvim_buf_get_option(ctx.bufnr, "fileformat")
  return item:config(ctx).text[fileformat] or fileformat
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
      text = {},
    }, opts.config or {}),
    on_click = opts.on_click,
    context = opts.context,
    cache = {
      scope = "buf",
      invalidate = "BufWritePost",
    },
  })

  return item
end

return mod
