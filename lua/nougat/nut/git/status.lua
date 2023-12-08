local Item = require("nougat.item")
local buf_cache = require("nougat.cache.buffer")

--luacheck: push no max line length

---@class nougat.nut.git.status.count_config: nougat_item_config__function
---@field content? nil
---@field config? nil

---@class nougat.nut.git.status_config: nougat_item_config__nil
---@field cache? nil
---@field content? NougatItem[]
---@field hidden? nil
---@field prepare? nil

--luacheck: pop

---@param item NougatItem
local function get_prepare(item, ctx)
  ctx.gitstatus = item:cache(ctx).gitstatus
end

local function get_hidden(_, ctx)
  return not ctx.gitstatus or ctx.gitstatus.total == 0
end

local function get_count_content(item, ctx)
  return ctx.gitstatus[item._str_key]
end

local hidden = {}

function hidden.if_zero_count()
  ---@param item NougatItem
  return function(item, ctx)
    return ctx.gitstatus[item._num_key] == 0
  end
end

local mod = {
  hidden = hidden,
}

---@param type 'added'|'changed'|'removed'
---@param config nougat.nut.git.status.count_config
function mod.count(type, config)
  local item = Item({
    priority = config.priority,
    hidden = config.hidden == nil and hidden.if_zero_count() or config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = get_count_content,
    suffix = config.suffix,
    sep_right = config.sep_right,
    on_click = config.on_click,
    context = config.context,
  })

  item._num_key = type
  item._str_key = type .. "_str"

  return item
end

local function on_gitstatus_change(cache)
  cache.added_str = tostring(cache.added)
  cache.changed_str = tostring(cache.changed)
  cache.removed_str = tostring(cache.removed)
end

---@param config nougat.nut.git.status_config
function mod.create(config)
  buf_cache.enable("gitstatus")
  buf_cache.on("gitstatus.change", on_gitstatus_change)

  local item = Item({
    priority = config.priority,
    prepare = get_prepare,
    hidden = get_hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = config.content,
    suffix = config.suffix,
    sep_right = config.sep_right,
    on_click = config.on_click,
    context = config.context,
    cache = {
      get = function(store, ctx)
        return store[ctx.bufnr]
      end,
      store = buf_cache.store,
    },
  })

  return item
end

return mod
