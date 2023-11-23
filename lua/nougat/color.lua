local get_hl_def = require("nougat.util.hl").get_hl_def

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

---@class nougat.color
local color = { accent = {} }

local mod = {
  colorscheme = nil,
}

function mod.get()
  local colorscheme = vim.g.colors_name
  if not colorscheme or #colorscheme == 0 then
    colorscheme = "auto"
  end

  if mod.colorscheme == colorscheme then
    return color
  end

  if mod.colorscheme ~= colorscheme then
    local ok, cs = pcall(require, "nougat.color." .. colorscheme)

    color = ok and cs.get() or { accent = {} }
  end

  if not color.accent then
    color.accent = {}
  end

  color.red = color.red or vim.g.terminal_color_9 or "red"
  color.green = color.green or vim.g.terminal_color_10 or "green"
  color.yellow = color.yellow or vim.g.terminal_color_11 or "yellow"
  color.blue = color.blue or vim.g.terminal_color_12 or "blue"
  color.magenta = color.magenta or vim.g.terminal_color_13 or "magenta"
  color.cyan = color.cyan or vim.g.terminal_color_14 or "cyan"

  local accent = color.accent
  if not accent then
    accent = {}
    color.accent = accent
  end

  accent.red = accent.red or vim.g.terminal_color_1 or "darkred"
  accent.green = accent.green or vim.g.terminal_color_2 or "darkgreen"
  accent.yellow = accent.yellow or vim.g.terminal_color_3 or "darkyellow"
  accent.blue = accent.blue or vim.g.terminal_color_4 or "darkblue"
  accent.magenta = accent.magenta or vim.g.terminal_color_5 or "darkmagenta"
  accent.cyan = accent.cyan or vim.g.terminal_color_6 or "darkcyan"

  if vim.fn.hlexists("Normal") == 1 then
    local normal = get_hl_def("Normal")
    color.bg = color.bg or normal.bg
    color.fg = color.fg or normal.fg
  end

  if vim.go.background == "dark" then
    color.bg = color.bg or vim.g.terminal_color_0 or "#000000"
    accent.bg = accent.bg or vim.g.terminal_color_8 or "darkgray"
    color.fg = color.fg or vim.g.terminal_color_15 or "#ffffff"
    accent.fg = accent.fg or vim.g.terminal_color_7 or "lightgray"
  else
    color.bg = color.bg or vim.g.terminal_color_15 or "#ffffff"
    accent.bg = accent.bg or vim.g.terminal_color_7 or "lightgray"
    color.fg = color.fg or vim.g.terminal_color_0 or "#000000"
    accent.fg = accent.fg or vim.g.terminal_color_8 or "darkgray"
  end

  local shades = generate_shades(color.bg, color.fg, 10)
  color.bg0 = color.bg0 or shades[1]
  color.bg1 = color.bg1 or shades[2]
  color.bg2 = color.bg2 or shades[3]
  color.bg3 = color.bg3 or shades[4]
  color.bg4 = color.bg4 or shades[5]
  color.fg4 = color.fg4 or shades[6]
  color.fg3 = color.fg3 or shades[7]
  color.fg2 = color.fg2 or shades[8]
  color.fg1 = color.fg1 or shades[9]
  color.fg0 = color.fg0 or shades[10]

  return color
end

return mod
