local Item = require("nougat.item")
local has_devicons, devicons = pcall(require, "nvim-web-devicons")

local filetype_overide = {
  fugitive = "git",
  gitcommit = "git",
}

local function get_content(_, ctx)
  return vim.api.nvim_buf_get_var(ctx.ctx.tab.bufnr, "ft_icon")[1]
end

local function get_hl(_, ctx)
  return vim.api.nvim_buf_get_var(ctx.ctx.tab.bufnr, "ft_icon")[2]
end

local function prepare(_, ctx)
  local bufnr = ctx.ctx.tab.bufnr

  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  filetype = filetype_overide[filetype] or filetype

  if not vim.fn.getbufvar(bufnr, "ft_icon", false) then
    local icon_char, icon_fg = devicons.get_icon_color_by_filetype(filetype, { default = true })
    vim.api.nvim_buf_set_var(bufnr, "ft_icon", { icon_char, { fg = icon_fg } })
  end
end

local mod = {}

function mod.create(opts)
  local item = Item({
    prepare = prepare,
    hidden = opts.hidden,
    hl = get_hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = get_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    on_click = opts.on_click,
    context = opts.context,
  })

  if not has_devicons then
    item.hidden = true
  end

  return item
end

return mod
