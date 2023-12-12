local core = require("nougat.core")
local Item = require("nougat.item")
local get_hl_name = require("nougat.color").get_hl_name
local u = require("nougat.util")
local hl_u = require("nougat.bar.hl")

--luacheck: push no max line length

---@alias nougat_bar_type 'statusline'|'tabline'|'winbar'

---@alias nougat_bar_hl integer|string|nougat_hl_def|(fun(self: NougatBar, ctx: nougat_core_expression_context): integer|string|nougat_hl_def)

---@class nougat_bar_config
---@field breakpoints? integer[]
---@field hl? nougat_bar_hl

---@class nougat_bar_ctx: nougat_core_expression_context
---@field ctx table
---@field breakpoint integer current breakpoint
---@field hl nougat_hl_def fallback highlight for current item
---@field width integer width of the bar
---@field hls nougat_lazy_item_hl[]|{ len: integer } (internal)
---@field parts string[]|{ len: integer } (internal)
---@field slots? any[] (internal)
---@field available_width? integer (internal)

--luacheck: pop

local prepare_highlights = hl_u.prepare_highlights
local resolve_bar_hl, resolve_item_hl = hl_u.resolve_bar_hl, hl_u.resolve_item_hl

---@param affix nougat_item_affix
---@param item NougatItem
---@param ctx nougat_bar_ctx
---@param breakpoint integer
local function resolve_item_affix(affix, item, ctx, breakpoint)
  if type(affix) == "function" then
    return affix(item, ctx) or ""
  end

  return affix[breakpoint]
end

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
---@return 'min'|'max'
local function get_breakpoint_type(breakpoints)
  if breakpoints[1] ~= 0 and breakpoints[1] ~= math.huge then
    error("breakpoints[1] must be 0 or math.huge")
  end

  if #breakpoints == 1 then
    return breakpoints[1] == 0 and "min" or "max"
  end

  return breakpoints[1] < breakpoints[2] and "min" or "max"
end

local get_next_id = u.create_id_generator()

---@param type nougat_bar_type
---@param config? nougat_bar_config
local function init(class, type, config)
  ---@class NougatBar
  local self = setmetatable({}, { __index = class })

  self.id = get_next_id()
  self.type = type

  self._hl_name = fallback_hl_name_by_type[self.type]
  self.hl = config and config.hl or 0

  --luacheck: push no max line length
  ---@type NougatItem[]|{ len: integer, next: (fun(self: NougatItem[]): NougatItem,integer), _overflow?: 'hide-all'|'hide-self' }
  self._items = { len = 0, next = u.get_next_list_item }
  --luacheck: pop

  self._breakpoints = config and config.breakpoints or { 0 }
  self._get_breakpoint_index = get_breakpoint_index[get_breakpoint_type(self._breakpoints)]

  self._parts = { len = 0 }
  self._hls = { len = 0 }
  self._hl = { bg = nil, fg = nil }

  return self
end

---@class NougatBar
---@field type nougat_bar_type
---@field hl nougat_bar_hl
local Bar = setmetatable({}, {
  __call = init,
  __name = "NougatBar",
})

---@param item string|nougat_item_config|NougatItem
---@return NougatItem
function Bar:add_item(item)
  if type(item) == "string" then
    item = Item({ content = item })
  elseif not item.id then
    item = Item(item --[[@as nougat_item_config]])
  end
  ---@cast item NougatItem

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

---@param hls nougat_lazy_item_hl[]
---@param hl_idx integer
---@return nougat_lazy_item_hl
local function get_item_hl_table(hls, hl_idx)
  ---@type nougat_lazy_item_hl
  local item_hl = hls[hl_idx]
  if not item_hl then
    item_hl = { fb = {} }
    hls[hl_idx] = item_hl
  end

  item_hl.c = nil
  item_hl.c_idx = nil
  item_hl.sl = nil
  item_hl.sl_idx = nil
  item_hl.sr = nil
  item_hl.sr_idx = nil
  item_hl.fc_idx = nil
  item_hl.lc_idx = nil
  -- item_hl.fb.bg, item_hl.fb.fg = nil, nil
  item_hl.x = nil

  return item_hl
end

---@param items NougatItem[]|{ len?: integer, next: (fun(self: NougatItem[]): NougatItem,integer) }
---@param ctx nougat_bar_ctx
function Bar.__prepare_parts(items, ctx)
  local breakpoint = ctx.breakpoint

  local hls, parts = ctx.hls, ctx.parts
  local hl_idx, part_idx

  local ctx_hl = ctx.hl
  local reset_hl_bg, reset_hl_fg, reset_hl_name = ctx_hl.bg, ctx_hl.fg, get_hl_name(ctx_hl, ctx_hl)

  local item = items:next()
  while item do
    hl_idx, part_idx = hls.len, parts.len

    if item.prepare then
      item:prepare(ctx)
    end

    local hidden = item.hidden and (item.hidden == true or item:hidden(ctx))

    if not hidden then
      hl_idx = hl_idx + 1

      local item_hl = get_item_hl_table(hls, hl_idx)
      item_hl.fb.bg, item_hl.fb.fg = reset_hl_bg, reset_hl_fg

      if item.sep_left then
        local sep = item.sep_left[breakpoint]

        if sep.content then
          item_hl.sl = resolve_item_hl(sep.hl, item, ctx)

          if item_hl.sl then
            item_hl.sl_idx = part_idx
            part_idx = part_idx + 3
          elseif item.hl then
            item_hl.c = resolve_item_hl(item.hl, item, ctx)

            if item_hl.c then
              item_hl.c_idx = part_idx
              part_idx = part_idx + 3
            end
          end

          part_idx = part_idx + 1
          parts[part_idx] = sep.content
        end
      end

      -- content hl is not added yet
      if not item_hl.c_idx then
        -- content hl is not resolved yet
        if item_hl.c ~= false then
          item_hl.c = resolve_item_hl(item.hl, item, ctx)
        end

        if item_hl.c then
          item_hl.c_idx = part_idx
          part_idx = part_idx + 3
        elseif item_hl.sl_idx then -- sep_left hl was added
          -- separator's highlight should not bleed into content
          part_idx = core.add_highlight(reset_hl_name, nil, parts, part_idx)
        end
      end

      if item_hl.c then
        ctx_hl.bg, ctx_hl.fg = item_hl.c.bg or ctx_hl.bg, item_hl.c.fg or ctx_hl.fg
      else
        ctx_hl.bg, ctx_hl.fg = reset_hl_bg, reset_hl_fg
      end

      if item.content then
        if item.prefix then
          part_idx = part_idx + 1
          parts[part_idx] = resolve_item_affix(item.prefix, item, ctx, breakpoint)
        end

        local content = item.content
        local content_type = type(content)
        if content_type == "function" then
          hls.len = hl_idx
          parts.len = part_idx

          content = item:content(ctx) or ""
          content_type = type(content)

          hl_idx = hls.len
        end

        if (content_type == "table" and content.len or #content) > 0 then
          if content_type == "table" then
            if type(content[1]) == "string" then
              ---@cast content string[]
              for idx = 1, (content.len or #content) do
                part_idx = part_idx + 1
                parts[part_idx] = content[idx]
              end
            else
              hls.len = hl_idx
              parts.len = part_idx

              if not content.next then
                content.next = u.get_next_list_item
              end

              ---@cast content NougatItem[]
              Bar.__prepare_parts(content, ctx)

              if hl_idx ~= hls.len then
                local total_child_hls = hls.len - hl_idx
                hl_idx = hls.len
                item_hl.fc_idx = total_child_hls == 1 and hl_idx or hl_idx - total_child_hls + 1
                item_hl.lc_idx = hl_idx
              end
              part_idx = parts.len
            end
          else
            part_idx = part_idx + 1
            parts[part_idx] = content
          end

          if item.suffix then
            part_idx = part_idx + 1
            parts[part_idx] = resolve_item_affix(item.suffix, item, ctx, breakpoint)
          end
        else -- no content returned
          if part_idx == parts.len then -- no parts added
            if item.prefix then
              -- discard prefix
              part_idx = part_idx - 1
              parts.len = part_idx
            end
          else
            part_idx = parts.len
          end
        end
      end

      if item.sep_right then
        local sep = item.sep_right[breakpoint]

        if sep.content then
          item_hl.sr = resolve_item_hl(sep.hl, item, ctx)

          if item_hl.sr then
            item_hl.sr_idx = part_idx
            part_idx = part_idx + 3
          end

          part_idx = part_idx + 1
          parts[part_idx] = sep.content
        end
      end

      if item_hl.c or item_hl.sl or item_hl.sr then
        part_idx = core.add_highlight(reset_hl_name, nil, parts, part_idx)
      end

      if item.hl == false then
        hl_idx = hl_idx - 1
      end
    end

    hls.len = hl_idx
    parts.len = part_idx

    item = items:next()
  end
end

---@param slots table<integer, (string|table)[]|{ hl: nougat_lazy_item_hl, len: integer }|nil>
---@param idx integer
---@return (string|table)[]|{ hl: nougat_lazy_item_hl, len: integer }
local function get_item_parts_slot(slots, idx)
  local slot = slots[idx]
  if not slot then
    slot = { hl = { fb = {} } }
    slots[idx] = slot
  end

  local item_hl = slot.hl
  item_hl.c = nil
  item_hl.c_idx = nil
  item_hl.sl = nil
  item_hl.sl_idx = nil
  item_hl.sr = nil
  item_hl.sr_idx = nil
  item_hl.fc_idx = nil
  item_hl.lc_idx = nil
  -- item_hl.fb.bg, item_hl.fb.fg = nil, nil
  item_hl.x = nil

  return slot
end

---@type { winid?: integer }
local o_eval_stl_opts = {}

---@param items NougatItem[]|{ len?: integer, next: (fun(self: NougatItem[]): NougatItem,integer) }
---@param ctx nougat_bar_ctx
function Bar.__prepare_slots(items, ctx)
  local available_width = ctx.available_width

  local initial_available_width = available_width

  local ctx_hl = ctx.hl
  local reset_hl_bg, reset_hl_fg, reset_hl_name = ctx_hl.bg, ctx_hl.fg, get_hl_name(ctx_hl, ctx_hl)

  local breakpoint = ctx.breakpoint

  local slots = ctx.slots
  ---@cast slots -nil

  local item, item_idx = items:next()
  while item do
    local slot_initial_available_width = available_width

    local parts = get_item_parts_slot(slots, item_idx)
    local item_hl = parts.hl
    item_hl.fb.bg, item_hl.fb.fg = reset_hl_bg, reset_hl_fg

    local part_idx = 0

    local should_skip_slot

    if available_width >= 0 then
      if item.prepare then
        item:prepare(ctx)
      end

      local hidden = item.hidden and (item.hidden == true or item:hidden(ctx))

      if not hidden then
        if item.sep_left then
          local sep = item.sep_left[breakpoint]

          if sep.content then
            item_hl.sl = resolve_item_hl(sep.hl, item, ctx)

            if item_hl.sl then
              item_hl.sl_idx = part_idx
              part_idx = part_idx + 3
            elseif item.hl then
              item_hl.c = resolve_item_hl(item.hl, item, ctx)

              if item_hl.c then
                item_hl.c_idx = part_idx
                part_idx = part_idx + 3
              end
            end

            part_idx = part_idx + 1
            parts[part_idx] = sep.content

            available_width = available_width - vim.api.nvim_strwidth(sep.content)
          else
            part_idx = part_idx + 1
            parts[part_idx] = ""
          end
        end

        -- content hl is not added yet
        if not item_hl.c_idx then
          -- content hl is not resolved yet
          if item_hl.c ~= false then
            item_hl.c = resolve_item_hl(item.hl, item, ctx)
          end

          if item_hl.c then
            item_hl.c_idx = part_idx
            part_idx = part_idx + 3
          elseif item_hl.sl_idx then -- sep_left hl was added
            -- separator's highlight should not bleed into content
            part_idx = core.add_highlight(reset_hl_name, nil, parts, part_idx)
          end
        end

        if item_hl.c then
          ctx_hl.bg, ctx_hl.fg = item_hl.c.bg or ctx_hl.bg, item_hl.c.fg or ctx_hl.fg
        else
          ctx_hl.bg, ctx_hl.fg = reset_hl_bg, reset_hl_fg
        end

        local nested_items_idx, nested_items

        if item.content then
          if item.prefix then
            part_idx = part_idx + 1
            parts[part_idx] = resolve_item_affix(item.prefix, item, ctx, breakpoint)

            available_width = available_width - vim.api.nvim_strwidth(parts[part_idx])
          end

          local content = item.content
          local content_type = type(content)
          if content_type == "function" then
            parts.len = part_idx

            ctx.parts = parts

            content = item:content(ctx) or ""
            content_type = type(content)
          end

          if (content_type == "table" and content.len or #content) > 0 then
            o_eval_stl_opts.winid = ctx.winid

            if content_type == "table" then
              if type(content[1]) == "string" then
                ---@cast content string[]
                for idx = 1, (content.len or #content) do
                  local c = vim.api.nvim_eval_statusline(content[idx], o_eval_stl_opts)

                  part_idx = part_idx + 1
                  parts[part_idx] = content[idx]

                  available_width = available_width - c.width
                end
              else
                if not content.next then
                  u.initialize_priority_item_list(content)
                end

                part_idx = part_idx + 1

                nested_items_idx = part_idx
                nested_items = content
              end
            else
              if item.priority == -math.huge then
                part_idx = part_idx + 1
                parts[part_idx] = content
              else
                local c = vim.api.nvim_eval_statusline(content, o_eval_stl_opts)

                part_idx = part_idx + 1
                parts[part_idx] = content

                available_width = available_width - c.width
              end
            end

            if item.suffix then
              part_idx = part_idx + 1
              parts[part_idx] = resolve_item_affix(item.suffix, item, ctx, breakpoint)

              available_width = available_width - vim.api.nvim_strwidth(parts[part_idx])
            end
          else -- no content returned
            if part_idx == parts.len then -- no parts added
              if item.prefix then
                -- discard prefix
                part_idx = part_idx - 1
                parts.len = part_idx
              end
            else
              part_idx = parts.len
            end
          end
        end

        if item.sep_right then
          local sep = item.sep_right[breakpoint]

          if sep.content then
            item_hl.sr = resolve_item_hl(sep.hl, item, ctx)

            if item_hl.sr then
              item_hl.sr_idx = part_idx
              part_idx = part_idx + 3
            end

            part_idx = part_idx + 1
            parts[part_idx] = sep.content

            available_width = available_width - vim.api.nvim_strwidth(sep.content)
          else
            part_idx = part_idx + 1
            parts[part_idx] = ""
          end
        end

        if nested_items_idx then
          local nested_slots = parts[nested_items_idx]
          if not nested_slots or nested_slots.id ~= item.id then
            nested_slots = { id = item.id }
            parts[nested_items_idx] = nested_slots
          end

          nested_slots.len = nested_items.len
          ctx.available_width = available_width
          ctx.slots = nested_slots

          ---@cast nested_items NougatItem[]
          Bar.__prepare_slots(nested_items, ctx)

          if ctx.available_width == available_width then
            should_skip_slot = true
          else
            available_width = ctx.available_width
          end

          ctx.slots = slots
          ctx.available_width = available_width
        end

        if item_hl.c or item_hl.sl or item_hl.sr then
          part_idx = core.add_highlight(reset_hl_name, nil, parts, part_idx)
        end

        if item.hl == false then
          item_hl.x = true
        end
      end
    end

    if should_skip_slot then
      part_idx = 0
      available_width = slot_initial_available_width
    elseif available_width < 0 then
      if items._overflow == "hide-all" then
        for i = 1, #slots do
          slots[i].len = 0
        end
        ctx.available_width = initial_available_width
        break
      else
        -- hide-self
        part_idx = 0
        available_width = slot_initial_available_width
      end
    end

    parts.len = part_idx
    ctx.available_width = available_width

    item, item_idx = items:next()
  end
end

local function prepare_parts_from_slots(slots, parts, parts_len, hls, hls_len, item_hl)
  for i = 1, slots.len do
    local slot = slots[i]

    if type(slot) == "table" then
      if slot.len > 0 then
        local c_len, hl = parts_len, slot.hl
        if hl and not hl.x then
          hls_len = hls_len + 1

          local item_hls_len = hls_len

          if hl.sl_idx then
            hl.sl_idx = hl.sl_idx + parts_len
          end

          if hl.c_idx then
            hl.c_idx = hl.c_idx + parts_len
          end

          if hl.sr_idx then
            hl.sr_idx = hl.sr_idx + parts_len
          end

          parts_len, hls_len = prepare_parts_from_slots(slot, parts, parts_len, hls, hls_len, hl)

          if item_hls_len ~= hls_len then
            local total_child_hls = hls_len - item_hls_len
            hl.fc_idx = total_child_hls == 1 and hls_len or hls_len - total_child_hls + 1
            hl.lc_idx = hls_len
          end

          hls[item_hls_len] = hl
        else
          parts_len, hls_len = prepare_parts_from_slots(slot, parts, parts_len, hls, hls_len)
        end

        c_len = parts_len - c_len

        if item_hl and item_hl.sr_idx then
          item_hl.sr_idx = item_hl.sr_idx + c_len - 1
        end
      end
    else
      parts_len = parts_len + 1
      parts[parts_len] = slot or ""
    end
  end

  return parts_len, hls_len
end

local function prepare_priority_parts(items, ctx)
  local parts = ctx.parts
  Bar.__prepare_slots(items, ctx)
  parts.len, ctx.hls.len = prepare_parts_from_slots(ctx.slots, parts, 0, ctx.hls, 0)
  ctx.parts = parts
end

---@param ctx nougat_bar_ctx
function Bar:generate(ctx)
  ctx.breakpoint = self._get_breakpoint_index(ctx.width, self._breakpoints)
  ---@deprecated
  ctx.ctx.breakpoint = ctx.breakpoint

  local hl, bar_hl = self._hl, resolve_bar_hl(self, ctx)
  hl.bg, hl.fg = bar_hl.bg, bar_hl.fg
  ctx.hl = hl

  local o_hls, o_parts = self._hls, self._parts
  o_hls.len, o_parts.len = 0, 0
  ctx.hls, ctx.parts = o_hls, o_parts

  if self._slots then
    local o_slots = self._slots
    o_slots.len = self._items.len
    ctx.slots = o_slots

    ctx.available_width = ctx.width

    prepare_priority_parts(self._items, ctx)
  else
    Bar.__prepare_parts(self._items, ctx)
  end

  prepare_highlights(ctx, bar_hl)

  return table.concat(o_parts, nil, 1, o_parts.len)
end

---@alias NougatBar.constructor fun(type: nougat_bar_type, config?: nougat_bar_config): NougatBar
---@type NougatBar|NougatBar.constructor
local NougatBar = Bar

return NougatBar
