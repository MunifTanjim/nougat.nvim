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

---@param item NougatItem
---@param breakpoints integer[]
function mod.prepare_config_breakpoints(item, breakpoints)
  for i = 1, #breakpoints do
    local base_config = item._config[i - 1] or item._config
    item._config[i] = vim.tbl_deep_extend("keep", item._config[i] or {}, base_config)
  end
end

---@param item NougatItem
---@param name string
---@param breakpoints integer[]
function mod.prepare_property_breakpoints(item, name, breakpoints)
  local val = item[name]

  if type(val) == "table" then
    for i = 1, #breakpoints do
      if not val[i] then
        val[i] = val[i - 1]
      end
    end
  end
end

return mod
