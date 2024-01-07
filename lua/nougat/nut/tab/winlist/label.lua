local core = require("nougat.core")
local Item = require("nougat.item")
local tab_store = require("nougat.nut.tab.winlist")._tab_store

local get_on_click = function(context)
  ---@type nougat_core_click_handler
  local open = tab_store[context.tabid].on_click_open[context.bufnr]
  if not open then
    ---@type nougat_core_click_handler
    open = function(_, _, _, _, ctx)
      local ctx_ids = vim.split(ctx.ctx, ":")
      local tabid = tonumber(ctx_ids[1]) --[[@as integer]]
      local bufnr = tonumber(ctx_ids[2]) --[[@as integer]]
      if tabid ~= ctx.tabid then
        vim.api.nvim_set_current_tabpage(tabid)
      end
      local winid = vim.fn.bufwinid(bufnr) --[[@as integer]]
      if winid ~= -1 then
        vim.api.nvim_set_current_win(winid)
      end
    end

    tab_store[context.tabid].on_click_open[context.bufnr] = open
  end
  return open
end

-- re-used tables
local o_label_opts = { context = nil }
local o_label_parts = {}

---@param ctx nougat.nut.tab.winlist_ctx
local function get_label_content(_, ctx)
  local tabid = ctx.tabbuf.tabid
  local bufnr = ctx.tabbuf.bufnr
  o_label_opts.context = string.format("%s:%s", tabid, bufnr)
  o_label_opts.on_click = get_on_click(ctx.tabbuf)
  local label = vim.bo[bufnr].buftype == "" and vim.fn.fnamemodify(ctx.tabbuf.filename, ":t") --[[@as string]]
    or vim.bo[bufnr].filetype
  local parts_len = core.add_clickable(label, o_label_opts, o_label_parts, 0)
  return table.concat(o_label_parts, nil, 1, parts_len)
end

local mod = {}

---@param config nougat_item_config__nil
function mod.create(config)
  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = get_label_content,
    suffix = config.suffix,
    sep_right = config.sep_right,
  })

  return item
end

return mod
