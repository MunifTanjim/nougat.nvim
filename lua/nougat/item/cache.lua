local cache_getter = {
  buf = function(item, ctx)
    return item._cache_store[ctx.bufnr][ctx.ctx.breakpoint]
  end,
  win = function(item, ctx)
    return item._cache_store[ctx.winid][ctx.ctx.breakpoint]
  end,
  tab = function(item, ctx)
    return item._cache_store[ctx.tabid][ctx.ctx.breakpoint]
  end,
  _wrap_fn = function(item, ctx)
    return item._cache_get(item._cache_store, ctx)
  end,
}

local mod = {
  cache_getter = cache_getter,
}

function mod.auto_cached_content(item, ctx)
  local c = item:cache(ctx)
  if not c._v then
    c._v = item:_get_content(ctx)
  end
  return c._v
end

---@param store table<integer, any>
---@param get_id fun(info: table): integer
---@param info table
function mod.invalidate_cache(store, get_id, info)
  local cache = store[get_id(info)]
  if cache then
    for key in pairs(cache) do
      cache[key] = nil
    end
  end
end

---@type table<string, fun(info: table): integer>
local id_getter_by_key = {
  buf = function(info)
    return info.buf
  end,
}

---@param event string
---@param scope? string
function mod.get_invalidation_id_getter(event, scope)
  if not scope or scope ~= "buf" then
    error("auto invalidation only supported for cache.scope=buf")
  end
  if string.sub(event, 1, 3):lower() == "buf" then
    return id_getter_by_key.buf
  end
  error("auto invalidation not supported for event: " .. event)
end

return mod
