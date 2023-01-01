local mod = {}

local char = {
  none = nil,

  space = " ",

  vertical = "│",
  heavy_veritcal = "┃",
  double_vertical = "║",

  full_block = "█",

  left_chevron = "",
  left_chevron_solid = "",
  right_chevron = "",
  right_chevron_solid = "",

  falling_diagonal = "",
  rising_diagonal = "",

  left_lower_triangle_solid = "",
  left_upper_triangle_solid = "",
  right_lower_triangle_solid = "",
  right_upper_triangle_solid = "",

  left_half_circle = "",
  left_half_circle_solid = "",
  right_half_circle = "",
  right_half_circle_solid = "",
}

mod.char = char

mod.hl = {
  prev_bg = -1,
  next_bg = 1,
}

local hl_transition_by_char = {
  [char.left_chevron_solid] = { bg = mod.hl.prev_bg },
  [char.right_chevron_solid] = { bg = mod.hl.next_bg },
  [char.left_lower_triangle_solid] = { bg = mod.hl.prev_bg },
  [char.left_upper_triangle_solid] = { bg = mod.hl.prev_bg },
  [char.right_lower_triangle_solid] = { bg = mod.hl.next_bg },
  [char.right_upper_triangle_solid] = { bg = mod.hl.next_bg },
  [char.left_half_circle_solid] = { bg = mod.hl.prev_bg },
  [char.right_half_circle_solid] = { bg = mod.hl.next_bg },
}

--luacheck: push no max line length

---@alias nougat_separator_hl_def { bg?: string|number, fg?: string|number }
---@alias nougat_separator_hl nougat_separator_hl_def|(fun(item: NougatItem, ctx: nougat_ctx):nougat_separator_hl_def)
---@alias nougat_separator { content: string, hl?: nougat_separator_hl }

--luacheck: pop

---@param separator nougat_separator
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
local function with_hl(separator, hl)
  if not hl then
    return separator
  end

  if hl == true then
    local default_hl = hl_transition_by_char[separator.content]
    separator.hl = default_hl and { bg = default_hl.bg, fg = default_hl.fg } or {}
  else
    separator.hl = hl
  end

  return separator
end

local is_left_separator = {
  [char.left_chevron_solid] = true,
  [char.left_chevron] = true,
  [char.left_lower_triangle_solid] = true,
  [char.left_upper_triangle_solid] = true,
  [char.left_half_circle] = true,
  [char.left_half_circle_solid] = true,
}

local is_right_separator = {
  [char.right_chevron_solid] = true,
  [char.right_chevron] = true,
  [char.right_lower_triangle_solid] = true,
  [char.right_upper_triangle_solid] = true,
  [char.right_half_circle] = true,
  [char.right_half_circle_solid] = true,
}

-- Adjusts separator's `.hl`, in case left/right separator was used for right/left side.
--
-- `side` can be:
-- - `-1`: left
-- -  `1`: right
---@param side -1|1
---@param separator? nougat_separator
function mod.adjust_hl(side, separator)
  if not separator or not separator.hl then
    return separator
  end

  if (side == -1 and is_right_separator[separator.content]) or (side == 1 and is_left_separator[separator.content]) then
    separator.hl.bg, separator.hl.fg = separator.hl.fg, separator.hl.bg
  end

  return separator
end

-- ''
---@return nougat_separator
function mod.none()
  return {
    content = char.none,
  }
end

-- '` `'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.space(hl)
  return with_hl({
    content = char.space,
  }, hl)
end

-- '`│`'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.vertical(hl)
  return with_hl({
    content = char.vertical,
  }, hl)
end

-- '`┃`'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.heavy_veritcal(hl)
  return with_hl({
    content = char.heavy_veritcal,
  }, hl)
end

-- '`║`'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.double_vertical(hl)
  return with_hl({
    content = char.double_vertical,
  }, hl)
end

-- '`█`'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.full_block(hl)
  return with_hl({
    content = char.full_block,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.left_chevron(hl)
  return with_hl({
    content = char.left_chevron,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.left_chevron_solid(hl)
  return with_hl({
    content = char.left_chevron_solid,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.right_chevron(hl)
  return with_hl({
    content = char.right_chevron,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.right_chevron_solid(hl)
  return with_hl({
    content = char.right_chevron_solid,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.falling_diagonal(hl)
  return with_hl({
    content = char.falling_diagonal,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.rising_diagonal(hl)
  return with_hl({
    content = char.rising_diagonal,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.left_lower_triangle_solid(hl)
  return with_hl({
    content = char.left_lower_triangle_solid,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.left_upper_triangle_solid(hl)
  return with_hl({
    content = char.left_upper_triangle_solid,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.right_lower_triangle_solid(hl)
  return with_hl({
    content = char.right_lower_triangle_solid,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.right_upper_triangle_solid(hl)
  return with_hl({
    content = char.right_upper_triangle_solid,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.left_half_circle(hl)
  return with_hl({
    content = char.left_half_circle,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.left_half_circle_solid(hl)
  return with_hl({
    content = char.left_half_circle_solid,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.right_half_circle(hl)
  return with_hl({
    content = char.right_half_circle,
  }, hl)
end

-- '``'
---@param hl? nougat_separator_hl|boolean
---@return nougat_separator
function mod.right_half_circle_solid(hl)
  return with_hl({
    content = char.right_half_circle_solid,
  }, hl)
end

return mod
