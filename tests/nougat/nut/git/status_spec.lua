pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.git.status", function()
  local bar, ctx

  local nut

  before_each(function()
    require("nougat.util.store").clear_all()

    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    nut = require("nougat.nut.git.status")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works", function()
    package.loaded["gitsigns"] = {}

    bar:add_item(nut.create({
      prefix = " ",
      content = {
        nut.count("added", { prefix = "+", suffix = " " }),
        nut.count("changed", { prefix = "~", suffix = " " }),
        nut.count("removed", { prefix = "-", suffix = " " }),
      },
    }))

    package.loaded["gitsigns"] = nil

    vim.b[ctx.bufnr].gitsigns_status_dict = {
      added = 1,
    }
    vim.api.nvim_exec_autocmds("User", { pattern = "GitSignsUpdate" })
    vim.wait(0)

    t.eq(bar:generate(ctx), " +1 ")

    vim.b[ctx.bufnr].gitsigns_status_dict = {
      added = 0,
      changed = 2,
      removed = 3,
    }
    vim.api.nvim_exec_autocmds("User", { pattern = "GitSignsUpdate" })
    vim.wait(0)

    t.eq(bar:generate(ctx), " ~2 -3 ")
  end)

  it("can handle missing gitstatus", function()
    package.loaded["gitsigns"] = {}

    bar:add_item(nut.create({
      prefix = " ",
      content = {
        nut.count("added", { prefix = "+", suffix = " " }),
      },
    }))

    package.loaded["gitsigns"] = nil

    vim.b[ctx.bufnr].gitsigns_status_dict = nil
    vim.api.nvim_exec_autocmds("User", { pattern = "GitSignsUpdate" })
    vim.wait(0)

    t.eq(bar:generate(ctx), "")
  end)

  it("can handle missing provider", function()
    bar:add_item(nut.create({
      prefix = " ",
      content = {
        nut.count("added", { prefix = "+", suffix = " " }),
      },
    }))

    t.eq(bar:generate(ctx), "")
  end)
end)
