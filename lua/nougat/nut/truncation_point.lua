local core = require("nougat.core")
local Item = require("nougat.item")

local mod = {}

function mod.create()
  return Item({
    hl = false,
    priority = false,
    content = core.truncation_point(),
  })
end

return mod
