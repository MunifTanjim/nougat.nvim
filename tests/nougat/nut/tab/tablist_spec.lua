pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.tab.tablist", function()
  local tablist

  ---@type { bufnr: integer, winid: integer, tabid: integer }[]
  local tabs = {}
  local bar, ctx, ns

  local function add_tab()
    vim.cmd.tabnew()
    local tab = {
      bufnr = vim.api.nvim_get_current_buf(),
      winid = vim.api.nvim_get_current_win(),
      tabid = vim.api.nvim_get_current_tabpage(),
    }
    table.insert(tabs, tab)
    return tab
  end

  before_each(function()
    require("nougat.store")._clear()

    tablist = {
      tabs = require("nougat.nut.tab.tablist").create,
      close = require("nougat.nut.tab.tablist.close").create,
      diagnostic_count = require("nougat.nut.tab.tablist.diagnostic_count").create,
      icon = require("nougat.nut.tab.tablist.icon").create,
      label = require("nougat.nut.tab.tablist.label").create,
      label_hl = require("nougat.nut.tab.tablist.label").hl,
      modified = require("nougat.nut.tab.tablist.modified").create,
    }

    tabs = {}

    ns = vim.api.nvim_create_namespace("test:nut.tab.tablist")

    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_win_set_buf(0, bufnr)

    bar = Bar("tabline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    table.insert(tabs, { bufnr = ctx.bufnr, winid = ctx.winid, tabid = ctx.tabid })
  end)

  after_each(function()
    vim.cmd.tabonly({ bang = true })

    for _, tab in ipairs(tabs) do
      vim.api.nvim_buf_delete(tab.bufnr, { force = true })
    end
  end)

  it("works", function()
    vim.api.nvim_buf_set_name(tabs[1].bufnr, "TAB:A")
    vim.api.nvim_buf_set_name(add_tab().bufnr, "TAB:B")

    bar:add_item(tablist.tabs({
      active_tab = {
        hl = { bg = "black", fg = "blue" },
        prefix = " ",
        suffix = " ",
        content = {
          tablist.icon({ content = "~", suffix = " " }),
          tablist.label({}),
          tablist.modified({ prefix = " ", config = { text = "●" } }),
          tablist.close({ prefix = " ", config = { text = "󰅖" } }),
        },
      },
      inactive_tab = {
        hl = { bg = "gray", fg = "black" },
        prefix = " ",
        suffix = " ",
        content = {
          tablist.icon({ content = "~", suffix = " " }),
          tablist.label({}),
          tablist.modified({ prefix = " ", config = { text = "●" } }),
          tablist.close({ prefix = " ", config = { text = "󰅖" } }),
        },
      },
    }))

    t.eq(
      bar:generate(ctx),
      table.concat({
        "%#bg_black_fg_blue_#",
        " ~ ",
        "%1TTAB:A%T",
        " ",
        "%1X󰅖%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_gray_fg_black_#",
        " ~ ",
        "%2TTAB:B%T",
        " ",
        "%2X󰅖%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
      })
    )

    vim.bo[tabs[1].bufnr].modified = true
    vim.api.nvim_exec_autocmds("BufModifiedSet", {
      buffer = tabs[1].bufnr,
    })

    t.eq(
      bar:generate(ctx),
      table.concat({
        "%#bg_black_fg_blue_#",
        " ~ ",
        "%1TTAB:A%T",
        " ",
        "●",
        " ",
        "%1X󰅖%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_gray_fg_black_#",
        " ~ ",
        "%2TTAB:B%T",
        " ",
        "%2X󰅖%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
      })
    )
  end)

  describe("label", function()
    it("handles tab move", function()
      vim.api.nvim_buf_set_name(tabs[1].bufnr, "_A_")
      vim.api.nvim_buf_set_name(add_tab().bufnr, "_B_")
      vim.api.nvim_buf_set_name(add_tab().bufnr, "_C_")

      bar:add_item(tablist.tabs({}))

      t.eq(
        bar:generate(ctx),
        table.concat({
          "%#bg_0a0b10_fg_c4c6cd_b#",
          "▎",
          "%1T_A_%T",
          " ",
          "%1XX%X",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "▎",
          "%2T_B_%T",
          " ",
          "%2XX%X",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "▎",
          "%3T_C_%T",
          " ",
          "%3XX%X",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
        })
      )

      vim.api.nvim_set_current_tabpage(tabs[1].tabid)
      vim.cmd.tabmove(2)

      t.eq(
        bar:generate(ctx),
        table.concat({
          "%#bg_0a0b10_fg_c4c6cd_#",
          "▎",
          "%1T_B_%T",
          " ",
          "%1XX%X",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_b#",
          "▎",
          "%2T_A_%T",
          " ",
          "%2XX%X",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "▎",
          "%3T_C_%T",
          " ",
          "%3XX%X",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
        })
      )
    end)

    it(".hl.diagnostic()", function()
      vim.api.nvim_buf_set_name(tabs[1].bufnr, "_A_")
      vim.api.nvim_buf_set_name(add_tab().bufnr, "_B_")

      bar:add_item(tablist.tabs({
        active_tab = {
          hl = { bg = "black", fg = "blue" },
          prefix = " ",
          suffix = " ",
          content = {
            tablist.label({ hl = tablist.label_hl.diagnostic() }),
          },
        },
        inactive_tab = {
          hl = { bg = "gray", fg = "cyan" },
          prefix = " ",
          suffix = " ",
          content = {
            tablist.label({ hl = tablist.label_hl.diagnostic() }),
          },
        },
      }))

      t.eq(
        bar:generate(ctx),
        table.concat({
          "%#bg_black_fg_blue_#",
          " ",
          "%1T_A_%T",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_gray_fg_cyan_#",
          " ",
          "%2T_B_%T",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
        })
      )

      vim.diagnostic.set(ns, tabs[1].bufnr, {
        { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.ERROR },
      })
      vim.diagnostic.set(ns, tabs[2].bufnr, {
        { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.INFO },
      })

      t.wait_for(function()
        local diag_cache = require("nougat.cache.diagnostic")
        local severity = diag_cache.severity.COMBINED
        return diag_cache.store[tabs[1].bufnr][severity] + diag_cache.store[tabs[2].bufnr][severity] == 2
      end, 100)

      t.eq(
        bar:generate(ctx),
        table.concat({
          "%#bg_black_fg_blue_#",
          " ",
          "%#bg_black_fg_ff0000_#",
          "%1T_A_%T",
          "%#bg_black_fg_blue_#",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_gray_fg_cyan_#",
          " ",
          "%#bg_gray_fg_00ff00_#",
          "%2T_B_%T",
          "%#bg_gray_fg_cyan_#",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
        })
      )

      vim.diagnostic.reset(ns, tabs[2].bufnr)

      t.wait_for(function()
        local diag_cache = require("nougat.cache.diagnostic")
        local severity = diag_cache.severity.COMBINED
        return diag_cache.store[tabs[1].bufnr][severity] + diag_cache.store[tabs[2].bufnr][severity] == 1
      end, 100)

      t.eq(
        bar:generate(ctx),
        table.concat({
          "%#bg_black_fg_blue_#",
          " ",
          "%#bg_black_fg_ff0000_#",
          "%1T_A_%T",
          "%#bg_black_fg_blue_#",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_gray_fg_cyan_#",
          " ",
          "%2T_B_%T",
          " ",
          "%#bg_0a0b10_fg_c4c6cd_#",
        })
      )
    end)

    it("handles filename change", function()
      vim.api.nvim_buf_set_name(tabs[1].bufnr, "_A_")
      vim.api.nvim_buf_set_name(add_tab().bufnr, "_B_")

      bar:add_item(tablist.tabs({
        active_tab = {
          content = {
            tablist.label({}),
          },
        },
        inactive_tab = {
          content = {
            tablist.label({}),
          },
        },
      }))

      t.eq(
        bar:generate(ctx),
        table.concat({
          "%#bg_0a0b10_fg_c4c6cd_b#",
          "%1T",
          "_A_",
          "%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%2T",
          "_B_",
          "%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
        })
      )

      vim.cmd.file("__B__")

      t.eq(
        bar:generate(ctx),
        table.concat({
          "%#bg_0a0b10_fg_c4c6cd_b#",
          "%1T",
          "_A_",
          "%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%2T",
          "__B__",
          "%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
        })
      )
    end)
  end)

  it("diagnostic_count", function()
    vim.api.nvim_buf_set_name(tabs[1].bufnr, "_A_")
    vim.api.nvim_buf_set_name(add_tab().bufnr, "_B_")
    vim.api.nvim_buf_set_name(add_tab().bufnr, "_C_")
    vim.api.nvim_buf_set_name(add_tab().bufnr, "_D_")

    bar:add_item(tablist.tabs({
      active_tab = {
        hl = { bg = "black", fg = "blue" },
        prefix = " ",
        suffix = " ",
        content = {
          tablist.diagnostic_count({ suffix = " " }),
          tablist.label({}),
          tablist.close({ prefix = " ", config = { text = "x" } }),
        },
      },
      inactive_tab = {
        hl = { bg = "gray", fg = "black" },
        prefix = " ",
        suffix = " ",
        content = {
          tablist.diagnostic_count({ suffix = " " }),
          tablist.label({}),
          tablist.close({ prefix = " ", config = { text = "x" } }),
        },
      },
    }))

    t.eq(
      bar:generate(ctx),
      table.concat({
        "%#bg_black_fg_blue_#",
        " ",
        "%1T_A_%T",
        " ",
        "%1Xx%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_gray_fg_black_#",
        " ",
        "%2T_B_%T",
        " ",
        "%2Xx%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_gray_fg_black_#",
        " ",
        "%3T_C_%T",
        " ",
        "%3Xx%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_gray_fg_black_#",
        " ",
        "%4T_D_%T",
        " ",
        "%4Xx%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
      })
    )

    vim.diagnostic.set(ns, tabs[1].bufnr, {
      { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.ERROR },
      { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.INFO },
    })
    vim.diagnostic.set(ns, tabs[2].bufnr, {
      { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.HINT },
      { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.WARN },
    })
    vim.diagnostic.set(ns, tabs[3].bufnr, {
      { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.INFO },
    })
    vim.diagnostic.set(ns, tabs[4].bufnr, {
      { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.HINT },
    })

    t.wait_for(function()
      local diag_cache = require("nougat.cache.diagnostic")
      local severity = diag_cache.severity.COMBINED
      return diag_cache.store[tabs[1].bufnr][severity]
          + diag_cache.store[tabs[2].bufnr][severity]
          + diag_cache.store[tabs[3].bufnr][severity]
          + diag_cache.store[tabs[4].bufnr][severity]
        == 6
    end, 100)

    t.eq(
      bar:generate(ctx),
      table.concat({
        "%#bg_black_fg_blue_#",
        " ",
        "%#bg_black_fg_ff0000_#",
        "2",
        " ",
        "%#bg_black_fg_blue_#",
        "%1T_A_%T",
        " ",
        "%1Xx%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_gray_fg_black_#",
        " ",
        "%#bg_gray_fg_ffff00_#",
        "2",
        " ",
        "%#bg_gray_fg_black_#",
        "%2T_B_%T",
        " ",
        "%2Xx%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_gray_fg_black_#",
        " ",
        "%#bg_gray_fg_00ff00_#",
        "1",
        " ",
        "%#bg_gray_fg_black_#",
        "%3T_C_%T",
        " ",
        "%3Xx%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_gray_fg_black_#",
        " ",
        "%#bg_gray_fg_00ffff_#",
        "1",
        " ",
        "%#bg_gray_fg_black_#",
        "%4T_D_%T",
        " ",
        "%4Xx%X",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
      })
    )
  end)
end)
