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
  return icon_char_by_ft[item:cache(ctx).filetype]
end

local function get_hl(item, ctx)
  return icon_hl_by_ft[item:cache(ctx).filetype]
end

local function prepare(item, ctx)
  local filetype = item:cache(ctx).filetype or ""

  if not icon_char_by_ft[filetype] then
    local ft = filetype_overide[filetype] or filetype
    local icon_char, icon_fg = devicons.get_icon_color_by_filetype(ft, { default = true })
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
    cache = {
      get = function(store, ctx)
        return store[ctx.tab.bufnr]
      end,
      store = buffer_cache.store,
    },
  })

  if not has_devicons then
    item.hidden = true
  end

  return item
end

return mod
