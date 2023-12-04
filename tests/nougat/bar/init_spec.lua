pcall(require, "luacov")

local Bar = require("nougat.bar")
local Item = require("nougat.item")
local sep = require("nougat.separator")
local nut = {
  mode = require("nougat.nut.mode"),
  buf = {
    filename = require("nougat.nut.buf.filename"),
  },
}

local t = require("tests.util")

describe("NougatBar", function()
  local ctx

  before_each(function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, bufnr)
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("can be initialized", function()
    local bar = Bar("statusline")
    t.type(bar.id, "number")
    t.eq(bar.type, "statusline")
  end)

  describe("o.breakpoints", function()
    it("throws if [1] is not 0 or math.huge", function()
      local err = t.error(function()
        return Bar("statusline", { breakpoints = { 1 } })
      end)
      t.match(err, "breakpoints%[1%] must be 0 or math.huge")
    end)

    it("prepares NougatItem after adding", function()
      local bar = Bar("statusline", { breakpoints = { 0, 40 } })

      local a = bar:add_item({ prefix = "x", content = "a" })
      t.eq(a.prefix[1], "x")
      t.eq(a.prefix[2], "x")

      local b1 = Item({ prefix = "y1", content = "b1" })
      local b = bar:add_item({ prefix = "y", content = { b1 } })
      t.eq(b.prefix[1], "y")
      t.eq(b.prefix[2], "y")
      t.eq(b1.prefix[1], "y1")
      t.eq(b1.prefix[2], "y1")
    end)
  end)

  describe("o.hl", function()
    local hl

    before_each(function()
      ctx.width = vim.api.nvim_win_get_width(0)
      hl = { bg = "#ffcd00", fg = "#663399" }
    end)

    it("string", function()
      vim.api.nvim_set_hl(0, "NougatTest", hl)

      local bar = Bar("statusline", { hl = "NougatTest" })

      bar:add_item(Item({
        hl = { bold = true },
        content = "Content",
      }))

      t.eq(bar:generate(ctx), "%#bg_ffcd00_fg_663399_b#Content%#bg_ffcd00_fg_663399_#")

      t.eq(ctx.hl, hl)
    end)

    it("integer", function()
      vim.api.nvim_set_hl(0, "User1", hl)

      local bar = Bar("statusline", { hl = 1 })

      bar:add_item(Item({
        hl = { bold = true },
        content = "Content",
      }))

      t.eq(bar:generate(ctx), "%#bg_ffcd00_fg_663399_b#Content%#bg_ffcd00_fg_663399_#")

      t.eq(ctx.hl, hl)
    end)

    it("nougat_hl_def", function()
      local bar = Bar("statusline", { hl = hl })

      bar:add_item(Item({
        hl = { bold = true },
        content = "Content",
      }))

      t.eq(bar:generate(ctx), "%#bg_ffcd00_fg_663399_b#Content%#bg_ffcd00_fg_663399_#")

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

      t.eq(bar:generate(ctx), "%#bg_ffcd00_fg_663399_b#Content%#bg_ffcd00_fg_663399_#")

      t.eq(ctx.hl, hl)
    end)
  end)

  describe(":generate basic", function()
    local bar

    before_each(function()
      bar = Bar("statusline")
      ctx.width = vim.api.nvim_win_get_width(0)
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

      t.eq(bar:generate(ctx), "%#bg_663399_fg_ffcd00_#NORMAL%#bg_ffcd00_fg_663399_#[No Name]")
    end)
  end)

  describe(":generate w/ min breakpoints", function()
    local breakpoint = { s = 1, m = 2, l = 3 }
    local breakpoints = { [breakpoint.s] = 0, [breakpoint.m] = 40, [breakpoint.l] = 80 }
    local bar

    before_each(function()
      bar = Bar("statusline", { breakpoints = breakpoints })
      ctx.width = breakpoints[2] - 1
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
    local bar

    before_each(function()
      bar = Bar("statusline", { breakpoints = breakpoints })
      ctx.width = breakpoints[2] + 1
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

  describe(":generate", function()
    it("w/ fancy separator", function()
      local bar = Bar("statusline")

      bar:add_item({
        hl = { bg = "purple", fg = "yellow" },
        content = "X",
      })
      bar:add_item({
        hl = { fg = "cyan" },
        sep_left = sep.left_lower_triangle_solid(true),
        prefix = ".",
        content = "X",
        suffix = ".",
        sep_right = sep.right_lower_triangle_solid(true),
      })
      bar:add_item({
        hl = { bg = "purple", fg = "yellow" },
        content = "X",
      })

      t.eq(
        bar:generate(ctx),
        table.concat({
          "%#bg_purple_fg_yellow_#",
          "X",
          "%#bg_ffcd00_fg_663399_#",
          "%#bg_purple_fg_ffcd00_#",
          "",
          "%#bg_ffcd00_fg_cyan_#",
          ".X.",
          "%#bg_purple_fg_ffcd00_#",
          "",
          "%#bg_ffcd00_fg_663399_#",
          "%#bg_purple_fg_yellow_#",
          "X",
          "%#bg_ffcd00_fg_663399_#",
        }, "")
      )
    end)

    describe("w/ priority", function()
      local bar

      before_each(function()
        bar = Bar("statusline")
        ctx.width = vim.api.nvim_win_get_width(0)
      end)

      it("basic", function()
        bar:add_item(Item({
          priority = 1,
          content = string.rep("A", 10),
        }))
        bar:add_item(Item({
          priority = 3,
          content = string.rep("B", 10),
        }))
        bar:add_item(Item({
          priority = 2,
          content = string.rep("C", 10),
        }))

        ctx.width = 30
        t.eq(bar:generate(ctx), string.format("%s%s%s", string.rep("A", 10), string.rep("B", 10), string.rep("C", 10)))

        ctx.width = 25
        t.eq(bar:generate(ctx), string.format("%s%s%s", string.rep("A", 0), string.rep("B", 10), string.rep("C", 10)))

        ctx.width = 15
        t.eq(bar:generate(ctx), string.format("%s%s%s", string.rep("A", 0), string.rep("B", 10), string.rep("C", 0)))
      end)

      it("nested", function()
        bar:add_item(nut.mode.create({
          priority = 3,
        }))
        bar:add_item(nut.buf.filename.create({
          priority = 1,
        }))
        bar:add_item(Item({
          priority = 2,
          prefix = " ",
          content = {
            Item({
              priority = 1,
              prefix = "+",
              content = "1",
              suffix = " ",
            }),
            Item({
              priority = 2,
              prefix = "~",
              content = "1",
              suffix = " ",
            }),
            Item({
              priority = 1,
              prefix = "-",
              content = "1",
              suffix = " ",
            }),
          },
        }))

        ctx.width = string.len("NORMAL") + string.len("[No Name]") + 1 + (2 + 1) * 3
        t.eq(bar:generate(ctx), "%#bg_663399_fg_ffcd00_#NORMAL%#bg_ffcd00_fg_663399_#[No Name] +1 ~1 -1 ")

        ctx.width = string.len("NORMAL") + string.len("[No Name]") + 1 + (2 + 1) * 3 - 1
        t.eq(bar:generate(ctx), "%#bg_663399_fg_ffcd00_#NORMAL%#bg_ffcd00_fg_663399_# +1 ~1 -1 ")

        ctx.width = string.len("NORMAL") + 1 + (2 + 1) * 3
        t.eq(bar:generate(ctx), "%#bg_663399_fg_ffcd00_#NORMAL%#bg_ffcd00_fg_663399_# +1 ~1 -1 ")

        ctx.width = string.len("NORMAL") + 1 + (2 + 1) * 3 - 1
        t.eq(bar:generate(ctx), "%#bg_663399_fg_ffcd00_#NORMAL%#bg_ffcd00_fg_663399_# +1 ~1 ")

        ctx.width = string.len("NORMAL") + 1 + (2 + 1) * 2 - 1
        t.eq(bar:generate(ctx), "%#bg_663399_fg_ffcd00_#NORMAL%#bg_ffcd00_fg_663399_# ~1 ")

        ctx.width = 1 + (2 + 1) * 1 + 1
        t.eq(bar:generate(ctx), " ~1 ")
      end)
    end)
  end)
end)
