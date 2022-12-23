local mod = {}

local result = {
  statusline = {},
  tabline = {},
  winbar = {},
}

local Bar = require("nougat.bar")
local bar_generate = Bar.generate

local function bar_generate_profiler(bar, ctx)
  local start_time = vim.loop.hrtime()

  local ret = bar_generate(bar, ctx)

  local end_time = vim.loop.hrtime()

  if not result[bar.type][bar.id] then
    result[bar.type][bar.id] = {}
  end

  table.insert(result[bar.type][bar.id], end_time - start_time)

  return ret
end

function mod.start()
  Bar.generate = bar_generate_profiler
  result.statusline = {}
  result.tabline = {}
  result.winbar = {}
end

function mod.stop()
  Bar.generate = bar_generate
end

function mod.result()
  for _, bar_type in ipairs({ "statusline", "tabline", "winbar" }) do
    for id, bar in pairs(result[bar_type]) do
      local redraw = #bar
      local total_time_ns = 0
      for _, time_ns in ipairs(bar) do
        total_time_ns = total_time_ns + time_ns
      end
      local total_time_ms = total_time_ns / 1e6

      print(
        string.format(
          "%s(id: %2s) redraw(total: %5s per_ms: %9.6f) time(total: %12.6f per_redraw: %8.6f)",
          bar_type,
          id,
          redraw,
          redraw / total_time_ms,
          total_time_ms,
          total_time_ms / redraw
        )
      )
    end
  end
end

return mod
