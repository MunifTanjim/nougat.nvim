local Item = require("nougat.item")
local has_devicons, devicons = pcall(require, "nvim-web-devicons")

local filetype_overide = {
  fugitive = "git",
  gitcommit = "git",
}

local function get_content(_, ctx)
  return vim.b[ctx.ctx.tab.bufnr].ft_icon[1]
end

local function get_hl(_, ctx)
  return vim.b[ctx.ctx.tab.bufnr].ft_icon[2]
end

local function refresh(_, ctx)
  local tab_ctx = ctx.ctx.tab

  local filetype = vim.bo[tab_ctx.bufnr].filetype
  filetype = filetype_overide[filetype] or filetype

  if not vim.b[tab_ctx.bufnr].ft_icon then
    local icon_char, icon_fg = devicons.get_icon_color_by_filetype(filetype, { default = true })
    vim.b[tab_ctx.bufnr].ft_icon = { icon_char, { fg = icon_fg } }
  end
end

local mod = {}

function mod.create(opts)
  local item = Item({
    hidden = opts.hidden,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
  })

  if not has_devicons then
    item.hidden = true
  end

  item.hl = get_hl
  item.content = get_content
  item.refresh = refresh

  return item
end

return mod
