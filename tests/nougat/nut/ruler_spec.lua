pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.ruler", function()
  local bar, ctx

  local ruler

  before_each(function()
    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    ruler = require("nougat.nut.ruler")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works", function()
    bar:add_item(ruler.create())

    t.eq(bar:generate(ctx), "%-14(%l,%c%V%) %P")
    t.eq(vim.api.nvim_eval_statusline(bar:generate(ctx), { winid = ctx.winid }).str, "0,0-1          All")
  end)

  it("uses 'rulerformat'", function()
    vim.o.rulerformat = "%P"

    bar:add_item(ruler.create())

    t.eq(bar:generate(ctx), vim.o.rulerformat)
    t.eq(vim.api.nvim_eval_statusline(bar:generate(ctx), { winid = ctx.winid }).str, "All")
  end)
end)
