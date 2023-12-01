pcall(require, "luacov")

local Bar = require("nougat.bar")
local Item = require("nougat.item")
local nut = {
  mode = require("nougat.nut.mode"),
  buf = {
    filename = require("nougat.nut.buf.filename"),
  },
}

local t = require("tests.util")

describe("NougatBar", function()
  it("can be initialized", function()
    local bar = Bar("statusline")
    t.type(bar.id, "number")
    t.eq(bar.type, "statusline")
  end)

  describe(":generate basic", function()
    local bar, ctx

    before_each(function()
      bar = Bar("statusline")
      ctx = t.make_ctx(0, {
        ctx = {},
        width = vim.api.nvim_win_get_width(0),
      })
    end)

    it("strings", function()
      bar:add_item("A")
      bar:add_item("B")
      bar:add_item("C")

      t.eq(bar:generate(ctx), "ABC")
    end)

    it("items", function()
      bar:add_item(nut.mode.create())
      bar:add_item(nut.buf.filename.create({}))

      t.eq(bar:generate(ctx), "%#nougat_hl_bg_663399_fg_ffcd00_#NORMAL%#nougat_hl_bg_ffcd00_fg_663399_#[No Name]")
    end)
  end)
end)
