local Item = require("nougat.item")
local buf_cache = require("nougat.cache.buffer")

local has_devicons, devicons = pcall(require, "nvim-web-devicons")

--luacheck: push no max line length

---@class nougat.nut.buf.filetype_icon_config: nougat_item_config__function
---@field config? nil
---@field _get_bufnr? fun(ctx:nougat_bar_ctx):integer

--luacheck: pop

local filetype_overide = {
  fugitive = "git",
  gitcommit = "git",
}

local function prepare(item, ctx)
  local filetype = buf_cache.get("filetype", item._get_bufnr(ctx)) or ""
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

local function default_get_bufnr(ctx)
  return ctx.bufnr
end

local cache_initial_value = { c = nil, hl = { bg = "bg" } }

local mod = {}

---@param config nougat.nut.buf.filetype_icon_config
function mod.create(config)
  buf_cache.enable("filetype")

  local get_bufnr = config._get_bufnr or default_get_bufnr

  local item = Item({
    init = function(item)
      item._get_bufnr = get_bufnr
    end,
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
      name = "nut.buf.filetype_icon",
      scope = "buf",
      get = function(store, ctx)
        return store[get_bufnr(ctx)]
      end,
      initial_value = cache_initial_value,
      clear = "BufFilePost",
    },
  })

  return item
end

return mod
