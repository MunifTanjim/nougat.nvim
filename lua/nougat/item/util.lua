local separator = require("nougat.separator")

local mod = {}

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

return mod
