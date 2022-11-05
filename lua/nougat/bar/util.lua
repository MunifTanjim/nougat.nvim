local core = require("nui.bar.core")

local config = {
  statusline = {},
}

local statusline = config.statusline

local statusline_generator = core.generator(function(ctx)
  local select = statusline.select

  return vim.api.nvim_win_call(ctx.winid, function()
    local stl = type(select) == "function" and select(ctx) or select
    return stl and stl:generate(ctx) or ""
  end)
end, {
  id = "nougat.go.statusline",
  context = {},
})

local statusline_by_filetype_generator = core.generator(function(ctx)
  local select = statusline.by_filetype[vim.bo[ctx.bufnr].filetype]

  return vim.api.nvim_win_call(ctx.winid, function()
    local stl = type(select) == "function" and select(ctx) or select
    return stl and stl:generate(ctx) or ""
  end)
end, {
  id = "nougat.wo.statusline.by_filetype",
  context = {},
})

---@param filetype string
---@param bar NougatBar|(fun(ctx:nui_bar_core_expression_context):NougatBar)
local function set_statusline_for_filetype(filetype, bar)
  if not statusline.by_filetype then
    statusline.by_filetype = {}

    local augroup = vim.api.nvim_create_augroup("nougat.wo.statusline.by_filetype", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      callback = function(info)
        local bufnr, ft = info.buf, info.match
        if statusline.by_filetype[ft] then
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              vim.api.nvim_buf_call(bufnr, function()
                vim.wo.statusline = statusline_by_filetype_generator
              end)
            end
          end)
        end
      end,
    })
  end

  statusline.by_filetype[filetype] = bar
end

local mod = {}

---@param bar NougatBar|(fun(ctx:nui_bar_core_expression_context):NougatBar)
---@param opts? { filetype?: string }
function mod.set_statusline(bar, opts)
  opts = opts or {}

  if opts.filetype then
    set_statusline_for_filetype(opts.filetype, bar)
  else
    statusline.select = bar

    vim.go.statusline = statusline_generator
  end
end

---@param focused_only? boolean
function mod.refresh_statusline(focused_only)
  if focused_only then
    vim.cmd("redrawstatus")
    return
  end

  vim.cmd("redrawstatus!")
end

return mod
