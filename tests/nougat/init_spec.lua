pcall(require, "luacov")

local nougat = require("nougat")
local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nougat", function()
  local function eval_statusline(winid, statusline)
    return vim.api.nvim_eval_statusline(statusline, { winid = winid })
  end

  local function eval_tabline(winid, tabline)
    return vim.api.nvim_eval_statusline(tabline, { winid = winid, use_tabline = true })
  end

  local function eval_winbar(winid, winbar)
    return vim.api.nvim_eval_statusline(winbar, { winid = winid, use_winbar = true })
  end

  before_each(function()
    require("nougat.store")._clear()

    vim.go.laststatus = 2
    vim.go.statusline = ""
    vim.go.tabline = ""
    vim.go.winbar = ""
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      vim.wo[winid].statusline = ""
      vim.wo[winid].winbar = ""
    end
  end)

  describe("set_statusline", function()
    it("accepts NougatBar", function()
      local bar = Bar("statusline")
      bar:add_item("BAR")

      nougat.set_statusline(bar)

      t.eq(eval_statusline(0, vim.o.statusline).str, "BAR")
    end)

    it("accepts nougat_bar_selector", function()
      local bar_a = Bar("statusline")
      bar_a:add_item("BAR_A")

      local bar_b = Bar("statusline")
      bar_b:add_item("BAR_B")

      local bar_idx = 1
      local bars = { bar_a, bar_b }

      nougat.set_statusline(function()
        return bars[bar_idx]
      end)

      t.eq(eval_statusline(0, vim.o.statusline).str, "BAR_A")

      bar_idx = 2
      t.eq(eval_statusline(0, vim.o.statusline).str, "BAR_B")
    end)

    it("can set for filetype", function()
      local bar = Bar("statusline")
      bar:add_item("BAR")

      local bar_a = Bar("statusline")
      bar_a:add_item("BAR_A")

      local bar_b = Bar("statusline")
      bar_b:add_item("BAR_B")

      nougat.set_statusline(bar)
      nougat.set_statusline(bar_a, { filetype = "a" })
      nougat.set_statusline(bar_b, { filetype = "b" })

      t.eq(eval_statusline(0, vim.o.statusline).str, "BAR")

      vim.bo.filetype = "a"
      vim.wait(0)
      t.eq(eval_statusline(0, vim.o.statusline).str, "BAR_A")

      vim.bo.filetype = "b"
      vim.wait(0)
      t.eq(eval_statusline(0, vim.o.statusline).str, "BAR_B")
    end)

    describe("ctx.width", function()
      before_each(function()
        vim.cmd.vnew()
      end)

      it("is set properly", function()
        local bar = Bar("statusline")
        bar:add_item({
          content = function(_, ctx)
            return tostring(ctx.width)
          end,
        })

        nougat.set_statusline(bar)

        vim.go.laststatus = 2
        t.eq(eval_statusline(0, vim.o.statusline).str, tostring(vim.api.nvim_win_get_width(0)))

        vim.go.laststatus = 3
        t.eq(eval_statusline(0, vim.o.statusline).str, tostring(vim.go.columns))
      end)
    end)
  end)

  describe("refresh_statusline", function()
    before_each(function()
      t.spy(vim, "cmd")
    end)

    after_each(function()
      vim.cmd:revert()
    end)

    it("works", function()
      nougat.refresh_statusline()
      t.spy(vim.cmd).was.called_with("redrawstatus")

      nougat.refresh_statusline(true)
      t.spy(vim.cmd).was.called_with("redrawstatus!")
    end)
  end)

  describe("set_tabline", function()
    it("accepts NougatBar", function()
      local bar = Bar("tabline")
      bar:add_item("BAR")

      nougat.set_tabline(bar)

      t.eq(vim.api.nvim_eval_statusline(vim.o.tabline, { winid = 0 }).str, "BAR")
    end)

    it("accepts nougat_bar_selector", function()
      local bar_a = Bar("tabline")
      bar_a:add_item("BAR_A")

      local bar_b = Bar("tabline")
      bar_b:add_item("BAR_B")

      local bar_idx = 1
      local bars = { bar_a, bar_b }

      nougat.set_tabline(function()
        return bars[bar_idx]
      end)

      t.eq(vim.api.nvim_eval_statusline(vim.o.tabline, { winid = 0 }).str, "BAR_A")

      bar_idx = 2
      t.eq(vim.api.nvim_eval_statusline(vim.o.tabline, { winid = 0 }).str, "BAR_B")
    end)

    describe("ctx.width", function()
      before_each(function()
        vim.cmd.vnew()
      end)

      it("is set properly", function()
        local bar = Bar("tabline")
        bar:add_item({
          content = function(_, ctx)
            return tostring(ctx.width)
          end,
        })

        nougat.set_tabline(bar)

        t.eq(eval_tabline(0, vim.o.tabline).str, tostring(vim.go.columns))
      end)
    end)
  end)

  describe("refresh_tabline", function()
    before_each(function()
      t.spy(vim, "cmd")
    end)

    after_each(function()
      vim.cmd:revert()
    end)

    it("works", function()
      nougat.refresh_tabline()
      t.spy(vim.cmd).was.called_with("redrawtabline")
    end)
  end)

  describe("set_winbar", function()
    it("accepts NougatBar", function()
      local bar = Bar("winbar")
      bar:add_item("BAR")

      nougat.set_winbar(bar, { global = true })

      t.eq(eval_winbar(0, vim.o.winbar).str, "BAR")
    end)

    it("accepts nougat_bar_selector", function()
      local bar_a = Bar("winbar")
      bar_a:add_item("BAR_A")

      local bar_b = Bar("winbar")
      bar_b:add_item("BAR_B")

      local bar_idx = 1
      local bars = { bar_a, bar_b }

      nougat.set_winbar(function()
        return bars[bar_idx]
      end, { global = true })

      t.eq(eval_winbar(0, vim.o.winbar).str, "BAR_A")

      bar_idx = 2
      t.eq(eval_winbar(0, vim.o.winbar).str, "BAR_B")
    end)

    it("can set local 'winbar'", function()
      local bar = Bar("winbar")
      bar:add_item("BAR")

      nougat.set_winbar(bar)

      t.eq(vim.api.nvim_eval_statusline(vim.o.winbar, { winid = 0 }).str, "")

      vim.cmd.new()
      vim.wait(0)
      t.eq(vim.api.nvim_eval_statusline(vim.o.winbar, { winid = 0 }).str, "BAR")

      t.eq(vim.api.nvim_eval_statusline(vim.go.winbar, { winid = 0 }).str, "")
    end)

    it("does not set local 'winbar' for popup", function()
      local bar = Bar("winbar")
      bar:add_item("BAR")

      nougat.set_winbar(bar)

      local bufnr = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_open_win(bufnr, true, { relative = "win", row = 0, col = 0, width = 8, height = 4 })
      vim.wait(0)
      t.eq(vim.api.nvim_eval_statusline(vim.o.winbar, { winid = 0 }).str, "")
    end)

    it("can set for filetype", function()
      local bar = Bar("winbar")
      bar:add_item("BAR")

      local bar_a = Bar("winbar")
      bar_a:add_item("BAR_A")

      local bar_b = Bar("winbar")
      bar_b:add_item("BAR_B")

      nougat.set_winbar(bar, { global = true })
      nougat.set_winbar(bar_a, { filetype = "a" })
      nougat.set_winbar(bar_b, { filetype = "b" })

      t.eq(eval_winbar(0, vim.o.winbar).str, "BAR")

      vim.bo.filetype = "a"
      vim.wait(0)
      t.eq(eval_winbar(0, vim.o.winbar).str, "BAR_A")

      vim.bo.filetype = "b"
      vim.wait(0)
      t.eq(eval_winbar(0, vim.o.winbar).str, "BAR_B")
    end)

    it("can set for winid", function()
      local bar = Bar("winbar")
      bar:add_item("BAR")

      nougat.set_winbar(bar, { winid = 0 })

      t.eq(eval_winbar(0, vim.o.winbar).str, "BAR")

      vim.cmd.new()
      t.eq(eval_winbar(0, vim.o.winbar).str, "")
    end)
  end)

  describe("refresh_winbar", function()
    before_each(function()
      t.spy(vim, "cmd")
    end)

    after_each(function()
      vim.cmd:revert()
    end)

    it("works", function()
      nougat.refresh_winbar()
      t.spy(vim.cmd).was.called_with("redrawstatus")

      nougat.refresh_winbar(true)
      t.spy(vim.cmd).was.called_with("redrawstatus!")
    end)
  end)
end)
