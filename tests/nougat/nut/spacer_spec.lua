pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.spacer", function()
  local bar, ctx

  local spacer

  before_each(function()
    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    spacer = require("nougat.nut.spacer")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works", function()
    bar:add_item("A")
    bar:add_item(spacer.create())
    bar:add_item("B")

    t.eq(bar:generate(ctx), "A%=B")
    t.eq(
      vim.api.nvim_eval_statusline(bar:generate(ctx), { winid = ctx.winid }).str,
      string.format("A%sB", string.rep(" ", ctx.width - 2))
    )
  end)
end)
