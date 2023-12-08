pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.buf.diagnostic_count", function()
  local bar, ctx, ns

  local dc

  before_each(function()
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_win_set_buf(0, bufnr)

    require("nougat.util.store").clear_all()

    ns = vim.api.nvim_create_namespace("test:nut.tab.tablist")

    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    dc = require("nougat.nut.buf.diagnostic_count")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  describe("severity", function()
    it("works", function()
      bar:add_item(dc.create({
        config = {
          severity = vim.diagnostic.severity.ERROR,
        },
      }))

      t.eq(bar:generate(ctx), "")

      vim.diagnostic.set(ns, ctx.bufnr, {
        { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.ERROR },
      })

      t.wait_for(function()
        local diag_cache = require("nougat.cache.diagnostic")
        local severity = diag_cache.severity.COMBINED
        return diag_cache.store[ctx.bufnr][severity] == 1
      end, 100)

      t.eq(bar:generate(ctx), "1")

      vim.diagnostic.reset(ns, ctx.bufnr)

      t.wait_for(function()
        local diag_cache = require("nougat.cache.diagnostic")
        local severity = diag_cache.severity.COMBINED
        return diag_cache.store[ctx.bufnr][severity] == 0
      end, 100)

      t.eq(bar:generate(ctx), "")

      vim.diagnostic.set(ns, ctx.bufnr, {
        { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.WARN },
      })

      t.wait_for(function()
        local diag_cache = require("nougat.cache.diagnostic")
        local severity = diag_cache.severity.COMBINED
        return diag_cache.store[ctx.bufnr][severity] == 1
      end, 100)

      t.eq(bar:generate(ctx), "")
    end)
  end)

  describe("combined", function()
    it("works w/o config", function()
      bar:add_item(dc.create({}))

      local expected_value = ""

      t.eq(bar:generate(ctx), expected_value)

      local diagnostics = {
        { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.ERROR },
        { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.WARN },
      }

      vim.diagnostic.set(ns, ctx.bufnr, diagnostics)

      t.wait_for(function()
        return bar:generate(ctx) ~= expected_value
      end, 100)

      expected_value = table.concat({
        "%#bg_ffcd00_fg_ff0000_#",
        "E:",
        "1",
        "%#bg_ffcd00_fg_663399_#",
        " ",
        "%#bg_ffcd00_fg_ffff00_#",
        "W:",
        "1",
      })

      t.eq(bar:generate(ctx), expected_value)

      table.insert(diagnostics, { lnum = 0, col = 1, message = "", severity = vim.diagnostic.severity.INFO })
      table.insert(diagnostics, { lnum = 0, col = 1, message = "", severity = vim.diagnostic.severity.HINT })

      vim.diagnostic.set(ns, ctx.bufnr, diagnostics)

      t.wait_for(function()
        return bar:generate(ctx) ~= expected_value
      end, 100)

      expected_value = table.concat({
        "%#bg_ffcd00_fg_ff0000_#",
        "E:",
        "1",
        "%#bg_ffcd00_fg_663399_#",
        " ",
        "%#bg_ffcd00_fg_ffff00_#",
        "W:",
        "1",
        "%#bg_ffcd00_fg_663399_#",
        " ",
        "%#bg_ffcd00_fg_00ff00_#",
        "I:",
        "1",
        "%#bg_ffcd00_fg_663399_#",
        " ",
        "%#bg_ffcd00_fg_00ffff_#",
        "H:",
        "1",
      })

      t.eq(bar:generate(ctx), expected_value)
    end)

    it("works w/ config", function()
      bar:add_item(dc.create({
        config = {
          error = { prefix = "E(", suffix = ")" },
          warn = { prefix = "W(", suffix = ")" },
          sep = "",
        },
      }))

      local expected_value = ""

      t.eq(bar:generate(ctx), expected_value)

      local diagnostics = {
        { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.ERROR },
        { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.WARN },
      }

      vim.diagnostic.set(ns, ctx.bufnr, diagnostics)

      t.wait_for(function()
        return bar:generate(ctx) ~= expected_value
      end, 100)

      expected_value = table.concat({
        "%#bg_ffcd00_fg_ff0000_#",
        "E(",
        "1",
        ")",
        "%#bg_ffcd00_fg_ffff00_#",
        "W(",
        "1",
        ")",
      })

      t.eq(bar:generate(ctx), expected_value)
    end)
  end)

  it(".hidden.if_zero()", function()
    bar:add_item(dc.create({
      hidden = dc.hidden.if_zero(),
      config = {
        severity = vim.diagnostic.severity.ERROR,
      },
    }))

    t.eq(bar:generate(ctx), "")

    vim.diagnostic.set(ns, ctx.bufnr, {
      { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.ERROR },
    })

    t.wait_for(function()
      local diag_cache = require("nougat.cache.diagnostic")
      local severity = diag_cache.severity.COMBINED
      return diag_cache.store[ctx.bufnr][severity] == 1
    end, 100)

    t.eq(bar:generate(ctx), "1")
  end)
end)
