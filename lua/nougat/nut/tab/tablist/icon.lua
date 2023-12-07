local Item = require("nougat.item")
local buf_cache = require("nougat.cache.buffer")

local has_devicons, devicons = pcall(require, "nvim-web-devicons")

--luacheck: push no max line length

---@class nougat.nut.tab.tablist.icon_config: nougat_item_config__function
---@field config? nil

--luacheck: pop

local filetype_overide = {
  fugitive = "git",
  gitcommit = "git",
}

local function prepare(item, ctx)
  local filetype = buf_cache.get("filetype", ctx.tab.bufnr) or ""
  local cache = item:cache(ctx)
  if not cache.c then
    local ft = filetype_overide[filetype] or filetype
    cache.c, cache.hl.fg = devicons.get_icon_color_by_filetype(ft, { default = true })
  end
end

local function hl(item, ctx)
  return item:cache(ctx).hl
end

local function content(item, ctx)
  return item:cache(ctx).c
end

local cache_initial_value = { c = nil, hl = {} }

local mod = {}

---@param config nougat.nut.tab.tablist.icon_config
function mod.create(config)
  buf_cache.enable("filetype")

  local item = Item({
    priority = config.priority,
    prepare = has_devicons and prepare or config.prepare,
    hidden = config.hidden,
    hl = has_devicons and hl or config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = has_devicons and content or config.content or "◌",
    suffix = config.suffix,
    sep_right = config.sep_right,
    on_click = config.on_click,
    context = config.context,
    cache = {
      name = "nut.tab.tablist.icon",
      scope = "buf",
      get = function(store, ctx)
        return store[ctx.tab.bufnr]
      end,
      initial_value = cache_initial_value,
      clear = "BufFilePost",
    },
  })

  return item
end

return mod
