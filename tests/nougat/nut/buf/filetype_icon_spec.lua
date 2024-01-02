pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.buf.filetype_icon", function()
  local bar, ctx

  local nut

  before_each(function()
    require("nougat.store")._clear()

    package.loaded["nougat.nut.buf.filetype_icon"] = nil

    package.loaded["nvim-web-devicons"] = {
      get_icon_color_by_filetype = function()
        return "~", "yellow"
      end,
    }

    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    nut = require("nougat.nut.buf.filetype_icon")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works", function()
    vim.api.nvim_buf_set_name(ctx.bufnr, "_A_.md")

    bar:add_item(nut.create({}))

    t.eq(
      bar:generate(ctx),
      table.concat({
        "%#bg_ffcd00_fg_yellow_#",
        "~",
        "%#bg_ffcd00_fg_663399_#",
      }, "")
    )
  end)
end)
