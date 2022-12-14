local Item = require("nougat.item")
local create_cache_store = require("nougat.cache").create_store

local cache_store = create_cache_store("buf", "nut.buf.wordcount", {
  -- buffer changedtick
  ct = -1,
  --- value
  v = -1,
})

local function get_wordcount(format)
  local wordcount = vim.fn.wordcount()
  local count = wordcount.visual_words or wordcount.words
  return format(count)
end

local in_visual_mode = {
  ["v"] = true,
  ["vs"] = true,
  ["V"] = true,
  ["Vs"] = true,
  [""] = true,
  ["s"] = true,
}

local function get_content(item, ctx)
  local config = item:config(ctx)

  if in_visual_mode[vim.fn.mode()] then
    return get_wordcount(config.format)
  end

  local cache = item.cache[ctx.bufnr]

  local changedtick = vim.api.nvim_buf_get_var(ctx.bufnr, "changedtick")
  if cache.ct ~= changedtick then
    cache.ct = changedtick
    cache.v = get_wordcount(config.format)
  end

  return cache.v
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
      format = tostring,
    }, opts.config or {}),
    on_click = opts.on_click,
    context = opts.context,
  })

  item.cache = cache_store

  return item
end

return mod
