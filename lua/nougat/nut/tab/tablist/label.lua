local core = require("nui.bar.core")
local Item = require("nougat.item")

-- re-used table
local o_label_opts = { tabnr = nil, close = false }

local function get_content(_, ctx)
  local tab_ctx = ctx.ctx.tab
  o_label_opts.tabnr = tab_ctx.tabnr
  return core.label(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(tab_ctx.bufnr), ":t"), o_label_opts)
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
    on_click = opts.on_click,
    context = opts.context,
  })

  return item
end

return mod
