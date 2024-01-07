local buf_cache = require("nougat.cache.buffer")
local Item = require("nougat.item")
local get_hl_def = require("nougat.color").get_hl_def

--luacheck: push no max line length

---@class nougat.nut.tab.tablist_config: nougat_item_config__function
---@field active_tab? nougat_item_config|NougatItem
---@field inactive_tab? nougat_item_config|NougatItem
---@field cache? nil
---@field config? nil
---@field content? nil

---@class nougat.nut.tab.tablist_ctx.tab: nougat_bar_ctx
---@field tabnr integer
---@field filename string

---@class nougat.nut.tab.tablist_ctx: nougat_bar_ctx
---@field tab nougat.nut.tab.tablist_ctx.tab

--luacheck: pop

---@param item nougat.nut.tab.tablist
---@param ctx nougat_bar_ctx
local function get_content(item, ctx)
  local tabids = vim.api.nvim_list_tabpages()

  item.tabs.ctx = ctx --[[@as nougat.nut.tab.tablist_ctx]]
  item.tabs.len = #tabids
  item.tabs.tabids = tabids

  return item.tabs
end

---@param tabs nougat.nut.tab.tablist.tabs
local function get_next_tab_item(tabs)
  local ctx, tab_ctx = tabs.ctx, tabs.tab_ctx
  ---@cast ctx -nil

  local idx = tabs._idx + 1

  local tabid = tabs.tabids[idx]

  if not tabid then
    tabs._idx = 0
    ctx.tab = nil
    return nil, nil
  end

  tabs._idx = idx

  tab_ctx.tabid, tab_ctx.tabnr = tabid, vim.api.nvim_tabpage_get_number(tabid)
  tab_ctx.winid = vim.api.nvim_tabpage_get_win(tabid)
  tab_ctx.bufnr = vim.api.nvim_win_get_buf(tab_ctx.winid)
  tab_ctx.is_focused = ctx.tabid == tabid
  tab_ctx.filename = buf_cache.get("filename", tab_ctx.bufnr) --[[@as string]]

  ctx.tab = tab_ctx

  return tab_ctx.is_focused and tabs.active_item or tabs.inactive_item, idx
end

local function get_default_tab()
  return Item({
    sep_left = { content = "▎" },
    content = {
      require("nougat.nut.tab.tablist.label").create({}),
      require("nougat.nut.tab.tablist.close").create({
        prefix = " ",
        suffix = " ",
      }),
    },
  })
end

local mod = {}

---@param config nougat.nut.tab.tablist_config
function mod.create(config)
  buf_cache.enable("filename")

  local active_item = config.active_tab or get_default_tab()
  if not active_item.hl then
    active_item.hl = get_hl_def("TabLineSel")
  end
  if not active_item.id then
    active_item = Item(active_item --[[@as nougat_item_config]])
    ---@cast active_item NougatItem
  end

  local inactive_item = config.inactive_tab or get_default_tab()
  if not inactive_item.hl then
    inactive_item.hl = get_hl_def("TabLine")
  end
  if not inactive_item.id then
    inactive_item = Item(inactive_item --[[@as nougat_item_config]])
    ---@cast inactive_item NougatItem
  end

  ---@class nougat.nut.tab.tablist: NougatItem
  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = get_content,
    suffix = config.suffix,
    sep_right = config.sep_right,
  })

  ---@class nougat.nut.tab.tablist.tabs
  ---@field active_item NougatItem
  ---@field inactive_item NougatItem
  ---@field ctx? nougat.nut.tab.tablist_ctx
  ---@field tab_ctx nougat.nut.tab.tablist_ctx.tab
  ---@field len integer
  ---@field _idx integer
  ---@field tabids integer[]
  item.tabs = {
    active_item = active_item,
    inactive_item = inactive_item,

    ctx = nil,
    tab_ctx = {},

    _idx = 0,
    len = 0,
    tabids = {},

    next = get_next_tab_item,
  }

  return item
end

return mod
