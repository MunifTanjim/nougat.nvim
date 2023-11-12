local Item = require("nougat.item")

local buffer_cache = require("nougat.cache.buffer")
buffer_cache.enable("gitstatus")
buffer_cache.on("gitstatus.change", function(cache)
  cache.added_str = tostring(cache.added)
  cache.changed_str = tostring(cache.changed)
  cache.removed_str = tostring(cache.removed)
end)

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
  return function(item, ctx)
    return ctx.gitstatus[item._num_key] == 0
  end
end

local mod = {
  hidden = hidden,
}

---@param type 'added'|'changed'|'removed'
function mod.count(type, opts)
  local item = Item({
    hidden = opts.hidden == nil and hidden.if_zero_count() or opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = get_count_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    on_click = opts.on_click,
    context = opts.context,
  })

  item._num_key = type
  item._str_key = type .. "_str"

  return item
end

function mod.create(opts)
  local item = Item({
    prepare = get_prepare,
    hidden = get_hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = opts.content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    on_click = opts.on_click,
    context = opts.context,
    cache = {
      get = function(store, ctx)
        return store[ctx.bufnr]
      end,
      store = buffer_cache.store,
    },
  })

  return item
end

return mod
