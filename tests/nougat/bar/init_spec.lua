pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("NougatBar", function()
  it("can be initialized", function()
    local bar = Bar("statusline")
    t.type(bar.id, "number")
    t.eq(bar.type, "statusline")
  end)
end)
