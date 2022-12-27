local core = require("nui.bar.core")

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
function mod.set_hl(hl, fallback_hl)
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
local o_transitional_hl = {}

---@param hl nougat_hl_def|nougat_separator_hl_def
---@param prev_hl? nougat_hl_def
---@param curr_hl nougat_hl_def
---@param next_hl? nougat_hl_def
---@return nougat_hl_def transitional_hl
function mod.prepare_transitional_hl(hl, prev_hl, curr_hl, next_hl)
  ---@diagnostic disable-next-line: assign-type-mismatch
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

---@class nougat_lazy_item_hl
---@field c? nougat_hl_def content
---@field c_idx? integer content index
---@field sl? nougat_separator_hl_def sep left
---@field sl_idx? integer sep left index
---@field sr? nougat_separator_hl_def sep right
---@field sr_idx? integer sep right index
---@field r? nougat_hl_def reset
---@field r_idx? integer reset index
---@field pio? integer prev index offset
---@field nio? integer next index offset
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
    item_hl.pio = -1
    item_hl.nio = 1
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
    pio = -1,
    nio = 1,
    fb = nil,
  }
  hls[hl_idx] = item_hl
  return item_hl
end

---@param items NougatItem[]|{ len?: integer }
---@param ctx nougat_ctx
---@param item_fallback_hl? nougat_hl_def
function mod.prepare_parts(items, ctx, item_fallback_hl)
  local breakpoint = ctx.ctx.breakpoint

  local hls, parts = ctx.hls, ctx.parts
  local hl_idx, part_idx

  for item_idx = 1, (items.len or #items) do
    local item = items[item_idx]

    hl_idx, part_idx = hls.len, parts.len

    if item.refresh then
      item:refresh(ctx)
    end

    local hidden = item.hidden and (item.hidden == true or item:hidden(ctx))

    if not hidden then
      hl_idx = hl_idx + 1

      local item_hl = get_item_hl_table(hls, hl_idx)
      item_hl.fb = item_fallback_hl

      if item.sep_left then
        local sep = item.sep_left[breakpoint]

        if sep.content then
          if sep.hl then
            item_hl.sl = sep.hl
            item_hl.sl_idx = part_idx
            part_idx = part_idx + 3
          elseif item.hl then
            item_hl.c_idx = part_idx
            part_idx = part_idx + 3
          end

          part_idx = part_idx + 1
          parts[part_idx] = sep.content
        end
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
          item_hl.c_idx = part_idx
          part_idx = part_idx + 3
        end
      elseif item_hl.sl then
        part_idx = core.add_highlight(0, nil, parts, part_idx)
      end

      if item.content then
        if item.prefix then
          part_idx = part_idx + 1
          parts[part_idx] = item.prefix[breakpoint]
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
              mod.prepare_parts(content, ctx, item_hl.c)

              if hl_idx ~= hls.len then
                item_hl.nio = item_hl.nio + hls.len - hl_idx
                hl_idx = hls.len
              end
              part_idx = parts.len
            end
          else
            part_idx = part_idx + 1
            parts[part_idx] = content
          end

          if item.suffix then
            part_idx = part_idx + 1
            parts[part_idx] = item.suffix[breakpoint]
          end
        else -- no content returned
          if part_idx == parts.len then -- no parts added
            -- discard prefix
            part_idx = part_idx - 1
            parts.len = part_idx
          else
            part_idx = parts.len
          end
        end
      end

      if item.sep_right then
        local sep = item.sep_right[breakpoint]

        if sep.content then
          if sep.hl then
            item_hl.sr = sep.hl
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
    local prev_hl_c = idx + hl.pio > 1 and hls[idx + hl.pio].c or nil
    local next_hl_c = idx + hl.nio <= hl_idx and hls[idx + hl.nio].c or nil

    if hl.sl then
      core.add_highlight(
        mod.set_hl(mod.prepare_transitional_hl(hl.sl, prev_hl_c, hl.c, next_hl_c), hl.fb or fallback_hl),
        nil,
        parts,
        hl.sl_idx
      )
    end

    if hl.c then
      core.add_highlight(mod.set_hl(hl.c, hl.fb or fallback_hl), nil, parts, hl.c_idx)
    end

    if hl.sr then
      core.add_highlight(
        mod.set_hl(mod.prepare_transitional_hl(hl.sr, prev_hl_c, hl.c, next_hl_c), hl.fb or fallback_hl),
        nil,
        parts,
        hl.sr_idx
      )
    end

    if hl.r then
      core.add_highlight(mod.set_hl(hl.r, fallback_hl), nil, parts, hl.r_idx)
    end
  end
end

return mod
