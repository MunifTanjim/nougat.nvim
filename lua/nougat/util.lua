local core = require("nougat.core")

local mod = {}

mod.code = {
  buf_file_path = "f",
  buf_file_path_full = "F",
  buf_file_name = "t",
  buf_modified_flag = "m",
  buf_modified_flag_alt = "M",
  buf_readonly_flag = "r",
  buf_readonly_flag_alt = "R",
  buf_type_help_flag = "h",
  buf_type_help_flag_alt = "H",
  win_type_preview_flag = "w",
  win_type_preview_flag_alt = "W",
  buf_filetype_flag = "y",
  buf_filetype_flag_alt = "Y",
  buf_type_quickfix = "q",
  buf_keymap_name = "k",
  buf_number = "n",
  buf_cursor_char = "b",
  buf_cursor_char_hex = "B",
  buf_cursor_byte = "o",
  buf_cursor_byte_hex = "O",
  printer_page_number = "N",
  buf_line_current = "l",
  buf_line_total = "L",
  buf_col_current_byte = "c",
  buf_col_current = "v",
  buf_col_current_alt = "V",
  buf_line_percentage = "p",
  buf_line_percentage_alt = "P",
  argument_list_status = "a",
}

---@return (fun():integer) next_id
function mod.create_id_generator()
  local id = 0
  return function()
    id = id + 1
    return id
  end
end

local augroup = vim.api.nvim_create_augroup("nougat.on_event", { clear = true })

---@type table<string, (fun(info:table):nil)[]>
local autocmd_cb_store = {}

---@param event string|string[]
---@param callback (fun(info:table):nil)
local function on_event(event, callback)
  if type(event) == "string" then
    event = { event }
  end

  for _, ev in ipairs(event) do
    local event_name = ev
    local pattern

    if string.sub(ev, 1, 5) == "User " then
      event_name = "User"
      pattern = string.sub(ev, 6)
    end

    if not autocmd_cb_store[ev] then
      autocmd_cb_store[ev] = {}

      vim.api.nvim_create_autocmd(event_name, {
        group = augroup,
        pattern = pattern,
        callback = function(info)
          local cbs = info.event == "User" and autocmd_cb_store["User " .. info.match] or autocmd_cb_store[info.event]

          for _, cb in ipairs(cbs) do
            cb(info)
          end
        end,
        desc = "[nougat] util.on_event - " .. ev,
      })
    end

    autocmd_cb_store[ev][#autocmd_cb_store[ev] + 1] = callback
  end
end

mod.on_event = on_event

---@alias nougat_hl_def { bg?: string, fg?: string, bold?: boolean, italic?: boolean }

---@type table<string, nougat_hl_def>
local get_hl_cache = {}

---@param name string
---@return nougat_hl_def
local function get_hl(name)
  if get_hl_cache[name] then
    return get_hl_cache[name]
  end

  local def = vim.api.nvim_get_hl_by_name(name, true)

  if def.background then
    def.bg = string.format("#%06x", def.background)
    def.background = nil
  end

  if def.foreground then
    def.fg = string.format("#%06x", def.foreground)
    def.foreground = nil
  end

  if def.reverse then
    def.bg, def.fg = def.fg, def.bg
    def.reverse = nil
  end

  get_hl_cache[name] = def

  return def
end

on_event("ColorScheme", function()
  local names = vim.tbl_keys(get_hl_cache)
  for idx = 1, #names do
    get_hl_cache[names[idx]] = nil
  end
end)

local nougat_hl_name_format = "nougat_hl_bg_%s_fg_%s_%s"
local attr_bold_italic = "b.i"
local attr_bold = "b"
local attr_italic = "i"
local attr_none = ""

-- format: `nougat_hl_bg_<bg>_fg_<fg>_<attr...>`
---@param hl nougat_hl_def
---@return string
local function make_nougat_hl_name(hl)
  return string.format(
    nougat_hl_name_format,
    (hl.bg or ""):gsub("^#", "", 1),
    (hl.fg or ""):gsub("^#", "", 1),
    (hl.bold and hl.italic) and attr_bold_italic or hl.bold and attr_bold or hl.italic and attr_italic or attr_none
  )
end

local set_hl_cache = {}
local needs_fallback = { bg = true, fg = true }

-- re-used table
---@type nougat_hl_def
local o_hl_def = {}

---@param hl nougat_hl_def
---@param fallback_hl nougat_hl_def
---@return string hl_name
local function set_hl(hl, fallback_hl)
  o_hl_def.bg, o_hl_def.fg, o_hl_def.bold, o_hl_def.italic =
    hl.bg or fallback_hl.bg, hl.fg or fallback_hl.fg, hl.bold, hl.italic

  if needs_fallback[o_hl_def.bg] then
    o_hl_def.bg = fallback_hl[o_hl_def.bg or "bg"]
  end

  if needs_fallback[o_hl_def.fg] then
    o_hl_def.fg = fallback_hl[o_hl_def.fg or "fg"]
  end

  local hl_name = make_nougat_hl_name(o_hl_def)

  if not set_hl_cache[hl_name] then
    vim.api.nvim_set_hl(0, hl_name, o_hl_def)
    set_hl_cache[hl_name] = true
  end

  return hl_name
end

-- re-used table
---@type nougat_hl_def
local o_sep_hl = {}

---@param hl nougat_hl_def|nougat_separator_hl_def
---@param far_hl? nougat_hl_def
---@param near_hl? nougat_hl_def
---@param curr_hl? nougat_hl_def
---@param next_hl? nougat_hl_def
---@return nougat_hl_def sep_hl
local function prepare_sep_left_hl(hl, far_hl, near_hl, curr_hl, next_hl)
  o_sep_hl.bg = hl.bg or curr_hl and curr_hl.bg or "bg"
  o_sep_hl.fg = hl.fg or curr_hl and curr_hl.bg or next_hl and next_hl.bg or "bg"

  if o_sep_hl.bg == -1 then
    o_sep_hl.bg = near_hl and near_hl.bg or far_hl and far_hl.bg or nil
  elseif o_sep_hl.fg == -1 then
    o_sep_hl.fg = near_hl and near_hl.bg or far_hl and far_hl.bg or nil
  end

  return o_sep_hl
end

---@param hl nougat_hl_def|nougat_separator_hl_def
---@param prev_hl? nougat_hl_def
---@param curr_hl? nougat_hl_def
---@param near_hl? nougat_hl_def
---@param far_hl? nougat_hl_def
---@return nougat_hl_def sep_hl
local function prepare_sep_right_hl(hl, prev_hl, curr_hl, near_hl, far_hl)
  o_sep_hl.bg = hl.bg or curr_hl and curr_hl.bg or "bg"
  o_sep_hl.fg = hl.fg or prev_hl and prev_hl.bg or curr_hl and curr_hl.bg or "bg"

  if o_sep_hl.bg == 1 then
    o_sep_hl.bg = near_hl and near_hl.bg or far_hl and far_hl.bg or nil
  elseif o_sep_hl.fg == 1 then
    o_sep_hl.fg = near_hl and near_hl.bg or far_hl and far_hl.bg or nil
  end

  return o_sep_hl
end

---@class nougat_lazy_item_hl
---@field c? false|nougat_hl_def content (`false` means `content` w/o hl)
---@field c_idx? integer content index
---@field sl? false|nougat_separator_hl_def sep left (`false` means `sep_left` w/o hl)
---@field sl_idx? integer sep left index
---@field sr? false|nougat_separator_hl_def sep right (`false` means `sep_right` w/o hl)
---@field sr_idx? integer sep right index
---@field r? nougat_hl_def reset
---@field r_idx? integer reset index
---@field fc_idx? integer first child index
---@field lc_idx? integer last child index
---@field fb? nougat_hl_def fallback

---@param hls nougat_lazy_item_hl[]
---@param hl_idx integer
---@return nougat_lazy_item_hl
local function get_item_hl_table(hls, hl_idx)
  ---@type nougat_lazy_item_hl
  local item_hl = hls[hl_idx]
  if item_hl then
    item_hl.c = nil
    item_hl.c_idx = nil
    item_hl.sl = nil
    item_hl.sl_idx = nil
    item_hl.sr = nil
    item_hl.sr_idx = nil
    item_hl.r = nil
    item_hl.r_idx = nil
    item_hl.fc_idx = nil
    item_hl.lc_idx = nil
    item_hl.fb = nil
    return item_hl
  end

  item_hl = {
    c = nil,
    c_idx = nil,
    sl = nil,
    sl_idx = nil,
    sr = nil,
    sr_idx = nil,
    r = nil,
    r_idx = nil,
    fc_idx = nil,
    lc_idx = nil,
    fb = nil,
  }
  hls[hl_idx] = item_hl
  return item_hl
end

---@param hl? nougat_item_hl
---@param item NougatItem
---@param ctx nougat_ctx
local function resolve_highlight(hl, item, ctx)
  local highlight = hl

  if type(highlight) == "function" then
    highlight = highlight(item, ctx)
  end

  if not highlight or type(highlight) == "table" then
    return highlight or false
  end

  if type(highlight) == "string" then
    return get_hl(highlight)
  end

  if type(highlight) == "number" then
    return get_hl("User" .. highlight)
  end

  return false
end

---@param affix nougat_item_affix
---@param item NougatItem
---@param ctx nougat_ctx
---@param breakpoint integer
local function resolve_affix(affix, item, ctx, breakpoint)
  if type(affix) == "function" then
    return affix(item, ctx) or ""
  end

  return affix[breakpoint]
end

---@param items NougatItem[]|{ len?: integer }
---@param ctx nougat_ctx
---@param item_fallback_hl? nougat_hl_def
local function prepare_parts(items, ctx, item_fallback_hl)
  local breakpoint = ctx.ctx.breakpoint

  local hls, parts = ctx.hls, ctx.parts
  local hl_idx, part_idx

  for item_idx = 1, (items.len or #items) do
    local item = items[item_idx]

    hl_idx, part_idx = hls.len, parts.len

    if item.prepare then
      item:prepare(ctx)
    end

    local hidden = item.hidden and (item.hidden == true or item:hidden(ctx))

    if not hidden then
      hl_idx = hl_idx + 1

      local item_hl = get_item_hl_table(hls, hl_idx)
      item_hl.fb = item_fallback_hl

      if item.sep_left then
        local sep = item.sep_left[breakpoint]

        if sep.content then
          item_hl.sl = resolve_highlight(sep.hl, item, ctx)

          if item_hl.sl then
            item_hl.sl_idx = part_idx
            part_idx = part_idx + 3
          elseif item.hl then
            item_hl.c = resolve_highlight(item.hl, item, ctx)

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
          item_hl.c = resolve_highlight(item.hl, item, ctx)
        end

        if item_hl.c then
          item_hl.c_idx = part_idx
          part_idx = part_idx + 3
        elseif item_hl.sl_idx then -- sep_left hl was added
          -- separator's highlight should not bleed into content
          part_idx = core.add_highlight(0, nil, parts, part_idx)
        end
      end

      if item.content then
        if item.prefix then
          part_idx = part_idx + 1
          parts[part_idx] = resolve_affix(item.prefix, item, ctx, breakpoint)
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

              ---@cast content NougatItem[]
              prepare_parts(content, ctx, item_hl.c)

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
            parts[part_idx] = resolve_affix(item.suffix, item, ctx, breakpoint)
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
          item_hl.sr = resolve_highlight(sep.hl, item, ctx)

          if item_hl.sr then
            item_hl.sr_idx = part_idx
            part_idx = part_idx + 3
          end

          part_idx = part_idx + 1
          parts[part_idx] = sep.content
        end
      end

      if item_hl.c or item_hl.sl or item_hl.sr then
        if item_fallback_hl then
          item_hl.r = item_fallback_hl
          item_hl.r_idx = part_idx
          part_idx = part_idx + 3
        else
          part_idx = core.add_highlight(0, nil, parts, part_idx)
        end
      end

      if item.hl == false then
        hl_idx = hl_idx - 1
      end
    end

    hls.len = hl_idx
    parts.len = part_idx
  end
end

---@param ctx nougat_ctx
---@param fallback_hl nougat_hl_def
function mod.process_bar_highlights(ctx, fallback_hl)
  local hls = ctx.hls
  local hl_idx = hls.len

  local parts = ctx.parts

  for idx = 1, hl_idx do
    local hl = hls[idx]

    if hl.sl then
      -- for parent:
      -- - last child of prev sibling
      -- - or prev sibling
      -- for first child:
      -- - parent
      -- for children:
      -- - prev sibling
      local near_prev_hl = idx > 1 and hls[idx - 1] or nil
      -- for first child:
      -- - prev sibling of parent
      local far_prev_hl_c = ((near_prev_hl and idx == near_prev_hl.fc_idx) and idx > 2) and hls[idx - 2].c or nil
      -- for parent
      -- - first child
      local near_next_hl_c = hl.fc_idx and hls[hl.fc_idx].c or nil

      core.add_highlight(
        set_hl(
          prepare_sep_left_hl(hl.sl, far_prev_hl_c, near_prev_hl and near_prev_hl.c or nil, hl.c, near_next_hl_c),
          hl.fb or fallback_hl
        ),
        nil,
        parts,
        hl.sl_idx
      )
    end

    if hl.c then
      core.add_highlight(set_hl(hl.c, hl.fb or fallback_hl), nil, parts, hl.c_idx)
    end

    if hl.sr then
      -- for parent:
      -- - last child
      local prev_hl_c = hl.lc_idx and hls[hl.lc_idx].c or nil
      -- for parent:
      -- - next sibling
      -- for children:
      -- - next sibling
      -- for last child:
      -- - next sibling of parent
      local near_next_hl = hl.lc_idx and (hl.lc_idx + 1 <= hl_idx and hls[hl.lc_idx + 1])
        or idx + 1 <= hl_idx and hls[idx + 1]
        or nil
      -- for parent:
      -- - first child of next sibling
      -- for last child:
      -- - first child of next sibling of parent
      local far_next_hl_c = (near_next_hl and near_next_hl.fc_idx) and hls[near_next_hl.fc_idx].c or nil

      core.add_highlight(
        set_hl(
          prepare_sep_right_hl(hl.sr, prev_hl_c, hl.c, near_next_hl and near_next_hl.c or nil, far_next_hl_c),
          hl.fb or fallback_hl
        ),
        nil,
        parts,
        hl.sr_idx
      )
    end

    if hl.r then
      core.add_highlight(set_hl(hl.r, fallback_hl), nil, parts, hl.r_idx)
    end
  end
end

mod.get_hl = get_hl
mod.set_hl = set_hl

mod.prepare_parts = prepare_parts

return mod
