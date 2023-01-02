local core = require("nougat.core")
local store = require("nougat.bar.store")

local statusline = store.statusline
local tabline = store.tabline
local winbar = store.winbar

local option_value_global_opts = { scope = "global" }

local statusline_generator = core.generator(function(ctx)
  ctx.width = vim.api.nvim_get_option_value("laststatus", option_value_global_opts) == 3
      and vim.api.nvim_get_option_value("columns", option_value_global_opts)
    or vim.api.nvim_win_get_width(ctx.winid)

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
  ctx.width = vim.api.nvim_get_option_value("laststatus", option_value_global_opts) == 3
      and vim.api.nvim_get_option_value("columns", option_value_global_opts)
    or vim.api.nvim_win_get_width(ctx.winid)

  local select = statusline.by_filetype[vim.api.nvim_buf_get_option(ctx.bufnr, "filetype")]

  return vim.api.nvim_win_call(ctx.winid, function()
    local stl = type(select) == "function" and select(ctx) or select
    return stl and stl:generate(ctx) or ""
  end)
end, {
  id = "nougat.wo.statusline.by_filetype",
  context = {},
})

local tabline_generator = core.generator(function(ctx)
  ctx.width = vim.api.nvim_get_option_value("columns", option_value_global_opts)

  local select = tabline.select

  return vim.api.nvim_win_call(ctx.winid, function()
    local tal = type(select) == "function" and select(ctx) or select
    return tal and tal:generate(ctx) or ""
  end)
end, {
  id = "nougat.go.tabline",
  context = {},
})

local winbar_generator = core.generator(function(ctx)
  ctx.width = vim.api.nvim_win_get_width(ctx.winid)

  local select = winbar.select

  return vim.api.nvim_win_call(ctx.winid, function()
    local wbr = type(select) == "function" and select(ctx) or select
    return wbr and wbr:generate(ctx) or ""
  end)
end, {
  id = "nougat.go.winbar",
  context = {},
})

local winbar_by_filetype_generator = core.generator(function(ctx)
  ctx.width = vim.api.nvim_win_get_width(ctx.winid)

  local select = winbar.by_filetype[vim.api.nvim_buf_get_option(ctx.bufnr, "filetype")]

  return vim.api.nvim_win_call(ctx.winid, function()
    local wbr = type(select) == "function" and select(ctx) or select
    return wbr and wbr:generate(ctx) or ""
  end)
end, {
  id = "nougat.wo.winbar.by_filetype",
  context = {},
})

---@param filetype string
---@param bar NougatBar|(fun(ctx:nougat_core_expression_context):NougatBar)
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
                vim.api.nvim_win_set_option(0, "statusline", statusline_by_filetype_generator)
              end)
            end
          end)
        end
      end,
    })
  end

  statusline.by_filetype[filetype] = bar
end

---@param bar NougatBar|(fun(ctx:nougat_core_expression_context):NougatBar)
local function set_winbar_local(bar)
  winbar.select = bar

  local augroup = vim.api.nvim_create_augroup("nougat.wo.winbar", { clear = true })

  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = augroup,
    callback = function()
      if vim.fn.win_gettype(0) == "popup" then
        return
      end

      vim.api.nvim_win_set_option(0, "winbar", winbar_generator)
    end,
  })
end

---@param filetype string
---@param bar NougatBar|(fun(ctx:nougat_core_expression_context):NougatBar)
local function set_winbar_for_filetype(filetype, bar)
  if not winbar.by_filetype then
    winbar.by_filetype = {}

    local augroup = vim.api.nvim_create_augroup("nougat.wo.winbar.by_filetype", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      callback = function(info)
        local bufnr, ft = info.buf, info.match
        if winbar.by_filetype[ft] then
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              vim.api.nvim_buf_call(bufnr, function()
                vim.api.nvim_win_set_option(0, "winbar", winbar_by_filetype_generator)
              end)
            end
          end)
        end
      end,
    })
  end

  winbar.by_filetype[filetype] = bar
end

local mod = {}

---@param bar NougatBar|(fun(ctx:nougat_core_expression_context):NougatBar)
---@param opts? { filetype?: string }
function mod.set_statusline(bar, opts)
  opts = opts or {}

  if opts.filetype then
    set_statusline_for_filetype(opts.filetype, bar)
  else
    statusline.select = bar

    vim.api.nvim_set_option_value("statusline", statusline_generator, option_value_global_opts)
  end
end

---@param force_all? boolean
function mod.refresh_statusline(force_all)
  if force_all then
    vim.cmd("redrawstatus!")
    return
  end

  vim.cmd("redrawstatus")
end

function mod.set_tabline(bar)
  tabline.select = bar

  vim.api.nvim_set_option_value("tabline", tabline_generator, option_value_global_opts)
end

function mod.refresh_tabline()
  vim.cmd("redrawtabline")
end

---@param bar NougatBar|(fun(ctx:nougat_core_expression_context):NougatBar)
---@param opts? { filetype?: string, global?: boolean }
function mod.set_winbar(bar, opts)
  opts = opts or {}

  if opts.filetype then
    set_winbar_for_filetype(opts.filetype, bar)
  elseif opts.global then
    winbar.select = bar
    vim.api.nvim_set_option_value("winbar", winbar_generator, option_value_global_opts)
  else
    set_winbar_local(bar)
  end
end

---@param force_all? boolean
function mod.refresh_winbar(force_all)
  if force_all then
    vim.cmd("redrawstatus!")
    return
  end

  vim.cmd("redrawstatus")
end

return mod
