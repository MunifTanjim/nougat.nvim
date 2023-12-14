pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.buf.filestatus", function()
  local bar, ctx

  local filestatus

  before_each(function()
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_win_set_buf(0, bufnr)

    require("nougat.store")._clear()

    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    filestatus = require("nougat.nut.buf.filestatus")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works w/o config", function()
    bar:add_item(filestatus.create({}))

    t.eq(bar:generate(ctx), "")

    vim.v = { option_new = false }
    vim.api.nvim_exec_autocmds("OptionSet", {
      pattern = "modifiable",
    })

    t.eq(bar:generate(ctx), "-")

    vim.v = { option_new = true }
    vim.api.nvim_exec_autocmds("OptionSet", {
      pattern = "readonly",
    })

    t.eq(bar:generate(ctx), "RO,-")

    vim.bo[ctx.bufnr].modified = true
    vim.api.nvim_exec_autocmds("BufModifiedSet", {
      buffer = ctx.bufnr,
    })

    t.eq(bar:generate(ctx), "RO,+,-")
  end)

  it("works w/ config", function()
    bar:add_item(filestatus.create({
      config = {
        sep = " ",
      },
    }))

    t.eq(bar:generate(ctx), "")

    vim.v = { option_new = false }
    vim.api.nvim_exec_autocmds("OptionSet", {
      pattern = "modifiable",
    })

    t.eq(bar:generate(ctx), "-")

    vim.v = { option_new = true }
    vim.api.nvim_exec_autocmds("OptionSet", {
      pattern = "readonly",
    })

    t.eq(bar:generate(ctx), "RO -")

    vim.bo[ctx.bufnr].modified = true
    vim.api.nvim_exec_autocmds("BufModifiedSet", {
      buffer = ctx.bufnr,
    })

    t.eq(bar:generate(ctx), "RO + -")
  end)
end)
