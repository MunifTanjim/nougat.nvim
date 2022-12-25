local Item = require("nougat.item")
local u = require("nougat.util")
local iu = require("nougat.item.util")

local function get_content(item, ctx)
  local active_tabid = ctx.tabid
  local tabids = vim.api.nvim_list_tabpages()

  local items = item.tabs.items
  local item_idx = 0

  for tidx = 1, #tabids do
    local tabid = tabids[tidx]

    local tab = tabid == active_tabid and item.active_tab or item.inactive_tab

    item_idx = item_idx + 1
    items[item_idx] = tab
  end

  item.tabs.ctx = ctx
  item.tabs.len = item_idx
  item.tabs.tabids = tabids

  u.prepare_parts(item.tabs, ctx)

  ctx.ctx.tab = nil
end

local function on_init_breakpoints(item, breakpoints)
  for _, tab in ipairs({ item.active_tab, item.inactive_tab }) do
    iu.prepare_property_breakpoints(tab, "sep_left", breakpoints)
    iu.prepare_property_breakpoints(tab, "prefix", breakpoints)
    iu.prepare_property_breakpoints(tab, "suffix", breakpoints)
    iu.prepare_property_breakpoints(tab, "sep_right", breakpoints)

    local tab_items = tab.content
    for idx = 1, #tab_items do
      tab_items[idx]:_init_breakpoints(breakpoints)
    end
  end
end

local tabs_metatable = {
  __index = function(tabs, idx)
    local ctx, tab_ctx = tabs.ctx, tabs.tab_ctx

    local tabid = tabs.tabids[idx]
    tab_ctx.tabid, tab_ctx.tabnr = tabid, vim.api.nvim_tabpage_get_number(tabid)
    tab_ctx.winid = vim.api.nvim_tabpage_get_win(tabid)
    tab_ctx.bufnr = vim.api.nvim_win_get_buf(tab_ctx.winid)
    tab_ctx.is_focused = ctx.tabid == tabid

    ctx.ctx.tab = tab_ctx

    return tabs.items[idx]
  end,
}

local default_tab_hl = {
  active = u.get_hl("TabLineSel"),
  inactive = u.get_hl("TabLine"),
}

local function get_default_tab()
  return {
    sep_left = { content = "▎" },
    content = {
      require("nougat.nut.tab.tablist.label").create({}),
      require("nougat.nut.tab.tablist.close").create({
        prefix = " ",
        suffix = " ",
      }),
    },
  }
end

local mod = {}

function mod.create(opts)
  local active_tab = opts.active_tab or get_default_tab()
  if not active_tab.hl then
    active_tab.hl = default_tab_hl.active
  end

  local inactive_tab = opts.inactive_tab or get_default_tab()
  if not inactive_tab.hl then
    inactive_tab.hl = default_tab_hl.inactive
  end

  for _, tab in ipairs({ active_tab, inactive_tab }) do
    tab.sep_left = iu.normalize_sep(-1, tab.sep_left)
    tab.prefix = type(tab.prefix) == "string" and { tab.prefix } or tab.prefix
    tab.suffix = type(tab.suffix) == "string" and { tab.suffix } or tab.suffix
    tab.sep_right = iu.normalize_sep(1, tab.sep_right)
  end

  local item = Item({
    hidden = opts.hidden,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    suffix = opts.suffix,
    sep_right = opts.sep_right,

    on_init_breakpoints = on_init_breakpoints,
  })

  item.content = get_content

  item.active_tab = active_tab
  item.inactive_tab = inactive_tab

  item.tabs = setmetatable({
    ctx = nil,
    tab_ctx = {},

    len = 0,
    items = {},
    tabids = {},
  }, tabs_metatable)

  return item
end

return mod
