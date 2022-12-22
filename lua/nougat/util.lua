local core = require("nui.bar.core")
local separator = require("nougat.separator")

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

---@alias nougat_hl_def { bg?: string, fg?: string, bold?: boolean, italic?: boolean }

---@type table<string, nougat_hl_def>
local get_hl_cache = {}

---@param name string
---@return nougat_hl_def
function mod.get_hl(name)
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

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("nougat.util.get_hl", { clear = true }),
  callback = function()
    local names = vim.tbl_keys(get_hl_cache)
    for idx = 1, #names do
      get_hl_cache[names[idx]] = nil
    end
  end,
  desc = "[nougat] util.get_hl cache cleanup",
})

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
    hl.bg:gsub("^#", "", 1),
    hl.fg:gsub("^#", "", 1),
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
function mod.set_hl(hl, fallback_hl)
  o_hl_def.bg, o_hl_def.fg, o_hl_def.bold, o_hl_def.italic = hl.bg, hl.fg, hl.bold, hl.italic

  if not o_hl_def.bg or needs_fallback[o_hl_def.bg] then
    o_hl_def.bg = fallback_hl[o_hl_def.bg or "bg"]
  end

  if not o_hl_def.fg or needs_fallback[o_hl_def.fg] then
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
local o_transitional_hl = {}

---@param hl nougat_hl_def
---@param prev_hl nougat_hl_def
---@param curr_hl nougat_hl_def
---@param next_hl nougat_hl_def
---@return nougat_hl_def transitional_hl
function mod.prepare_transitional_hl(hl, prev_hl, curr_hl, next_hl)
  o_transitional_hl.bg, o_transitional_hl.fg = hl.bg, hl.fg or curr_hl and curr_hl.bg or "bg"

  if o_transitional_hl.bg == -1 then
    o_transitional_hl.bg = prev_hl and prev_hl.bg or nil
  elseif o_transitional_hl.bg == 1 then
    o_transitional_hl.bg = next_hl and next_hl.bg or nil
  end

  if o_transitional_hl.fg == -1 then
    o_transitional_hl.fg = prev_hl and prev_hl.fg or nil
  elseif o_transitional_hl.fg == 1 then
    o_transitional_hl.fg = next_hl and next_hl.fg or nil
  end

  return o_transitional_hl
end

---@param side -1|1
---@param sep nougat_separator|nil
---@return nougat_separator[]|nil
function mod.normalize_sep(side, sep)
  if not sep then
    return sep
  end

  if sep.content then
    sep = { sep }
  end

  for i = 1, #sep do
    sep[i] = separator.adjust_hl(side, sep[i])
  end

  return sep
end

---@param items NougatItem[]|{ len?: integer }
---@param ctx nui_bar_core_expression_context
---@param fallback_hl nougat_hl_def
---@return string[]
function mod.prepare_parts(items, ctx, fallback_hl)
  local breakpoint = ctx.ctx.breakpoint

  local part_idx = 0
  ---@type string[]
  local parts = {}

  local item_hl_idx = 0
  local item_hls = {}

  for item_idx = 1, (items.len or #items) do
    local item = items[item_idx]

    if item.refresh then
      item:refresh(ctx)
    end

    local hidden = item.hidden and (item.hidden == true or item:hidden(ctx))

    if not hidden then
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
          item_hl.c = mod.get_hl(hl_c)
        elseif type(hl_c) == "number" then
          item_hl.c = mod.get_hl("User" .. hl_c)
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

          if type(content) == "table" then
            for idx = 1, (content.len or #content) do
              part_idx = part_idx + 1
              parts[part_idx] = content[idx]
            end
          else
            part_idx = part_idx + 1
            parts[part_idx] = content
          end

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
      parts[hl.sl_idx] = core.highlight(
        mod.set_hl(mod.prepare_transitional_hl(hl.sl, prev_hl_c, hl.c, next_hl_c), fallback_hl)
      )
    end

    if hl.c then
      parts[hl.c_idx] = core.highlight(mod.set_hl(hl.c, fallback_hl))
    end

    if hl.sr then
      parts[hl.sr_idx] = core.highlight(
        mod.set_hl(mod.prepare_transitional_hl(hl.sr, prev_hl_c, hl.c, next_hl_c), fallback_hl)
      )
    end
  end

  return parts
end

return mod
