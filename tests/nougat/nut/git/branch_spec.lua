pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.git.branch", function()
  local bar, ctx

  local nut

  before_each(function()
    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    nut = require("nougat.nut.git.branch")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works w/o config (fugitive)", function()
    local orig_fn = vim.api.nvim_get_runtime_file
    vim.api.nvim_get_runtime_file = function(name, all)
      vim.api.nvim_get_runtime_file = orig_fn
      if name == "plugin/fugitive.vim" and all == false then
        return { "" }
      end
      return vim.api.nvim_get_runtime_file(name, all)
    end

    bar:add_item(nut.create())

    local fn_name = "FugitiveHead"
    vim.fn[fn_name] = function()
      return "fugitive:branch"
    end

    t.eq(bar:generate(ctx), "fugitive:branch")
  end)

  it("works w/o config (gitsigns)", function()
    package.loaded["gitsigns"] = {}

    bar:add_item(nut.create())

    package.loaded["gitsigns"] = nil

    vim.b.gitsigns_head = "gitsigns:branch"

    t.eq(bar:generate(ctx), "gitsigns:branch")
  end)

  it("is hidden for missing provider", function()
    bar:add_item(nut.create())

    t.eq(bar:generate(ctx), "")
  end)

  it("works w/ config", function()
    package.loaded["gitsigns"] = {}

    bar:add_item(nut.create({
      config = {
        provider = "gitsigns",
      },
    }))

    package.loaded["gitsigns"] = nil

    vim.b.gitsigns_head = "gitsigns:branch"

    t.eq(bar:generate(ctx), "gitsigns:branch")
  end)
end)
