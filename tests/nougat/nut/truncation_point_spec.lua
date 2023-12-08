pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.truncation_point", function()
  local bar, ctx

  local nut

  before_each(function()
    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    nut = require("nougat.nut.truncation_point")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works", function()
    local left = string.rep("A", ctx.width / 2 + 5)
    local right = string.rep("B", ctx.width / 2)

    bar:add_item(left)
    bar:add_item(nut.create())
    bar:add_item(right)

    t.eq(bar:generate(ctx), string.format("%s%s%s", left, "%<", right))
    t.eq(
      vim.api.nvim_eval_statusline(bar:generate(ctx), { winid = ctx.winid }).str,
      string.format("%s%s%s", left, "<", string.sub(right, 1, -7))
    )
  end)
end)
