local core = require("nougat.core")
local Item = require("nougat.item")

-- re-used table
local o_label_opts = { tabnr = nil, close = false }

local function get_content(_, ctx)
  local tab_ctx = ctx.tab
  o_label_opts.tabnr = tab_ctx.tabnr
  return core.label(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(tab_ctx.bufnr), ":t"), o_label_opts)
end

local hl = {}

local diagnostic_cache, diagnostic_severity, diagnostic_hl_group_by_severity

local function hl_diagnostic(_, ctx)
  return diagnostic_hl_group_by_severity[diagnostic_cache[ctx.tab.bufnr].max]
end

function hl.diagnostic()
  if not diagnostic_cache then
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

      diagnostic_cache = ncd.store
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
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = get_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    on_click = opts.on_click,
    context = opts.context,
    cache = {
      scope = "buf",
      get = function(store, ctx)
        return store[ctx.tab.bufnr][ctx.ctx.breakpoint]
      end,
      invalidate = "BufFilePost",
    },
  })

  return item
end

return mod
