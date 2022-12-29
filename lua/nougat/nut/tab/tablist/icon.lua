local Item = require("nougat.item")
local has_devicons, devicons = pcall(require, "nvim-web-devicons")

local buffer_cache = require("nougat.cache.buffer")

buffer_cache.enable("filetype")

local filetype_overide = {
  fugitive = "git",
  gitcommit = "git",
}

---@type table<string, string>
local icon_char_by_ft = {}
---@type table<string, { fg: string }>
local icon_hl_by_ft = {}

local function get_content(item, ctx)
  return icon_char_by_ft[item.buf_cache[ctx.ctx.tab.bufnr].filetype]
end

local function get_hl(item, ctx)
  return icon_hl_by_ft[item.buf_cache[ctx.ctx.tab.bufnr].filetype]
end

local function prepare(item, ctx)
  local bufnr = ctx.ctx.tab.bufnr
  local cache = item.buf_cache[bufnr]

  local filetype = cache.filetype
  if not filetype then
    filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
    cache.filetype = filetype
  end

  filetype = filetype_overide[filetype] or filetype

  if not icon_char_by_ft[filetype] then
    local icon_char, icon_fg = devicons.get_icon_color_by_filetype(filetype, { default = true })
    icon_char_by_ft[filetype] = icon_char
    icon_hl_by_ft[filetype] = { fg = icon_fg }
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

  item.buf_cache = buffer_cache.store

  return item
end

return mod
