pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.buf.filetype", function()
  local bar, ctx

  local filetype

  before_each(function()
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_win_set_buf(0, bufnr)

    require("nougat.util.store").clear_all()

    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    filetype = require("nougat.nut.buf.filetype")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works", function()
    bar:add_item(filetype.create({}))

    t.eq(bar:generate(ctx), "%{&filetype}")
  end)
end)
