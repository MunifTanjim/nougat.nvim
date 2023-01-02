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

function mod.bench()
  local redraw_count = 10000

  local current_bar_generate = Bar.generate
  Bar.generate = bar_generate

  for _, bar_type in ipairs({ "statusline", "tabline", "winbar" }) do
    local value = vim.o[bar_type]
    if #value > 0 then
      local bar = {}

      local id = tonumber(string.match(value, "nougat_core_generator_fn%((.+)%)"))

      for _ = 1, redraw_count do
        local start_time = vim.loop.hrtime()

        vim.g.statusline_winid = vim.api.nvim_get_current_win()
        _G.nougat_core_generator_fn(id)
        vim.g.statusline_winid = nil

        local end_time = vim.loop.hrtime()

        table.insert(bar, end_time - start_time)
      end

      table.sort(bar)

      local min_time_ms = bar[1] / 1e6
      local max_time_ms = bar[redraw_count] / 1e6

      local mid_idx = math.ceil(redraw_count / 2)
      local med_time_ms = (redraw_count % 2 == 0 and (bar[mid_idx] + bar[mid_idx + 1]) / 2 or bar[mid_idx]) / 1e6

      local total_time_ns = 0
      for _, time_ns in ipairs(bar) do
        total_time_ns = total_time_ns + time_ns
      end
      local total_time_ms = total_time_ns / 1e6

      --luacheck: push no max line length
      print(
        string.format(
          "bench(%10s: %2s) redraw(total: %5s per_ms: %9.6f) time(total: %12.6f min: %8.6f med: %8.6f max: %8.6f per_redraw: %8.6f)",
          bar_type,
          id,
          redraw_count,
          redraw_count / total_time_ms,
          total_time_ms,
          min_time_ms,
          med_time_ms,
          max_time_ms,
          total_time_ms / redraw_count
        )
      )
      --luacheck: pop
    end
  end

  Bar.generate = current_bar_generate
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
      table.sort(bar)

      local redraw_count = #bar

      local min_time_ms = bar[1] / 1e6
      local max_time_ms = bar[redraw_count] / 1e6

      local mid_idx = math.ceil(redraw_count / 2)
      local med_time_ms = (redraw_count % 2 == 0 and (bar[mid_idx] + bar[mid_idx + 1]) / 2 or bar[mid_idx]) / 1e6

      local total_time_ns = 0
      for _, time_ns in ipairs(bar) do
        total_time_ns = total_time_ns + time_ns
      end
      local total_time_ms = total_time_ns / 1e6

      --luacheck: push no max line length
      print(
        string.format(
          "%10s(id: %2s) redraw(total: %5s per_ms: %9.6f) time(total: %12.6f min: %8.6f med: %8.6f max: %8.6f per_redraw: %8.6f)",
          bar_type,
          id,
          redraw_count,
          redraw_count / total_time_ms,
          total_time_ms,
          min_time_ms,
          med_time_ms,
          max_time_ms,
          total_time_ms / redraw_count
        )
      )
      --luacheck: pop
    end
  end
end

return mod
