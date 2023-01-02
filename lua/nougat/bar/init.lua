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

---@param type 'statusline'|'tabline'|'winbar'
---@param opts? { breakpoints?: integer[] }
local function init(class, type, opts)
  ---@class NougatBar
  local self = setmetatable({}, { __index = class })

  self.id = next_id()
  self.type = type

  ---@type NougatItem[]
  self._items = {}
  self._hl_name = fallback_hl_name_by_type[self.type]

  self._breakpoints = opts and opts.breakpoints or { 0 }
  self._get_breakpoint_index = get_breakpoint_index[get_breakpoint_type(self._breakpoints)]

  return self
end

---@class NougatBar
local Bar = setmetatable({}, {
  __call = init,
  __name = "NougatBar",
})

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

-- re-used tables
local o_hls = { len = 0 }
local o_parts = { len = 0 }

--luacheck: push no max line length
---@alias nougat_ctx nougat_core_expression_context|{ hls: nougat_lazy_item_hl[]|{ len: integer }, parts: string[]|{ len: integer }, width: integer }
--luacheck: pop

---@param ctx nougat_ctx
function Bar:generate(ctx)
  ctx.ctx.breakpoint = self._get_breakpoint_index(ctx.width, self._breakpoints)

  local bar_hl = u.get_hl(self._hl_name[ctx.is_focused])
  ctx.ctx.bar_hl = bar_hl

  o_hls.len, o_parts.len = 0, 0
  ctx.hls, ctx.parts = o_hls, o_parts

  u.prepare_parts(self._items, ctx)
  u.process_bar_highlights(ctx, bar_hl)

  return table.concat(o_parts, nil, 1, o_parts.len)
end

--luacheck: push no max line length

---@alias NougatBar.constructor fun(type: 'statusline'|'tabline'|'winbar', opts?: { breakpoints?: integer[] }): NougatBar
---@type NougatBar|NougatBar.constructor
local NougatBar = Bar

--luacheck: pop

return NougatBar
