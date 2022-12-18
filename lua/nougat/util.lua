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

return mod
