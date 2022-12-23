local core = require("nui.bar.core")
local Item = require("nougat.item")
local u = require("nougat.util")

-- re-used table
local o_tab_item_parts = {}

local function get_tab_item_content(item, ctx)
  local config = item:config(ctx)

  local tab_ctx = ctx.ctx.tab
  local tabnr = tab_ctx.tabnr

  local part_idx = 0

  local label_opts = { tabnr = tabnr, close = false }

  part_idx = core.add_label(
    vim.fn.fnamemodify(vim.api.nvim_buf_get_name(tab_ctx.bufnr), ":t"),
    label_opts,
    o_tab_item_parts,
    part_idx
  )

  if config.close then
    label_opts.close = true

    part_idx = part_idx + 1
    o_tab_item_parts[part_idx] = " "

    part_idx = core.add_label(config.close, label_opts, o_tab_item_parts, part_idx)
  end

  o_tab_item_parts.len = part_idx

  return o_tab_item_parts
end

local function get_content(item, ctx)
  local bar_hl = ctx.ctx.bar_hl

  local hl = type(item.hl) == "function" and item:hl(ctx) or item.hl
  if type(hl) == "string" then
    hl = u.get_hl(hl)
  elseif type(hl) == "number" then
    hl = u.get_hl("User" .. hl)
  end
  hl.bg, hl.fg = hl.bg or bar_hl.bg, hl.fg or bar_hl.fg

  local tabids = vim.api.nvim_list_tabpages()

  item.processor.ctx = ctx
  item.processor.len = #tabids
  item.processor.tabids = tabids

  return u.prepare_parts(item.processor, ctx, hl)
end

local function on_init_breakpoints(item, breakpoints)
  item.processor.active_item:_init_breakpoints(breakpoints)
  item.processor.inactive_item:_init_breakpoints(breakpoints)
end

local processor_metatable = {
  __index = function(processor, idx)
    local ctx = processor.ctx

    local tab_ctx = processor.tab_ctx

    local tabid = processor.tabids[idx]
    tab_ctx.tabid, tab_ctx.tabnr = tabid, vim.api.nvim_tabpage_get_number(tabid)
    tab_ctx.winid = vim.api.nvim_tabpage_get_win(tabid)
    tab_ctx.bufnr = vim.api.nvim_win_get_buf(tab_ctx.winid)

    ctx.ctx.tab = tab_ctx

    return tabid == ctx.tabid and processor.active_item or processor.inactive_item
  end,
}

local mod = {}

function mod.TabItem(opts)
  local item = Item({
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_deep_extend("force", {
      close = "",
    }, opts.config or {}),
  })

  item.content = get_tab_item_content

  return item
end

function mod.create(opts)
  local config = vim.tbl_deep_extend("force", {}, opts.config or {})

  local processor = {
    ctx = nil,
    len = 0,
    tabids = {},

    tab_ctx = {},

    active_item = config.active_tab or mod.TabItem({ hl = "TabLineSel", prefix = " ", suffix = " " }),
    inactive_item = config.inactive_tab or mod.TabItem({ hl = "TabLine", prefix = " ", suffix = " " }),
  }

  config.active_tab, config.inactive_tab = nil, nil

  local item = Item({
    hidden = opts.hidden,
    hl = opts.hl or {},
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = config,

    on_init_breakpoints = on_init_breakpoints,
  })

  item.processor = setmetatable(processor, processor_metatable)

  item.content = get_content

  return item
end

return mod
