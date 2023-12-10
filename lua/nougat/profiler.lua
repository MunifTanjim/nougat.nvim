local Bar = require("nougat.bar")

local bar_by_id = {}

local mod = {}

local current_bar_type, current_bar_id

local function instrument_bar_generate(result_store)
  local bar_generate = Bar.generate
  Bar.generate = function(bar, ctx)
    current_bar_type = bar.type
    current_bar_id = bar.id

    if not bar_by_id[current_bar_id] then
      bar_by_id[current_bar_id] = bar
    end

    if not result_store[current_bar_type][current_bar_id] then
      result_store[current_bar_type][current_bar_id] = {}
    end
    local store = result_store[current_bar_type][current_bar_id]

    local start_time = vim.loop.hrtime()

    local ret = bar_generate(bar, ctx)

    local end_time = vim.loop.hrtime()

    table.insert(store, end_time - start_time)

    return ret
  end

  return function()
    Bar.generate = bar_generate
  end
end

local function instrument_prepare(name, result_store)
  local fn_name = "__" .. name

  local prepare = Bar[fn_name]

  Bar[fn_name] = function(items, ctx)
    if not result_store[current_bar_type][current_bar_id].item then
      result_store[current_bar_type][current_bar_id].item = {}
    end
    local store = result_store[current_bar_type][current_bar_id].item

    local next = items.next
    local start_time, item_id
    function items:next()
      if start_time and item_id then
        if not store[item_id] then
          store[item_id] = {}
        end
        table.insert(store[item_id], vim.loop.hrtime() - start_time)
      end
      start_time = vim.loop.hrtime()
      local item = next(self)
      item_id = item and item.id
      return item
    end
    prepare(items, ctx)
    items.next = next
  end

  return function()
    Bar[fn_name] = prepare
  end
end

---@param times number[]
local function crunch_result(times)
  table.sort(times)

  local redraw_count = #times

  local min_time_ms = times[1] / 1e6
  local max_time_ms = times[redraw_count] / 1e6

  local mid_idx = math.ceil(redraw_count / 2)
  local med_time_ms = (redraw_count % 2 == 0 and (times[mid_idx] + times[mid_idx + 1]) / 2 or times[mid_idx]) / 1e6

  local total_time_ns = 0
  for _, time_ns in ipairs(times) do
    total_time_ns = total_time_ns + time_ns
  end
  local total_time_ms = total_time_ns / 1e6

  return {
    min_time_ms = min_time_ms,
    med_time_ms = med_time_ms,
    max_time_ms = max_time_ms,
    redraw_count = redraw_count,
    total_time_ms = total_time_ms,
  }
end

local function display_result(type, result, bar_type, bar_id)
  --luacheck: push no max line length
  local data = crunch_result(result[bar_type][bar_id])
  print(
    string.format(
      "%s(%10s: %2s) redraw(total: %5s per_ms: %12.6f) time(total: %12.6f min: %8.6f med: %8.6f max: %8.6f per_redraw: %8.6f)",
      type,
      bar_type,
      bar_id,
      data.redraw_count,
      data.redraw_count / data.total_time_ms,
      data.total_time_ms,
      data.min_time_ms,
      data.med_time_ms,
      data.max_time_ms,
      data.total_time_ms / data.redraw_count
    )
  )
  for item_id, item_result in pairs(result[bar_type][bar_id].item) do
    local item_data = crunch_result(item_result)
    print(
      string.format(
        "  %s(%8s: %2s) redraw(%12s per_ms: %12.6f) time(total: %12.6f min: %8.6f med: %8.6f max: %8.6f per_redraw: %8.6f)",
        type,
        "item",
        item_id,
        " ",
        item_data.redraw_count / item_data.total_time_ms,
        item_data.total_time_ms,
        item_data.min_time_ms,
        item_data.med_time_ms,
        item_data.max_time_ms,
        item_data.total_time_ms / item_data.redraw_count
      )
    )
  end
  --luacheck: pop
end

local bench_result = {
  statusline = {},
  tabline = {},
  winbar = {},
}

function mod.bench()
  local redraw_count = 10000

  for _, bar_type in ipairs({ "statusline", "tabline", "winbar" }) do
    bench_result[bar_type] = {}

    current_bar_type = bar_type

    local restore_bar_generate = instrument_bar_generate(bench_result)

    local value = vim.o[bar_type]
    if #value > 0 then
      local id = tonumber(string.match(value, "nougat_core_generator_fn%((.+)%)"))
      current_bar_id = id

      if not bench_result[current_bar_type][current_bar_id] then
        bench_result[current_bar_type][current_bar_id] = {}
      end

      local restore_prepare_parts = instrument_prepare("prepare_parts", bench_result)
      local restore_prepare_slots = instrument_prepare("prepare_slots", bench_result)

      for _ = 1, redraw_count do
        vim.g.statusline_winid = vim.api.nvim_get_current_win()
        _G.nougat_core_generator_fn(id)
        vim.g.statusline_winid = nil
      end

      restore_prepare_parts()
      restore_prepare_slots()

      display_result("bench", bench_result, current_bar_type, current_bar_id)
    end

    restore_bar_generate()
  end
end

local profile_result = {
  statusline = {},
  tabline = {},
  winbar = {},
  _resets = {},
}

function mod.start()
  profile_result.statusline = {}
  profile_result.tabline = {}
  profile_result.winbar = {}

  table.insert(profile_result._resets, instrument_bar_generate(profile_result))
  table.insert(profile_result._resets, instrument_prepare("prepare_parts", profile_result))
  table.insert(profile_result._resets, instrument_prepare("prepare_slots", profile_result))
end

function mod.stop()
  for _, reset in ipairs(profile_result._resets) do
    reset()
  end
  profile_result._resets = {}

  for _, bar_type in ipairs({ "statusline", "tabline", "winbar" }) do
    for bar_id in pairs(profile_result[bar_type]) do
      display_result("profile", profile_result, bar_type, bar_id)
    end
  end
end

local get_object = {
  bar = function(id)
    return bar_by_id[id]
  end,
  item = function(id)
    for _, bar in pairs(bar_by_id) do
      local item = bar._items:next()
      while item do
        if item.id == id then
          return item
        end
        item = bar._items:next()
      end
    end
  end,
}

---@param type 'bar'|'item'
---@param id integer
---@return nil|NougatBar|NougatItem
function mod.inspect(type, id)
  if not get_object[type] then
    error("invalid type: " .. type)
  end
  if not id then
    error("missing id")
  end
  return get_object[type](id)
end

return mod
