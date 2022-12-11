local core = require("nui.bar.core")
local Item = require("nougat.item")

local mod = {}

function mod.create()
  return Item({ content = core.spacer() })
end

return mod
