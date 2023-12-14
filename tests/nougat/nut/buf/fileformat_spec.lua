pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.buf.fileformat", function()
  local bar, ctx

  ---@module 'nougat.nut.buf.fileformat'
  local fileformat

  before_each(function()
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_win_set_buf(0, bufnr)

    require("nougat.store")._clear()

    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    fileformat = require("nougat.nut.buf.fileformat")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works w/o config", function()
    bar:add_item(fileformat.create({}))

    t.eq(bar:generate(ctx), vim.bo[ctx.bufnr].fileformat)

    vim.bo[ctx.bufnr].fileformat = "mac"

    vim.api.nvim_exec_autocmds("BufWritePost", {
      buffer = ctx.bufnr,
    })

    t.eq(bar:generate(ctx), vim.bo[ctx.bufnr].fileformat)
  end)

  it("works w/ config", function()
    bar:add_item(fileformat.create({
      config = {
        text = {
          unix = "UNIX",
          mac = "MAC",
        },
      },
    }))

    t.eq(bar:generate(ctx), "UNIX")

    vim.bo[ctx.bufnr].fileformat = "mac"

    vim.api.nvim_exec_autocmds("BufWritePost", {
      buffer = ctx.bufnr,
    })

    t.eq(bar:generate(ctx), "MAC")
  end)
end)
