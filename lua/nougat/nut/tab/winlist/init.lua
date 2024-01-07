local Item = require("nougat.item")
local TabStore = require("nougat.store").TabStore
local get_hl_def = require("nougat.color").get_hl_def

--luacheck: push no max line length

---@class nougat.nut.tab.winlist_config: nougat_item_config__function
---@field active_item? nougat_item_config|NougatItem
---@field inactive_item? nougat_item_config|NougatItem
---@field config? nil
---@field cache? nil
---@field content? nil

---@class nougat.nut.tab.winlist_ctx.tabbuf: nougat_bar_ctx
---@field filename string

---@class nougat.nut.tab.winlist_ctx: nougat.nut.tab.tablist_ctx
---@field tabbuf nougat.nut.tab.winlist_ctx.tabbuf

--luacheck: pop

local win_type = {
  [""] = true,
  loclist = true,
  quickfix = true,
}

local tab_store = TabStore("nut.tab.winlist", {
  on_click_open = {},
  count = 1,
})

local function list_winids(_, ctx)
  local tabid = ctx.tab and ctx.tab.tabid or ctx.tabid

  local winids, len = {}, 0
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabid)) do
    if win_type[vim.fn.win_gettype(winid)] then
      len = len + 1
      winids[len] = winid
    end
  end

  tab_store[tabid].count = len

  return winids
end

---@param item nougat.nut.tab.winlist
---@param ctx nougat_bar_ctx
local function content(item, ctx)
  local winids = list_winids(item, ctx)

  item.wins.ctx = ctx --[[@as nougat.nut.tab.winlist_ctx]]
  item.wins.len = #winids
  item.wins.winids = winids

  return item.wins
end

---@param wins nougat.nut.tab.winlist.wins
local function get_next_item(wins)
  local ctx, buf_ctx = wins.ctx, wins.buf_ctx
  ---@cast ctx -nil

  local idx = wins._idx + 1

  local winid = wins.winids[idx]

  if not winid then
    wins._idx = 0
    ctx.tabbuf = nil
    return nil, nil
  end

  wins._idx = idx

  local tabid = ctx.tab and ctx.tab.tabid or ctx.tabid

  buf_ctx.tabid, buf_ctx.winid, buf_ctx.bufnr = tabid, winid, vim.api.nvim_win_get_buf(winid)
  buf_ctx.is_focused = ctx.tabid == buf_ctx.tabid and ctx.bufnr == buf_ctx.bufnr
  buf_ctx.filename = vim.api.nvim_buf_get_name(buf_ctx.bufnr)

  ctx.tabbuf = buf_ctx

  return buf_ctx.is_focused and wins.active_item or wins.inactive_item, idx
end

local function get_default_item()
  return Item({
    content = {
      require("nougat.nut.tab.winlist.label").create({}),
    },
  })
end

local mod = {
  _tab_store = tab_store,
}

---@param config nougat.nut.tab.winlist_config
function mod.create(config)
  config = config or {}

  local active_item = config.active_item or get_default_item()
  if not active_item.hl then
    active_item.hl = get_hl_def("TabLineSel")
  end
  if not active_item.id then
    active_item = Item(active_item --[[@as nougat_item_config]])
    ---@cast active_item NougatItem
  end

  local inactive_item = config.inactive_item or get_default_item()
  if not inactive_item.hl then
    inactive_item.hl = get_hl_def("TabLine")
  end
  if not inactive_item.id then
    inactive_item = Item(inactive_item --[[@as nougat_item_config]])
    ---@cast inactive_item NougatItem
  end

  ---@class nougat.nut.tab.winlist: NougatItem
  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = content,
    suffix = config.suffix,
    sep_right = config.sep_right,
  })

  ---@class nougat.nut.tab.winlist.wins
  ---@field active_item NougatItem
  ---@field inactive_item NougatItem
  ---@field ctx? nougat.nut.tab.winlist_ctx
  ---@field buf_ctx nougat.nut.tab.winlist_ctx.tabbuf
  ---@field len integer
  ---@field _idx integer
  ---@field winids integer[]
  item.wins = {
    active_item = active_item,
    inactive_item = inactive_item,

    ctx = nil,
    buf_ctx = {},

    _idx = 0,
    len = 0,
    winids = {},

    next = get_next_item,
  }

  return item
end

return mod
