local on_event = require("nougat.util.on_event")

local mod = {}

---@alias nougat_hl_def { bg?: string, fg?: string, bold?: boolean, italic?: boolean }

---@type table<string, nougat_hl_def>
local get_hl_def_cache = {}

-- Get definition for a highlight group name.
--
-- _(Optimized for hot path)_
--
-- _**WARNING**: do not mutate the returned table._
--
---@param hl_name string
---@return nougat_hl_def
function mod.get_hl_def(hl_name)
  if get_hl_def_cache[hl_name] then
    return get_hl_def_cache[hl_name]
  end

  local hl = vim.api.nvim_get_hl_by_name(hl_name, true)

  if hl.background then
    hl.bg = string.format("#%06x", hl.background)
    hl.background = nil
  end

  if hl.foreground then
    hl.fg = string.format("#%06x", hl.foreground)
    hl.foreground = nil
  end

  if hl.reverse then
    hl.bg, hl.fg = hl.fg, hl.bg
    hl.reverse = nil
  end

  get_hl_def_cache[hl_name] = hl

  return hl
end

on_event("ColorScheme", function()
  local names = vim.tbl_keys(get_hl_def_cache)
  for idx = 1, #names do
    get_hl_def_cache[names[idx]] = nil
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

---@type table<string, boolean>
local get_hl_name_cache = {}

local needs_fallback = { bg = true, fg = true }

-- re-used table
---@type nougat_hl_def
local o_hl_def = {}

-- Get highlight group name for a definition.
--
-- For `hl.bg` and `hl.fg`:
-- - if the value is missing, it's taken from `fallback_hl`
-- - if the value is `'bg'` or `'fg'`, it's read from `fallback_hl`
--
-- _(Optimized for hot path)_
--
---@param hl nougat_hl_def
---@param fallback_hl nougat_hl_def
---@return string hl_name
function mod.get_hl_name(hl, fallback_hl)
  o_hl_def.bg, o_hl_def.fg, o_hl_def.bold, o_hl_def.italic =
    hl.bg or fallback_hl.bg, hl.fg or fallback_hl.fg, hl.bold, hl.italic

  if needs_fallback[o_hl_def.bg] then
    o_hl_def.bg = fallback_hl[o_hl_def.bg or "bg"]
  end

  if needs_fallback[o_hl_def.fg] then
    o_hl_def.fg = fallback_hl[o_hl_def.fg or "fg"]
  end

  local hl_name = make_nougat_hl_name(o_hl_def)

  if not get_hl_name_cache[hl_name] then
    vim.api.nvim_set_hl(0, hl_name, o_hl_def)
    get_hl_name_cache[hl_name] = true
  end

  return hl_name
end

return mod
