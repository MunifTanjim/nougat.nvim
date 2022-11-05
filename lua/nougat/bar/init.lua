local Object = require("nui.object")
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

---@class NougatBar
local Bar = Object("NougatBar")

---@param type 'statusline'|'tabline'|'winbar'
function Bar:init(type)
  self.id = next_id()
  self.type = type

  ---@type NougatItem[]
  self._items = {}
  self._hl_name = fallback_hl_name_by_type[self.type]
end

---@param item NougatItem
function Bar:add_item(item)
  self._items[#self._items + 1] = item
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
        if item.sep_left.hl then
          part_idx = part_idx + 1
          item_hl.sl = item.sep_left.hl
          item_hl.sl_idx = part_idx
        elseif item.hl then
          part_idx = part_idx + 1
          item_hl.c_idx = part_idx
        end

        part_idx = part_idx + 1
        parts[part_idx] = item.sep_left.content
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
            parts[part_idx] = item.prefix
          end
          part_idx = part_idx + 1
          parts[part_idx] = content
          if item.suffix then
            part_idx = part_idx + 1
            parts[part_idx] = item.suffix
          end
        end
      end

      if item.sep_right then
        if item.sep_right.hl then
          part_idx = part_idx + 1
          item_hl.sr = item.sep_right.hl
          item_hl.sr_idx = part_idx
        end

        part_idx = part_idx + 1
        parts[part_idx] = item.sep_right.content
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

---@alias NougatBar.constructor fun(type: 'statusline'|'tabline'|'winbar'): NougatBar
---@type NougatBar|NougatBar.constructor
local NougatBar = Bar

return NougatBar
