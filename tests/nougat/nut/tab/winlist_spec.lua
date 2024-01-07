pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.tab.winlist", function()
  local winlist

  local tabs = t.make_tabs()
  local bar, ctx

  before_each(function()
    vim.go.showtabline = 2

    require("nougat.store")._clear()

    winlist = {
      wins = require("nougat.nut.tab.winlist").create,
      label = require("nougat.nut.tab.winlist.label").create,
    }

    bar = Bar("tabline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    tabs.init()
  end)

  after_each(function()
    tabs.cleanup()

    vim.go.showtabline = 1
  end)

  it("works", function()
    vim.api.nvim_buf_set_name(tabs[1].wins[1].bufnr, "WIN:A")
    vim.api.nvim_buf_set_name(tabs[1].wins.new().bufnr, "WIN:B")

    bar:add_item(winlist.wins({}))

    t.eq(
      bar:generate(ctx),
      table.concat({
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%1@v:lua.nougat_core_click_handler@WIN:B%T",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_0a0b10_fg_c4c6cd_b#",
        "%2@v:lua.nougat_core_click_handler@WIN:A%T",
        "%#bg_0a0b10_fg_c4c6cd_#",
      }, "")
    )
  end)

  it("handles win move", function()
    vim.api.nvim_buf_set_name(tabs[1].wins[1].bufnr, "WIN:A")
    vim.api.nvim_buf_set_name(tabs[1].wins.new().bufnr, "WIN:B")

    vim.api.nvim_set_current_win(ctx.winid)

    bar:add_item(winlist.wins({
      active_item = {
        hl = { bg = "black", fg = "blue" },
        prefix = " ",
        suffix = " ",
        content = {
          winlist.label({}),
        },
      },
      inactive_item = {
        hl = { bg = "gray", fg = "black" },
        prefix = " ",
        suffix = " ",
        content = {
          winlist.label({}),
        },
      },
    }))

    t.eq(
      bar:generate(ctx),
      table.concat({
        "%#bg_gray_fg_black_#",
        " ",
        "%1@v:lua.nougat_core_click_handler@WIN:B%T",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_black_fg_blue_#",
        " ",
        "%2@v:lua.nougat_core_click_handler@WIN:A%T",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
      }, "")
    )

    t.feedkeys("<C-W>K", "x")

    t.eq(
      bar:generate(ctx),
      table.concat({
        "%#bg_black_fg_blue_#",
        " ",
        "%2@v:lua.nougat_core_click_handler@WIN:A%T",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
        "%#bg_gray_fg_black_#",
        " ",
        "%1@v:lua.nougat_core_click_handler@WIN:B%T",
        " ",
        "%#bg_0a0b10_fg_c4c6cd_#",
      }, "")
    )
  end)

  describe("label", function()
    it("on_click", function()
      vim.api.nvim_buf_set_name(tabs[1].wins[1].bufnr, "WIN:A")
      vim.api.nvim_buf_set_name(tabs[1].wins.new().bufnr, "WIN:B")

      vim.api.nvim_set_current_win(ctx.winid)

      bar:add_item(winlist.wins({}))

      t.eq(
        bar:generate(ctx),
        table.concat({
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%1@v:lua.nougat_core_click_handler@WIN:B%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_b#",
          "%2@v:lua.nougat_core_click_handler@WIN:A%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
        }, "")
      )

      local click_fn, fn_id = t.get_click_fn(bar:generate(ctx), "WIN:B")
      click_fn(fn_id, 1, "l", "")

      t.eq(vim.api.nvim_get_current_win(), tabs[1].wins[2].winid)
    end)
  end)

  describe("w/ tablist", function()
    local tablist = {
      tabs = require("nougat.nut.tab.tablist").create,
      number = require("nougat.nut.tab.tablist.number").create,
      win_count = require("nougat.nut.tab.tablist.win_count").create,
    }

    it("works", function()
      vim.api.nvim_buf_set_name(tabs[1].wins[1].bufnr, "WIN:A")
      vim.api.nvim_buf_set_name(tabs[1].wins.new().bufnr, "WIN:B")

      vim.api.nvim_buf_set_name(tabs.add().wins[1].bufnr, "WIN:X")
      vim.api.nvim_buf_set_name(tabs[2].wins.new().bufnr, "WIN:Y")

      vim.api.nvim_set_current_win(ctx.winid)

      bar:add_item(tablist.tabs({
        active_tab = {
          content = {
            tablist.number({}),
            winlist.wins({}),
          },
        },
        inactive_tab = {
          content = {
            tablist.number({}),
            tablist.win_count({ prefix = "(", suffix = ")" }),
            winlist.wins({}),
          },
        },
      }))

      vim.api.nvim_set_current_win(ctx.winid)

      bar:generate(ctx)

      t.eq(
        bar:generate(ctx),
        table.concat({
          "%#bg_0a0b10_fg_c4c6cd_b#",
          "%1T1%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%1@v:lua.nougat_core_click_handler@WIN:B%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_b#",
          "%2@v:lua.nougat_core_click_handler@WIN:A%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%2T2%T",
          "(2)",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%3@v:lua.nougat_core_click_handler@WIN:Y%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%4@v:lua.nougat_core_click_handler@WIN:X%T",
          "%#bg_0a0b10_fg_c4c6cd_#",
          "%#bg_0a0b10_fg_c4c6cd_#",
        }, "")
      )

      local click_fn, fn_id = t.get_click_fn(bar:generate(ctx), "WIN:Y")
      click_fn(fn_id, 1, "l", "")

      t.eq(vim.api.nvim_get_current_win(), tabs[2].wins[2].winid)
      t.eq(vim.api.nvim_get_current_tabpage(), tabs[2].tabid)
    end)
  end)
end)
