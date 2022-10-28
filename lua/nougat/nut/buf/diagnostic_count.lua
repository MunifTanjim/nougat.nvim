local Item = require("nougat.item")
local core = require("nui.bar.core")
local create_cache_store = require("nougat.cache").create_store
local u = require("nougat.util")

local severity = vim.deepcopy(vim.diagnostic.severity)
severity.COMBINED = severity.ERROR + severity.WARN + severity.INFO + severity.HINT

local cache_store = create_cache_store("buf", "nut_buf_diagnostic_count", {
  [severity.ERROR] = 0,
  [severity.WARN] = 0,
  [severity.INFO] = 0,
  [severity.HINT] = 0,
  [severity.COMBINED] = 0,
  -- combined content
  cc = nil,
})

local function get_count_content(item, ctx)
  local count = item.cache[ctx.bufnr][item.config.severity]
  return count > 0 and tostring(count) or ""
end

local function get_combined_content(item, ctx)
  local cache = item.cache[ctx.bufnr]

  if cache.cc then
    return cache.cc
  end

  local config = item.config

  cache.cc = ""

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
      parts[part_idx + 1] = core.highlight(u.set_hl(config.error, item_hl))
      parts[part_idx + 2] = config.error.prefix
      parts[part_idx + 3] = cache[severity.ERROR]
      parts[part_idx + 4] = config.error.suffix
      part_idx = part_idx + 4
    end

    if config.warn and cache[severity.WARN] > 0 then
      if part_idx > 0 and config.sep then
        parts[part_idx + 1] = sep_hl
        parts[part_idx + 2] = config.sep
        part_idx = part_idx + 2
      end
      parts[part_idx + 1] = core.highlight(u.set_hl(config.warn, item_hl))
      parts[part_idx + 2] = config.warn.prefix
      parts[part_idx + 3] = cache[severity.WARN]
      parts[part_idx + 4] = config.warn.suffix
      part_idx = part_idx + 4
    end

    if config.info and cache[severity.INFO] > 0 then
      if part_idx > 0 and config.sep then
        parts[part_idx + 1] = sep_hl
        parts[part_idx + 2] = config.sep
        part_idx = part_idx + 2
      end
      parts[part_idx + 1] = core.highlight(u.set_hl(config.info, item_hl))
      parts[part_idx + 2] = config.info.prefix
      parts[part_idx + 3] = cache[severity.INFO]
      parts[part_idx + 4] = config.info.suffix
      part_idx = part_idx + 4
    end

    if config.hint and cache[severity.HINT] > 0 then
      if part_idx > 0 and config.sep then
        parts[part_idx + 1] = sep_hl
        parts[part_idx + 2] = config.sep
        part_idx = part_idx + 2
      end
      parts[part_idx + 1] = core.highlight(u.set_hl(config.hint, item_hl))
      parts[part_idx + 2] = config.hint.prefix
      parts[part_idx + 3] = cache[severity.HINT]
      parts[part_idx + 4] = config.hint.suffix
    end

    cache.cc = table.concat(parts)
  end)

  return cache.cc
end

local augroup = vim.api.nvim_create_augroup("nougat.nut.buf.diagnostic_count", { clear = true })

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = augroup,
  callback = function(params)
    local error, warn, info, hint = 0, 0, 0, 0

    local diagnostics = vim.diagnostic.get(params.buf)

    for idx = 1, #diagnostics do
      local diagnostic = diagnostics[idx]
      if diagnostic.severity == severity.ERROR then
        error = error + 1
      elseif diagnostic.severity == severity.WARN then
        warn = warn + 1
      elseif diagnostic.severity == severity.INFO then
        info = info + 1
      elseif diagnostic.severity == severity.HINT then
        hint = hint + 1
      end
    end

    local cache = cache_store[params.buf]
    if cache[severity.ERROR] ~= error then
      cache[severity.ERROR] = error
      cache.cc = nil
    end
    if cache[severity.WARN] ~= warn then
      cache[severity.WARN] = warn
      cache.cc = nil
    end
    if cache[severity.INFO] ~= info then
      cache[severity.INFO] = info
      cache.cc = nil
    end
    if cache[severity.HINT] ~= hint then
      cache[severity.HINT] = hint
      cache.cc = nil
    end
    cache[severity.COMBINED] = error + warn + info + hint
  end,
  desc = "[nougat] nut.buf.diagnostic_count",
})

local mod = {}

function mod.create(opts)
  local item = Item({
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
  })

  item.cache = cache_store

  if opts.config and opts.config.severity then
    item.config = { severity = opts.config.severity }
  else
    item.config = vim.tbl_deep_extend("force", {
      error = { prefix = "E:", suffix = "", fg = "red" },
      warn = { prefix = "W:", suffix = "", fg = "yellow" },
      info = { prefix = "I:", suffix = "", fg = "lightblue" },
      hint = { prefix = "H:", suffix = "", fg = "lightgreen" },
      sep = " ",
      severity = severity.COMBINED,
    }, opts.config or {})

    if item.config.sep and #item.config.sep == 0 then
      item.config.sep = nil
    end
  end

  item.content = item.config.severity == severity.COMBINED and get_combined_content or get_count_content

  return item
end

return mod
