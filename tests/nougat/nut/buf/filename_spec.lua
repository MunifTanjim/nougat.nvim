pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.buf.filename", function()
  local bar, ctx

  local nut

  before_each(function()
    require("nougat.util.store").clear_all()

    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    nut = require("nougat.nut.buf.filename")
  end)

  it("works", function()
    bar:add_item(nut.create({}))

    vim.cmd("file some/folder/file.md")

    t.eq(bar:generate(ctx), "some/folder/file.md")

    vim.cmd("file some/folder/doc.md")

    t.eq(bar:generate(ctx), "some/folder/doc.md")
  end)
end)
