pcall(require, "luacov")

local profiler = require("nougat.profiler")

local t = require("tests.util")

describe("nougat.profiler", function()
  before_each(function()
    require("nougat.util.store").clear_all()

    vim.go.laststatus = 2
    vim.go.statusline = ""
    vim.go.tabline = ""
    vim.go.winbar = ""
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      vim.wo[winid].statusline = ""
      vim.wo[winid].winbar = ""
    end

    package.loaded["examples.slanty"] = nil
    require("examples.slanty")
  end)

  describe("bench", function()
    it("works", function()
      local print_stub = t.stub(_G, "print")

      vim.g._nougat_profiler_bench_count = 10
      profiler.bench()
      vim.g._nougat_profiler_bench_count = nil

      local calls = print_stub.calls
      print_stub:revert()

      for call_idx in ipairs(print_stub.calls) do
        local lines = vim.split(calls[call_idx].refs[1], "\n")
        local bar_type = t.match(
          lines[1],
          "bench%(%s*(%S-):%s+%d+%) redraw%(total:%s+%d+ per_ms:%s+[%d.]+%) time%(total:%s+[%d.]+ min:%s+[%d.]+ med:%s+[%d.]+ max:%s+[%d.]+ per_redraw:%s+[%d.]+%)"
        )
        t.eq(({ statusline = true, tabline = true, winbar = true })[bar_type], true)
        for idx = 2, #lines do
          t.match(
            lines[idx],
            "  bench%(%s*item:%s+%d+%) redraw%(%s+per_ms:%s+[%d.]+%) time%(total:%s+[%d.]+ min:%s+[%d.]+ med:%s+[%d.]+ max:%s+[%d.]+ per_redraw:%s+[%d.]+%)"
          )
        end
      end
    end)
  end)

  describe("profile", function()
    it("works", function()
      profiler.start()

      require("nougat").refresh_statusline(true)
      require("nougat").refresh_tabline()
      require("nougat").refresh_winbar(true)

      local print_stub = t.stub(_G, "print")

      profiler.stop()

      local calls = print_stub.calls
      print_stub:revert()

      for call_idx in ipairs(print_stub.calls) do
        local lines = vim.split(calls[call_idx].refs[1], "\n")
        local bar_type = t.match(
          lines[1],
          "profile%(%s*(%S-):%s+%d+%) redraw%(total:%s+%d+ per_ms:%s+[%d.]+%) time%(total:%s+[%d.]+ min:%s+[%d.]+ med:%s+[%d.]+ max:%s+[%d.]+ per_redraw:%s+[%d.]+%)"
        )
        t.eq(({ statusline = true, tabline = true, winbar = true })[bar_type], true)
        for idx = 2, #lines do
          t.match(
            lines[idx],
            "  profile%(%s*item:%s+%d+%) redraw%(%s+per_ms:%s+[%d.]+%) time%(total:%s+[%d.]+ min:%s+[%d.]+ med:%s+[%d.]+ max:%s+[%d.]+ per_redraw:%s+[%d.]+%)"
          )
        end
      end
    end)
  end)

  describe("inspect", function()
    it("bar", function()
      local print_stub = t.stub(_G, "print")

      vim.g._nougat_profiler_bench_count = 1
      profiler.bench()
      vim.g._nougat_profiler_bench_count = nil

      local calls = print_stub.calls
      print_stub:revert()

      local bar_type, bar_id = t.match(vim.split(calls[1].refs[1], "\n")[1], "bench%(%s*(%S-):%s+(%d+)%)")
      bar_id = tonumber(bar_id)
      local bar = profiler.inspect("bar", bar_id)
      t.type(bar, "table")
      t.eq(bar.id, bar_id)
      t.eq(bar.type, bar_type)
    end)

    it("item", function()
      local print_stub = t.stub(_G, "print")

      vim.g._nougat_profiler_bench_count = 1
      profiler.bench()
      vim.g._nougat_profiler_bench_count = nil

      local calls = print_stub.calls
      print_stub:revert()

      local item_id = t.match(vim.split(calls[1].refs[1], "\n")[2], "  bench%(%s*item:%s+(%d+)%)")
      item_id = tonumber(item_id)
      local item = profiler.inspect("item", item_id)
      t.type(item, "table")
      t.eq(item.id, item_id)
    end)

    it("throws if unknown type", function()
      local err = t.error(profiler.inspect, "unknown", 42)
      t.match(err, "invalid type: unknown")
    end)

    it("throws if missing id", function()
      local err = t.error(profiler.inspect, "bar")
      t.match(err, "missing id")
    end)
  end)
end)
