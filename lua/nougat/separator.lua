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

local hl_transition_by_char = {
  [char.left_chevron_solid] = { bg = -1 },
  [char.right_chevron_solid] = { bg = 1 },
  [char.left_lower_triangle_solid] = { bg = -1 },
  [char.left_upper_triangle_solid] = { bg = -1 },
  [char.right_lower_triangle_solid] = { bg = 1 },
  [char.right_upper_triangle_solid] = { bg = 1 },
  [char.left_half_circle_solid] = { bg = -1 },
  [char.right_half_circle_solid] = { bg = 1 },
}

---@alias nougat_separator_hl_def { bg?: string|-1|1, fg?: string|-1|1 }
---@alias nougat_separator { content: string, hl?: nougat_separator_hl_def }

---@param separator nougat_separator
---@param use_transition? boolean
---@return nougat_separator
local function with_hl(separator, use_transition)
  if use_transition then
    local hl = hl_transition_by_char[separator.content]
    separator.hl = hl and { bg = hl.bg, fg = hl.fg } or {}
  else
    separator.hl = {}
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
---@return nougat_separator
function mod.space()
  return {
    content = char.space,
  }
end

-- '`│`'
---@return nougat_separator
function mod.vertical()
  return {
    content = char.vertical,
  }
end

-- '`┃`'
---@return nougat_separator
function mod.heavy_veritcal()
  return {
    content = char.heavy_veritcal,
  }
end

-- '`║`'
---@return nougat_separator
function mod.double_vertical()
  return {
    content = char.double_vertical,
  }
end

-- '`█`'
---@return nougat_separator
function mod.full_block()
  return {
    content = char.full_block,
  }
end

-- '``'
---@return nougat_separator
function mod.left_chevron()
  return {
    content = char.left_chevron,
  }
end

-- '``'
---@param use_hl_transition? boolean
---@return nougat_separator
function mod.left_chevron_solid(use_hl_transition)
  return with_hl({
    content = char.left_chevron_solid,
  }, use_hl_transition)
end

-- '``'
---@return nougat_separator
function mod.right_chevron()
  return {
    content = char.right_chevron,
  }
end

-- '``'
---@param use_hl_transition? boolean
---@return nougat_separator
function mod.right_chevron_solid(use_hl_transition)
  return with_hl({
    content = char.right_chevron_solid,
  }, use_hl_transition)
end

-- '``'
---@return nougat_separator
function mod.falling_diagonal()
  return {
    content = char.falling_diagonal,
  }
end

-- '``'
---@return nougat_separator
function mod.rising_diagonal()
  return {
    content = char.rising_diagonal,
  }
end

-- '``'
---@param use_hl_transition? boolean
---@return nougat_separator
function mod.left_lower_triangle_solid(use_hl_transition)
  return with_hl({
    content = char.left_lower_triangle_solid,
  }, use_hl_transition)
end

-- '``'
---@param use_hl_transition? boolean
---@return nougat_separator
function mod.left_upper_triangle_solid(use_hl_transition)
  return with_hl({
    content = char.left_upper_triangle_solid,
  }, use_hl_transition)
end

-- '``'
---@param use_hl_transition? boolean
---@return nougat_separator
function mod.right_lower_triangle_solid(use_hl_transition)
  return with_hl({
    content = char.right_lower_triangle_solid,
  }, use_hl_transition)
end

-- '``'
---@param use_hl_transition? boolean
---@return nougat_separator
function mod.right_upper_triangle_solid(use_hl_transition)
  return with_hl({
    content = char.right_upper_triangle_solid,
  }, use_hl_transition)
end

-- '``'
---@return nougat_separator
function mod.left_half_circle()
  return {
    content = char.left_half_circle,
  }
end

-- '``'
---@param use_hl_transition? boolean
---@return nougat_separator
function mod.left_half_circle_solid(use_hl_transition)
  return with_hl({
    content = char.left_half_circle_solid,
  }, use_hl_transition)
end

-- '``'
---@return nougat_separator
function mod.right_half_circle()
  return {
    content = char.right_half_circle,
  }
end

-- '``'
---@param use_hl_transition? boolean
---@return nougat_separator
function mod.right_half_circle_solid(use_hl_transition)
  return with_hl({
    content = char.right_half_circle_solid,
  }, use_hl_transition)
end

return mod
