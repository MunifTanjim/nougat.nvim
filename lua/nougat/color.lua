local on_event = require("nougat.util.on_event")
local register_store = require("nougat.util.store").register
local clear_store = require("nougat.util.store").clear

---@alias nougat_hl_def { bg?: string, fg?: string, bold?: boolean, italic?: boolean }

---@class nougat.color
local color = { accent = {} }
---@type nougat.color
local theme = { accent = {} }

local store = register_store("nougat.color", {
  ---@type table<string, nougat_hl_def>
  get_hl_def = {},
  ---@type table<string, boolean>
  get_hl_name = {},
}, function(store)
  for name in pairs(store.get_hl_def) do
    store.get_hl_def[name] = nil
  end
  for name in pairs(store.get_hl_name) do
    store.get_hl_name[name] = nil
  end
end)

local get_hl_def_cache = store.get_hl_def

-- Get definition for a highlight group name.
--
-- _(Optimized for hot path)_
--
-- _**WARNING**: do not mutate the returned table._
--
---@param hl_name string
---@return nougat_hl_def
local function get_hl_def(hl_name)
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

local nougat_hl_name_format = "bg_%s_fg_%s_%s"
local attr_bold_italic = "b.i"
local attr_bold = "b"
local attr_italic = "i"
local attr_none = ""

-- format: `bg_<bg>_fg_<fg>_<attr...>`
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

local get_hl_name_cache = store.get_hl_name

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
local function get_hl_name(hl, fallback_hl)
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
    o_hl_def.bg = color[o_hl_def.bg] or o_hl_def.bg
    o_hl_def.fg = color[o_hl_def.fg] or o_hl_def.fg
    vim.api.nvim_set_hl(0, hl_name, o_hl_def)
    get_hl_name_cache[hl_name] = true
  end

  return hl_name
end

---@param hex string
---@return integer r
---@return integer g
---@return integer b
local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

---@param r integer
---@param g integer
---@param b integer
---@return string hex
local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

---@param start_hex string
---@param end_hex string
---@param n integer
---@return string[] shades
local function generate_shades(start_hex, end_hex, n)
  local start_rgb, end_rgb = { hex_to_rgb(start_hex) }, { hex_to_rgb(end_hex) }

  local shades = {}
  for i = 0, n - 1 do
    local t = i / (n - 1)
    shades[i + 1] = rgb_to_hex(
      math.floor(start_rgb[1] + t * (end_rgb[1] - start_rgb[1])),
      math.floor(start_rgb[2] + t * (end_rgb[2] - start_rgb[2])),
      math.floor(start_rgb[3] + t * (end_rgb[3] - start_rgb[3]))
    )
  end

  return shades
end

local function merge_color_table(old_tbl, new_tbl)
  for name, value in pairs(new_tbl) do
    if string.sub(name, 1, 1) ~= "." then
      if type(value) == "table" then
        old_tbl[name] = merge_color_table(type(old_tbl[name]) == "table" and old_tbl[name] or {}, value)
      else
        old_tbl[name] = value
      end
    end
  end
  return old_tbl
end

local function prepare_theme_table(thm, clr, prefix)
  for name, value in pairs(clr) do
    if string.sub(name, 1, 1) ~= "." then
      if type(value) == "table" then
        thm[name] = prepare_theme_table(type(thm[name]) == "table" and thm[name] or {}, value, prefix .. "." .. name)
      else
        thm[name] = prefix .. "." .. name
        color[prefix .. "." .. name] = value
      end
    end
  end
  return thm
end

local mod = {
  colorscheme = nil,
  background = vim.go.background,
  get_hl_def = get_hl_def,
  get_hl_name = get_hl_name,
}

local function on_colorscheme()
  clear_store(store)
  if vim.go.background ~= mod.background then
    mod.colorscheme = nil
  end
  mod.get()
end

function mod.get()
  on_event("ColorScheme", on_colorscheme)

  local colorscheme = vim.g.colors_name
  if not colorscheme or #colorscheme == 0 then
    colorscheme = "auto"
  end

  if mod.colorscheme == colorscheme then
    return theme
  end

  mod.colorscheme = colorscheme

  local ok, color_theme = pcall(require, "nougat.color." .. colorscheme)

  ---@class nougat.color
  local c = ok and color_theme.get() or { accent = {} }

  c.red = c.red or vim.g.terminal_color_9 or "red"
  c.green = c.green or vim.g.terminal_color_10 or "green"
  c.yellow = c.yellow or vim.g.terminal_color_11 or "yellow"
  c.blue = c.blue or vim.g.terminal_color_12 or "blue"
  c.magenta = c.magenta or vim.g.terminal_color_13 or "magenta"
  c.cyan = c.cyan or vim.g.terminal_color_14 or "cyan"

  local accent = c.accent
  if not accent then
    accent = {}
    c.accent = accent
  end

  accent.red = accent.red or vim.g.terminal_color_1 or "darkred"
  accent.green = accent.green or vim.g.terminal_color_2 or "darkgreen"
  accent.yellow = accent.yellow or vim.g.terminal_color_3 or "darkyellow"
  accent.blue = accent.blue or vim.g.terminal_color_4 or "darkblue"
  accent.magenta = accent.magenta or vim.g.terminal_color_5 or "darkmagenta"
  accent.cyan = accent.cyan or vim.g.terminal_color_6 or "darkcyan"

  if vim.fn.hlexists("Normal") == 1 then
    local normal = get_hl_def("Normal")
    c.bg = c.bg or normal.bg
    c.fg = c.fg or normal.fg
  end

  if vim.go.background == "dark" then
    c.bg = c.bg or vim.g.terminal_color_0 or "#000000"
    accent.bg = accent.bg or vim.g.terminal_color_8 or "darkgray"
    c.fg = c.fg or vim.g.terminal_color_15 or "#ffffff"
    accent.fg = accent.fg or vim.g.terminal_color_7 or "lightgray"
  else
    c.bg = c.bg or vim.g.terminal_color_15 or "#ffffff"
    accent.bg = accent.bg or vim.g.terminal_color_7 or "lightgray"
    c.fg = c.fg or vim.g.terminal_color_0 or "#000000"
    accent.fg = accent.fg or vim.g.terminal_color_8 or "darkgray"
  end

  local shades = generate_shades(c.bg, c.fg, 10)
  c.bg0 = c.bg0 or shades[1]
  c.bg1 = c.bg1 or shades[2]
  c.bg2 = c.bg2 or shades[3]
  c.bg3 = c.bg3 or shades[4]
  c.bg4 = c.bg4 or shades[5]
  c.fg4 = c.fg4 or shades[6]
  c.fg3 = c.fg3 or shades[7]
  c.fg2 = c.fg2 or shades[8]
  c.fg1 = c.fg1 or shades[9]
  c.fg0 = c.fg0 or shades[10]

  prepare_theme_table(theme, merge_color_table(color, c), "")

  return theme
end

return mod
