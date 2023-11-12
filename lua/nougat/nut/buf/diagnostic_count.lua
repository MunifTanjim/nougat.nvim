local Item = require("nougat.item")
local core = require("nougat.core")
local u = require("nougat.util")

local diagnostic_cache = require("nougat.cache.diagnostic")
local severity = diagnostic_cache.severity

diagnostic_cache.on("update", function(cache)
  -- previous combined content
  cache.pcc = cache.cc
  -- invalidate combined content
  cache.cc = nil
end)

local function default_hidden(item, ctx)
  return item:cache(ctx)[item:config(ctx).severity] == 0
end

local function get_count_content(item, ctx)
  local config = item:config(ctx)
  local count = item:cache(ctx)[config.severity]
  return count > 0 and tostring(count) or ""
end

local function get_combined_content(item, ctx)
  local cache = item:cache(ctx)

  if cache.cc then
    -- show cached combined content
    return cache.cc
  end

  -- show previous combined content, when current one is cooking
  cache.cc = cache.pcc

  local config = item:config(ctx)

  -- cook combined content lazily
  vim.schedule(function()
    local part_idx, parts = 0, {}

    local bar_hl = ctx.ctx.bar_hl
    local item_hl = item.hl or bar_hl
    local sep_hl = config.sep and core.highlight(u.set_hl(item.hl or {}, bar_hl))

    if config.error and cache[severity.ERROR] > 0 then
      if part_idx > 0 and config.sep then
        parts[part_idx + 1] = sep_hl
        parts[part_idx + 2] = config.sep
        part_idx = part_idx + 2
      end
      part_idx = core.add_highlight(u.set_hl(config.error, item_hl), nil, parts, part_idx)
      parts[part_idx + 1] = config.error.prefix
      parts[part_idx + 2] = cache[severity.ERROR]
      parts[part_idx + 3] = config.error.suffix
      part_idx = part_idx + 3
    end

    if config.warn and cache[severity.WARN] > 0 then
      if part_idx > 0 and config.sep then
        parts[part_idx + 1] = sep_hl
        parts[part_idx + 2] = config.sep
        part_idx = part_idx + 2
      end
      part_idx = core.add_highlight(u.set_hl(config.warn, item_hl), nil, parts, part_idx)
      parts[part_idx + 1] = config.warn.prefix
      parts[part_idx + 2] = cache[severity.WARN]
      parts[part_idx + 3] = config.warn.suffix
      part_idx = part_idx + 3
    end

    if config.info and cache[severity.INFO] > 0 then
      if part_idx > 0 and config.sep then
        parts[part_idx + 1] = sep_hl
        parts[part_idx + 2] = config.sep
        part_idx = part_idx + 2
      end
      part_idx = core.add_highlight(u.set_hl(config.info, item_hl), nil, parts, part_idx)
      parts[part_idx + 1] = config.info.prefix
      parts[part_idx + 2] = cache[severity.INFO]
      parts[part_idx + 3] = config.info.suffix
      part_idx = part_idx + 3
    end

    if config.hint and cache[severity.HINT] > 0 then
      if part_idx > 0 and config.sep then
        parts[part_idx + 1] = sep_hl
        parts[part_idx + 2] = config.sep
        part_idx = part_idx + 2
      end
      part_idx = core.add_highlight(u.set_hl(config.hint, item_hl), nil, parts, part_idx)
      parts[part_idx + 1] = config.hint.prefix
      parts[part_idx + 2] = cache[severity.HINT]
      parts[part_idx + 3] = config.hint.suffix
      part_idx = part_idx + 3
    end

    cache.cc = table.concat(parts, nil, 1, part_idx)
    cache.pcc = nil
  end)

  return cache.cc
end

local hidden = {}

local function hidden_if_zero(item, ctx)
  return item:cache(ctx)[item:config(ctx).severity] == 0
end

function hidden.if_zero()
  return hidden_if_zero
end

local mod = {
  hidden = hidden,
}

function mod.create(opts)
  local config
  if opts.config and opts.config.severity then
    config = { severity = opts.config.severity }
  else
    config = vim.tbl_deep_extend("force", {
      error = { prefix = "E:", suffix = "", fg = "red" },
      warn = { prefix = "W:", suffix = "", fg = "yellow" },
      info = { prefix = "I:", suffix = "", fg = "lightblue" },
      hint = { prefix = "H:", suffix = "", fg = "lightgreen" },
      sep = " ",
      severity = severity.COMBINED,
    }, opts.config or {})
    ---@cast config -nil

    if config.sep and #config.sep == 0 then
      config.sep = nil
    end
  end

  local item = Item({
    priority = opts.priority,
    hidden = opts.hidden == nil and default_hidden or opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = config.severity == severity.COMBINED and get_combined_content or get_count_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = config,
    on_click = opts.on_click,
    context = opts.context,
    cache = {
      get = function(store, ctx)
        return store[ctx.bufnr]
      end,
      store = diagnostic_cache.store,
    },
  })

  return item
end

return mod
