local core = require("nui.bar.core")
local Item = require("nougat.item")

local mod = {}

function mod.create()
  return Item({
    hl = false,
    content = core.truncation_point(),
  })
end

return mod
