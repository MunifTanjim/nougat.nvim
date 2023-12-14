pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.buf.fileencoding", function()
  local bar, ctx

  local nut

  before_each(function()
    require("nougat.store")._clear()

    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    nut = require("nougat.nut.buf.fileencoding")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works w/o config", function()
    bar:add_item(nut.create({}))

    t.eq(bar:generate(ctx), "")

    vim.bo[ctx.bufnr].fileencoding = "UTF-8"
    t.eq(bar:generate(ctx), "utf-8")

    vim.bo[ctx.bufnr].bomb = true
    t.eq(bar:generate(ctx), "utf-8[BOM]")

    vim.bo[ctx.bufnr].endofline = false
    t.eq(bar:generate(ctx), "utf-8[BOM][!EOL]")

    vim.bo[ctx.bufnr].fileencoding = ""
    t.eq(bar:generate(ctx), "[BOM][!EOL]")
  end)

  it("works w/ config", function()
    bar:add_item(nut.create({
      config = {
        text = {
          bomb = "(B)",
          noendofline = "(!)",
        },
      },
    }))

    t.eq(bar:generate(ctx), "")

    vim.bo[ctx.bufnr].fileencoding = "UTF-8"
    t.eq(bar:generate(ctx), "utf-8")

    vim.bo[ctx.bufnr].bomb = true
    t.eq(bar:generate(ctx), "utf-8(B)")

    vim.bo[ctx.bufnr].endofline = false
    t.eq(bar:generate(ctx), "utf-8(B)(!)")

    vim.bo[ctx.bufnr].fileencoding = ""
    t.eq(bar:generate(ctx), "(B)(!)")
  end)
end)
