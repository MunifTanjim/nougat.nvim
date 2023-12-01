pcall(require, "luacov")

local Bar = require("nougat.bar")
local Item = require("nougat.item")
local nut = {
  mode = require("nougat.nut.mode"),
  buf = {
    filename = require("nougat.nut.buf.filename"),
  },
}

local t = require("tests.util")

describe("NougatBar", function()
  it("can be initialized", function()
    local bar = Bar("statusline")
    t.type(bar.id, "number")
    t.eq(bar.type, "statusline")
  end)

  describe("o.hl", function()
    local ctx, hl

    before_each(function()
      ctx = t.make_ctx(0, {
        ctx = {},
        width = vim.api.nvim_win_get_width(0),
      })
      hl = { bg = "#ffcd00", fg = "#663399" }
    end)

    it("string", function()
      vim.api.nvim_set_hl(0, "NougatTest", hl)

      local bar = Bar("statusline", { hl = "NougatTest" })

      bar:add_item(Item({
        hl = { bold = true },
        content = "Content",
      }))

      t.eq(bar:generate(ctx), "%#nougat_hl_bg_ffcd00_fg_663399_b#Content%#nougat_hl_bg_ffcd00_fg_663399_#")

      t.eq(ctx.hl, hl)
    end)

    it("integer", function()
      vim.api.nvim_set_hl(0, "User1", hl)

      local bar = Bar("statusline", { hl = 1 })

      bar:add_item(Item({
        hl = { bold = true },
        content = "Content",
      }))

      t.eq(bar:generate(ctx), "%#nougat_hl_bg_ffcd00_fg_663399_b#Content%#nougat_hl_bg_ffcd00_fg_663399_#")

      t.eq(ctx.hl, hl)
    end)

    it("nougat_hl_def", function()
      local bar = Bar("statusline", { hl = hl })

      bar:add_item(Item({
        hl = { bold = true },
        content = "Content",
      }))

      t.eq(bar:generate(ctx), "%#nougat_hl_bg_ffcd00_fg_663399_b#Content%#nougat_hl_bg_ffcd00_fg_663399_#")

      t.eq(ctx.hl, hl)
    end)

    it("function", function()
      vim.api.nvim_set_hl(0, "NougatTest", { bg = "#ffcd00", fg = "#663399" })

      local bar
      bar = Bar("statusline", {
        hl = function(self, context)
          t.ref(self, bar)
          t.ref(context, ctx)
          return "NougatTest"
        end,
      })

      bar:add_item(Item({
        hl = { bold = true },
        content = "Content",
      }))

      t.eq(bar:generate(ctx), "%#nougat_hl_bg_ffcd00_fg_663399_b#Content%#nougat_hl_bg_ffcd00_fg_663399_#")

      t.eq(ctx.hl, hl)
    end)
  end)

  describe(":generate basic", function()
    local bar, ctx

    before_each(function()
      bar = Bar("statusline")
      ctx = t.make_ctx(0, {
        ctx = {},
        width = vim.api.nvim_win_get_width(0),
      })
    end)

    it("strings", function()
      bar:add_item("A")
      bar:add_item("B")
      bar:add_item("C")

      t.eq(bar:generate(ctx), "ABC")
    end)

    it("items", function()
      bar:add_item(nut.mode.create())
      bar:add_item(nut.buf.filename.create({}))

      t.eq(bar:generate(ctx), "%#nougat_hl_bg_663399_fg_ffcd00_#NORMAL%#nougat_hl_bg_ffcd00_fg_663399_#[No Name]")
    end)
  end)

  describe(":generate w/ min breakpoints", function()
    local breakpoint = { s = 1, m = 2, l = 3 }
    local breakpoints = { [breakpoint.s] = 0, [breakpoint.m] = 40, [breakpoint.l] = 80 }
    local bar, ctx

    before_each(function()
      bar = Bar("statusline", { breakpoints = breakpoints })
      ctx = t.make_ctx(0, {
        ctx = {},
        width = breakpoints[2] - 1,
      })
    end)

    it("filename", function()
      bar:add_item(nut.buf.filename.create({
        prefix = { "", " ", "  " },
        suffix = { "", " ", "  " },
        config = {
          modifier = ":t",
          [breakpoint.m] = {
            modifier = ":.",
            format = function(name)
              return vim.fn.pathshorten(name)
            end,
          },
          [breakpoint.l] = {
            format = false,
          },
        },
      }))

      local root_dir = vim.fn.fnamemodify(vim.trim(vim.fn.system("git rev-parse --show-toplevel")), ":p")

      vim.api.nvim_buf_set_name(ctx.bufnr, root_dir .. "/some/folder/file.md")

      t.eq(bar:generate(ctx), "file.md")

      ctx.width = breakpoints[3] - 1

      t.eq(bar:generate(ctx), " s/f/file.md ")

      ctx.width = breakpoints[3] + 1

      t.eq(bar:generate(ctx), "  some/folder/file.md  ")
    end)
  end)

  describe(":generate w/ max breakpoints", function()
    local breakpoint = { l = 1, m = 2, s = 3 }
    local breakpoints = { [breakpoint.l] = math.huge, [breakpoint.m] = 80, [breakpoint.s] = 40 }
    local bar, ctx

    before_each(function()
      bar = Bar("statusline", { breakpoints = breakpoints })
      ctx = t.make_ctx(0, {
        ctx = {},
        width = breakpoints[2] + 1,
      })
    end)

    it("filename", function()
      bar:add_item(nut.buf.filename.create({
        prefix = { "  ", " ", "" },
        suffix = { "  ", " ", "" },
        config = {
          modifier = ":.",
          [breakpoint.m] = {
            format = function(name)
              return vim.fn.pathshorten(name)
            end,
          },
          [breakpoint.s] = {
            modifier = ":t",
            format = false,
          },
        },
      }))

      local root_dir = vim.fn.fnamemodify(vim.trim(vim.fn.system("git rev-parse --show-toplevel")), ":p")

      vim.api.nvim_buf_set_name(ctx.bufnr, root_dir .. "/some/folder/file.md")

      t.eq(bar:generate(ctx), "  some/folder/file.md  ")

      ctx.width = breakpoints[3] + 1

      t.eq(bar:generate(ctx), " s/f/file.md ")

      ctx.width = breakpoints[3] - 1

      t.eq(bar:generate(ctx), "file.md")
    end)
  end)
end)
