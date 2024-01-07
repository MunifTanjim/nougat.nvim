local Item = require("nougat.item")
local get_hl_def = require("nougat.color").get_hl_def
local TabStore = require("nougat.store").TabStore
local on_event = require("nougat.util.on_event")

--luacheck: push no max line length

---@class nougat.nut.tab.buflist_config: nougat_item_config__function
---@field active_item? nougat_item_config|NougatItem
---@field inactive_item? nougat_item_config|NougatItem
---@field config? nil
---@field cache? nil
---@field content? nil

---@class nougat.nut.tab.buflist_ctx.buf: nougat_bar_ctx
---@field filename string

---@class nougat.nut.tab.buflist_ctx: nougat.nut.tab.tablist_ctx
---@field tabbuf nougat.nut.tab.buflist_ctx.buf

--luacheck: pop

---@class nougat.nut.tab.buflist._tab_store
local tab_store = TabStore("nut.tab.buflist", {
  on_click_open = {},
  bufnrs = {},
  count = 1,
})

---@param bufnr integer
tab_store.filter_bufnr = function(bufnr)
  return vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == ""
end

local function list_bufnrs(_, ctx)
  local tabid = ctx.tab and ctx.tab.tabid or ctx.tabid

  if tabid == ctx.tabid then
    local bufnrs, len = {}, 0
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(bufnr) and tab_store.filter_bufnr(bufnr) then
        len = len + 1
        bufnrs[len] = bufnr
      end
    end

    tab_store[tabid].count = len

    return bufnrs
  end

  return tab_store[tabid].bufnrs
end

---@param item nougat.nut.tab.buflist
---@param ctx nougat_bar_ctx
local function content(item, ctx)
  local bufnrs = list_bufnrs(item, ctx)

  item.bufs.ctx = ctx --[[@as nougat.nut.tab.buflist_ctx]]
  item.bufs.len = #bufnrs
  item.bufs.bufnrs = bufnrs

  return item.bufs
end

---@param bufs nougat.nut.tab.buflist.bufs
local function get_next_item(bufs)
  local ctx, buf_ctx = bufs.ctx, bufs.buf_ctx
  ---@cast ctx -nil

  local idx = bufs._idx + 1

  local bufnr = bufs.bufnrs[idx]

  if not bufnr then
    bufs._idx = 0
    ctx.tabbuf = nil
    return nil, nil
  end

  bufs._idx = idx

  local tabid = ctx.tab and ctx.tab.tabid or ctx.tabid

  buf_ctx.tabid, buf_ctx.bufnr = tabid, bufnr
  buf_ctx.is_focused = ctx.tabid == buf_ctx.tabid and ctx.bufnr == buf_ctx.bufnr
  if buf_ctx.is_focused then
    buf_ctx.winid = vim.fn.bufwinid(bufnr) --[[@as integer]]
  else
    buf_ctx.winid = vim.api.nvim_win_call(vim.api.nvim_tabpage_get_win(tabid), function()
      return vim.fn.bufwinid(bufnr)
    end)
  end
  buf_ctx.filename = vim.api.nvim_buf_get_name(buf_ctx.bufnr)

  ctx.tabbuf = buf_ctx

  return buf_ctx.is_focused and bufs.active_item or bufs.inactive_item, idx
end

local function get_default_item()
  return Item({
    content = {
      require("nougat.nut.tab.buflist.label").create({}),
    },
  })
end

local mod = {
  _tab_store = tab_store,
}

local function on_tab_leave()
  local tabid = vim.api.nvim_get_current_tabpage()
  local bufnrs = vim.tbl_filter(tab_store.filter_bufnr, vim.api.nvim_list_bufs())
  tab_store[tabid].bufnrs = bufnrs
  tab_store[tabid].count = #bufnrs
  for _, bufnr in pairs(bufnrs) do
    vim.bo[bufnr].buflisted = false
  end
end

local function on_tab_enter()
  local tabid = vim.api.nvim_get_current_tabpage()
  local bufnrs = tab_store[tabid].bufnrs
  if bufnrs then
    for _, bufnr in pairs(bufnrs) do
      vim.bo[bufnr].buflisted = true
    end
  end
end

---@param config nougat.nut.tab.buflist_config
function mod.create(config)
  config = config or {}

  on_event("TabLeave", on_tab_leave)
  on_event("TabEnter", on_tab_enter)

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

  ---@class nougat.nut.tab.buflist: NougatItem
  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = content,
    suffix = config.suffix,
    sep_right = config.sep_right,
  })

  ---@class nougat.nut.tab.buflist.bufs
  ---@field active_item NougatItem
  ---@field inactive_item NougatItem
  ---@field ctx? nougat.nut.tab.buflist_ctx
  ---@field buf_ctx nougat.nut.tab.buflist_ctx.buf
  ---@field len integer
  ---@field _idx integer
  ---@field bufnrs integer[]
  item.bufs = {
    active_item = active_item,
    inactive_item = inactive_item,

    ctx = nil,
    buf_ctx = {},

    _idx = 0,
    len = 0,
    bufnrs = {},

    next = get_next_item,
  }

  return item
end

return mod
