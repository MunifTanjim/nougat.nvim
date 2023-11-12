local core = require("nougat.core")
local Item = require("nougat.item")

local function get_label_tabnr_content(_, ctx)
  return "%" .. ctx.tab.tabnr .. "T"
end

-- re-used tables
local o_label_opts = { tabnr = nil, close = false }
local o_label_parts = {}

local function get_label_content(_, ctx)
  o_label_opts.tabnr = "x"
  local parts_len = core.add_label(vim.fn.fnamemodify(ctx.tab.filename, ":t"), o_label_opts, o_label_parts, 0)
  return table.concat(o_label_parts, nil, 4, parts_len)
end

local hl = {}

local diagnostic_cache_store, diagnostic_severity, diagnostic_hl_group_by_severity

local function hl_diagnostic(_, ctx)
  return diagnostic_hl_group_by_severity[diagnostic_cache_store[ctx.tab.bufnr].max]
end

function hl.diagnostic()
  if not diagnostic_cache_store then
    do
      local ncd = require("nougat.cache.diagnostic")
      ncd.on("update", function(cache)
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
      end)

      diagnostic_cache_store = ncd.store
      diagnostic_severity = ncd.severity
      diagnostic_hl_group_by_severity = {
        [diagnostic_severity.ERROR] = "DiagnosticError",
        [diagnostic_severity.WARN] = "DiagnosticWarn",
        [diagnostic_severity.INFO] = "DiagnosticInfo",
        [diagnostic_severity.HINT] = "DiagnosticHint",
      }
    end
  end

  return hl_diagnostic
end

local mod = {
  hl = hl,
}

function mod.create(opts)
  local item = Item({
    priority = opts.priority,
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
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
          get = function(store, ctx)
            return store[ctx.tab.bufnr][ctx.ctx.breakpoint]
          end,
          invalidate = "BufFilePost",
        },
      }),
    },
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    on_click = opts.on_click,
    context = opts.context,
  })

  return item
end

return mod
