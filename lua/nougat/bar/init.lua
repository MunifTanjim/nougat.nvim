local Object = require("nui.object")
local Item = require("nougat.item")
local u = require("nougat.util")

local next_id = u.create_id_generator()

local fallback_hl_name_by_type = {
  statusline = {
    [true] = "StatusLine",
    [false] = "StatusLineNC",
  },
  tabline = {
    [true] = "TabLineFill",
    [false] = "TabLineFill",
  },
  winbar = {
    [true] = "WinBar",
    [false] = "WinBarNC",
  },
}

---@type table<'statusline'|'tabline'|'winbar', fun(winid: integer): integer>
local get_width = {
  statusline = function(winid)
    return vim.go.laststatus == 3 and vim.go.columns or vim.api.nvim_win_get_width(winid)
  end,
  tabline = function()
    return vim.go.columns
  end,
  winbar = function(winid)
    return vim.api.nvim_win_get_width(winid)
  end,
}

---@type table<'min'|'max', fun(width: integer, breakpoints: integer[]): integer>
local get_breakpoint_index = {
  min = function(width, breakpoints)
    for idx = #breakpoints, 1, -1 do
      if width >= breakpoints[idx] then
        return idx
      end
    end
    return 0
  end,
  max = function(width, breakpoints)
    for idx = #breakpoints, 1, -1 do
      if width <= breakpoints[idx] then
        return idx
      end
    end
    return 0
  end,
}

---@param breakpoints integer[]
---@returns 'min'|'max'
local function get_breakpoint_type(breakpoints)
  if breakpoints[1] ~= 0 and breakpoints[1] ~= math.huge then
    error("breakpoints[1] must be 0 or math.huge")
  end

  if #breakpoints == 1 then
    return breakpoints[1] == 0 and "min" or "max"
  end

  return breakpoints[1] < breakpoints[2] and "min" or "max"
end

---@class NougatBar
local Bar = Object("NougatBar")

---@param type 'statusline'|'tabline'|'winbar'
---@param opts? { breakpoints?: integer[] }
function Bar:init(type, opts)
  self.id = next_id()
  self.type = type

  ---@type NougatItem[]
  self._items = {}
  self._hl_name = fallback_hl_name_by_type[self.type]

  self._breakpoints = opts and opts.breakpoints or { 0 }
  self._get_breakpoint_index = get_breakpoint_index[get_breakpoint_type(self._breakpoints)]

  self._get_width = get_width[type]
end

---@param item string|table|NougatItem
---@return NougatItem
function Bar:add_item(item)
  local idx = #self._items + 1

  if type(item) == "string" then
    self._items[idx] = Item({ content = item })
  elseif not item.id then
    self._items[idx] = Item(item)
  else
    self._items[idx] = item
  end

  local new_item = self._items[idx]

  new_item:_init_breakpoints(self._breakpoints)

  return new_item
end

-- re-used table
local o_parts = { len = 0 }

---@param ctx nui_bar_core_expression_context
function Bar:generate(ctx)
  ctx.width = self._get_width(ctx.winid)

  ctx.ctx.breakpoint = self._get_breakpoint_index(ctx.width, self._breakpoints)

  local bar_hl = u.get_hl(self._hl_name[ctx.is_focused])
  ctx.ctx.bar_hl = bar_hl

  o_parts.len = 0
  ctx.parts = o_parts

  u.prepare_parts(self._items, ctx, bar_hl)

  return table.concat(o_parts, nil, 1, o_parts.len)
end

--luacheck: push no max line length

---@alias NougatBar.constructor fun(type: 'statusline'|'tabline'|'winbar', opts?: { breakpoints?: integer[] }): NougatBar
---@type NougatBar|NougatBar.constructor
local NougatBar = Bar

--luacheck: pop

return NougatBar
