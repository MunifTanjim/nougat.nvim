local Item = require("nougat.item")
local get_hl_def = require("nougat.util.hl").get_hl_def
local get_hl_name = require("nougat.util.hl").get_hl_name
local u = require("nougat.util")

--luacheck: push no max line length

---@alias nougat_bar_hl integer|string|nougat_hl_def|(fun(self: NougatBar, ctx: nougat_core_expression_context): integer|string|nougat_hl_def)

--luacheck: pop

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

---@param bar NougatBar
---@param ctx nougat_core_expression_context
---@return nougat_hl_def bar_hl
---@return integer|string bar_hl_name
local function get_bar_hl(bar, ctx)
  local highlight = bar.hl

  if type(highlight) == "function" then
    highlight = highlight(bar, ctx)
  end

  if highlight == 0 then
    local hl_name = bar._hl_name[ctx.is_focused]
    return get_hl_def(hl_name), hl_name
  end

  if type(highlight) == "table" then
    return highlight, get_hl_name(highlight, highlight)
  end

  if type(highlight) == "string" then
    return get_hl_def(highlight), highlight
  end

  if type(highlight) == "number" then
    return get_hl_def("User" .. highlight), highlight
  end

  error("missing bar highlight")
end

---@param item NougatItem
---@return NougatItem
local function clone_item(item)
  local clone = {}
  for key, val in pairs(item) do
    clone[key] = val
  end
  return setmetatable(clone, getmetatable(item))
end

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

---@param type 'statusline'|'tabline'|'winbar'
---@param opts? { breakpoints?: integer[], hl?: nougat_bar_hl }
local function init(class, type, opts)
  ---@class NougatBar
  local self = setmetatable({}, { __index = class })

  self.id = next_id()
  self.type = type

  self._hl_name = fallback_hl_name_by_type[self.type]
  self.hl = opts and opts.hl or 0

  --luacheck: push no max line length
  ---@type NougatItem[]|{ len: integer, next: (fun(self: NougatItem[]): table,integer), _overflow?: 'hide-all'|'hide-self' }
  self._items = { len = 0, next = u.get_next_list_item }
  --luacheck: pop

  self._breakpoints = opts and opts.breakpoints or { 0 }
  self._get_breakpoint_index = get_breakpoint_index[get_breakpoint_type(self._breakpoints)]

  return self
end

---@class NougatBar
---@field hl nougat_bar_hl
local Bar = setmetatable({}, {
  __call = init,
  __name = "NougatBar",
})

---@param item string|table|NougatItem
---@return NougatItem
function Bar:add_item(item)
  if type(item) == "string" then
    item = Item({ content = item })
  elseif not item.id then
    item = Item(item)
  end

  local priority = item.priority

  if priority and not self._slots then
    self._slots = { len = 0 }
    self._items._overflow = "hide-self"
    self._items.next = nil
    u.initialize_priority_item_list(self._items)
  end

  local idx = self._items.len + 1
  self._items.len = idx

  if self._slots then
    item = clone_item(item)
    u.link_priority_item(self._items, item, idx)
  end

  self._items[idx] = item

  item:_init_breakpoints(self._breakpoints)

  return item
end

-- re-used tables
local o_hls = { len = 0 }
local o_parts = { len = 0 }

--luacheck: push no max line length
---@alias nougat_ctx nougat_core_expression_context|{ hls: nougat_lazy_item_hl[]|{ len: integer }, parts: string[]|{ len: integer }, width: integer, slots?: any[], available_width?: integer }
--luacheck: pop

---@param ctx nougat_ctx
function Bar:generate(ctx)
  ctx.ctx.breakpoint = self._get_breakpoint_index(ctx.width, self._breakpoints)

  local bar_hl, bar_hl_name = get_bar_hl(self, ctx)
  ctx.ctx.bar_hl, ctx.ctx.bar_hl_name = bar_hl, bar_hl_name

  o_hls.len, o_parts.len = 0, 0
  ctx.hls, ctx.parts = o_hls, o_parts

  if self._slots then
    local o_slots = self._slots
    o_slots.len = self._items.len
    ctx.slots = o_slots

    ctx.available_width = ctx.width

    u.prepare_priority_parts(self._items, ctx)
  else
    u.prepare_parts(self._items, ctx)
  end

  u.process_bar_highlights(ctx, bar_hl)

  return table.concat(o_parts, nil, 1, o_parts.len)
end

--luacheck: push no max line length

---@alias NougatBar.constructor fun(type: 'statusline'|'tabline'|'winbar', opts?: { breakpoints?: integer[] }): NougatBar
---@type NougatBar|NougatBar.constructor
local NougatBar = Bar

--luacheck: pop

return NougatBar
