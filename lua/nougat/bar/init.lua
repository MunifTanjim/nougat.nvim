local Object = require("nui.object")
local Item = require("nougat.item")
local core = require("nui.bar.core")
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

local function normalize_item(item, breakpoints)
  for i = 1, #breakpoints do
    local base_config = item._config[i - 1] or item._config
    item._config[i] = vim.tbl_deep_extend("keep", item._config[i] or {}, base_config)
  end

  for _, key in ipairs({ "sep_left", "prefix", "suffix", "sep_right" }) do
    local val = item[key]

    if val then
      for i = 1, #breakpoints do
        if not val[i] then
          val[i] = val[i - 1]
        end
      end
    end
  end

  return item
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

  return normalize_item(self._items[idx], self._breakpoints)
end

-- re-used table
---@type { bg?: string, fg?: string }
local o_sep_hl_def = {}

local function prepare_o_sep_hl_def(hl_s, prev_hl_c, hl_c, next_hl_c)
  o_sep_hl_def.bg, o_sep_hl_def.fg = hl_s.bg, hl_s.fg or hl_c and hl_c.bg or "bg"

  if o_sep_hl_def.bg == -1 then
    o_sep_hl_def.bg = prev_hl_c and prev_hl_c.bg or nil
  elseif o_sep_hl_def.bg == 1 then
    o_sep_hl_def.bg = next_hl_c and next_hl_c.bg or nil
  end

  if o_sep_hl_def.fg == -1 then
    o_sep_hl_def.fg = prev_hl_c and prev_hl_c.fg or nil
  elseif o_sep_hl_def.fg == 1 then
    o_sep_hl_def.fg = next_hl_c and next_hl_c.fg or nil
  end

  return o_sep_hl_def
end

---@param ctx nui_bar_core_expression_context
function Bar:generate(ctx)
  ctx.width = self._get_width(ctx.winid)

  local breakpoint = self._get_breakpoint_index(ctx.width, self._breakpoints)
  ctx.ctx.breakpoint = breakpoint

  local bar_hl = u.get_hl(self._hl_name[ctx.is_focused])
  ctx.ctx.bar_hl = bar_hl

  local part_idx = 0
  local parts = {}

  local item_hl_idx = 0
  local item_hls = {}

  for item_idx = 1, #self._items do
    local _item = self._items[item_idx]

    if _item.refresh then
      _item:refresh(ctx)
    end

    local item = _item:generate(ctx)

    if item then
      local item_hl = { c = nil, c_idx = nil, sl = nil, sl_idx = nil, sr = nil, sr_idx = nil }

      if item.sep_left then
        local sep = item.sep_left[breakpoint]

        if sep.hl then
          part_idx = part_idx + 1
          item_hl.sl = sep.hl
          item_hl.sl_idx = part_idx
        elseif item.hl then
          part_idx = part_idx + 1
          item_hl.c_idx = part_idx
        end

        part_idx = part_idx + 1
        parts[part_idx] = sep.content
      end

      if item.hl then
        local hl_c = type(item.hl) == "function" and item:hl(ctx) or item.hl
        if type(hl_c) == "table" then
          item_hl.c = hl_c
        elseif type(hl_c) == "string" then
          item_hl.c = u.get_hl(hl_c)
        elseif type(hl_c) == "number" then
          item_hl.c = u.get_hl("User" .. hl_c)
        else
          item_hl.c = nil
        end

        if not item_hl.c_idx then
          part_idx = part_idx + 1
          item_hl.c_idx = part_idx
        end
      elseif item_hl.sl then
        part_idx = part_idx + 1
        parts[part_idx] = core.highlight()
      end

      if item.content then
        local content = item.content
        if type(content) == "function" then
          content = item:content(ctx) or ""
        end

        if #content > 0 then
          if item.prefix then
            part_idx = part_idx + 1
            parts[part_idx] = item.prefix[breakpoint]
          end
          part_idx = part_idx + 1
          parts[part_idx] = content
          if item.suffix then
            part_idx = part_idx + 1
            parts[part_idx] = item.suffix[breakpoint]
          end
        end
      end

      if item.sep_right then
        local sep = item.sep_right[breakpoint]

        if sep.hl then
          part_idx = part_idx + 1
          item_hl.sr = sep.hl
          item_hl.sr_idx = part_idx
        end

        part_idx = part_idx + 1
        parts[part_idx] = sep.content
      end

      if item_hl.c or item_hl.sl or item_hl.sr then
        part_idx = part_idx + 1
        parts[part_idx] = core.highlight()
      end

      item_hl_idx = item_hl_idx + 1
      item_hls[item_hl_idx] = item_hl
    end
  end

  for idx = 1, item_hl_idx do
    local prev_hl_c, hl, next_hl_c =
      idx > 1 and item_hls[idx - 1].c, item_hls[idx], idx < item_hl_idx and item_hls[idx + 1].c

    if hl.sl then
      parts[hl.sl_idx] = core.highlight(u.set_hl(prepare_o_sep_hl_def(hl.sl, prev_hl_c, hl.c, next_hl_c), bar_hl))
    end

    if hl.c then
      parts[hl.c_idx] = core.highlight(u.set_hl(hl.c, bar_hl))
    end

    if hl.sr then
      parts[hl.sr_idx] = core.highlight(u.set_hl(prepare_o_sep_hl_def(hl.sr, prev_hl_c, hl.c, next_hl_c), bar_hl))
    end
  end

  return table.concat(parts)
end

--luacheck: push no max line length

---@alias NougatBar.constructor fun(type: 'statusline'|'tabline'|'winbar', opts?: { breakpoints?: integer[] }): NougatBar
---@type NougatBar|NougatBar.constructor
local NougatBar = Bar

--luacheck: pop

return NougatBar
