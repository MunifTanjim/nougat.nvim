local core = require("nougat.core")
local Item = require("nougat.item")

local function get_label_tabnr_content(_, ctx)
  return "%" .. ctx.tab.tabnr .. "T"
end

-- re-used tables
local o_label_opts = { tabnr = nil, close = false }
local o_label_parts = {}

---@param ctx nougat.nut.tab.tablist_ctx
local function get_label_content(_, ctx)
  o_label_opts.tabnr = "x"
  local parts_len = core.add_label(vim.fn.fnamemodify(ctx.tab.filename, ":t"), o_label_opts, o_label_parts, 0)
  return table.concat(o_label_parts, nil, 4, parts_len)
end

local hl = {}

local diagnostic_cache = require("nougat.cache.diagnostic")
local diagnostic_severity = diagnostic_cache.severity
local diagnostic_cache_store = diagnostic_cache.store

local diagnostic_hl_group_by_severity = {
  [diagnostic_severity.ERROR] = "DiagnosticError",
  [diagnostic_severity.WARN] = "DiagnosticWarn",
  [diagnostic_severity.INFO] = "DiagnosticInfo",
  [diagnostic_severity.HINT] = "DiagnosticHint",
}

local function hl_diagnostic(_, ctx)
  return diagnostic_hl_group_by_severity[diagnostic_cache_store[ctx.tab.bufnr].max]
end

local function calculate_max_diagnostic_severity(cache)
  if cache[diagnostic_severity.ERROR] > 0 then
    cache.max = diagnostic_severity.ERROR
  elseif cache[diagnostic_severity.WARN] > 0 then
    cache.max = diagnostic_severity.WARN
  elseif cache[diagnostic_severity.INFO] > 0 then
    cache.max = diagnostic_severity.INFO
  elseif cache[diagnostic_severity.HINT] > 0 then
    cache.max = diagnostic_severity.HINT
  else
    cache.max = 0
  end
end

function hl.diagnostic()
  diagnostic_cache.enable()
  diagnostic_cache.on("change", calculate_max_diagnostic_severity)
  return hl_diagnostic
end

local mod = {
  hl = hl,
}

---@param config nougat_item_config__nil
function mod.create(config)
  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    -- NOTE: splitting label_tabnr and label because we don't have TabMoved autocmd event.
    -- Upstream PR: https://github.com/neovim/neovim/pull/24137
    content = {
      Item({
        content = get_label_tabnr_content,
      }),
      Item({
        content = get_label_content,
        cache = {
          scope = "buf",
          ---@param ctx nougat.nut.tab.tablist_ctx
          get = function(store, ctx)
            return store[ctx.tab.bufnr][ctx.breakpoint]
          end,
          clear = "BufFilePost",
        },
      }),
    },
    suffix = config.suffix,
    sep_right = config.sep_right,
    on_click = config.on_click,
    context = config.context,
  })

  return item
end

return mod
