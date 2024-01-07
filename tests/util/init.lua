local spy = require("luassert.spy")
local stub = require("luassert.stub")

local mod = {}

function mod.eq(...)
  return assert.are.same(...)
end

function mod.neq(...)
  return assert["not"].are.same(...)
end

function mod.match(str, pattern)
  local matches = { string.match(str, pattern) }
  assert(
    #matches > 0,
    table.concat({
      "",
      "Input:",
      "  " .. str,
      "Found no match for:",
      "  " .. pattern,
    }, "\n")
  )
  return unpack(matches)
end

function mod.ref(a, b)
  return assert(a == b, "references are not same")
end

-- Usage:
-- - `t.spy()` : spy
-- - `t.spy(function() end)` : spy w/ implementation
-- - `t.spy(tbl, key)` : spy on `tbl[key]`
-- - `t.spy(spy)` : assert spy
function mod.spy(...)
  local args = { ... }
  if #args == 0 then
    return spy.new(function() end)
  elseif #args == 1 then
    if type(args[1]) == "function" then
      return spy.new(args[1])
    elseif spy.is_spy(args[1]) then
      return assert.spy(args[1])
    end
  elseif #args == 2 then
    return spy.on(args[1], args[2])
  end
end

-- Usage:
-- - `t.stub(tbl, key)` : stub `tbl[key]`
-- - `t.stub(tbl, key, ...return_vals)` : stub `tbl[key]` w/ return values
-- - `t.stub(tbl, key, function() end)` : stub `tbl[key]` w/ implementation
function mod.stub(...)
  local args = { ... }
  return stub.new(unpack(args))
end

function mod.type(v, t)
  return mod.eq(type(v), t)
end

function mod.error(fn, ...)
  local ok, err = pcall(fn, ...)
  mod.eq(ok, false)
  return err
end

---@param tbl table
---@param keys string[]
function mod.tbl_pick(tbl, keys)
  if not keys or #keys == 0 then
    return tbl
  end

  local new_tbl = {}
  for _, key in ipairs(keys) do
    new_tbl[key] = tbl[key]
  end
  return new_tbl
end

---@param tbl table
---@param keys string[]
function mod.tbl_omit(tbl, keys)
  if not keys or #keys == 0 then
    return tbl
  end

  local new_tbl = vim.deepcopy(tbl)
  for _, key in ipairs(keys) do
    rawset(new_tbl, key, nil)
  end
  return new_tbl
end

---@param keys string
---@param mode? string
function mod.feedkeys(keys, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), mode or "", false)
end

function mod.make_ctx(winid, extra)
  if not winid or winid == 0 then
    winid = vim.api.nvim_get_current_win()
  end

  return vim.tbl_extend("keep", {
    bufnr = vim.api.nvim_win_get_buf(winid),
    winid = winid,
    tabid = vim.api.nvim_win_get_tabpage(winid),
    is_focused = winid == vim.api.nvim_get_current_win(),
  }, extra or {})
end

function mod.assert_ctx(ctx)
  mod.type(ctx.bufnr, "number")
  mod.type(ctx.tabid, "number")
  mod.type(ctx.winid, "number")
  mod.type(ctx.is_focused, "boolean")
end

function mod.get_click_fn(content, label)
  local id, name = mod.match(content, "%%(%d+)@v:lua%.(nougat_[^@]+)@" .. label .. "%%T")
  id = tonumber(id)
  return _G[name], id
end

---@param fn fun():boolean
---@param timeout integer
function mod.wait_for(fn, timeout)
  vim.wait(timeout, fn, math.floor(timeout / 5))
  mod.eq(fn(), true)
end

function mod.make_wins()
  ---@class _nougat.t.wins
  ---@field [integer] { bufnr: integer, winid: integer }
  local wins = {}

  function wins.init()
    local item = {
      bufnr = vim.api.nvim_get_current_buf(),
      winid = vim.api.nvim_get_current_win(),
    }
    table.insert(wins, item)
    return wins
  end

  function wins.new()
    vim.cmd.new()
    local item = {
      bufnr = vim.api.nvim_get_current_buf(),
      winid = vim.api.nvim_get_current_win(),
    }
    table.insert(wins, item)
    return item
  end

  function wins.cleanup()
    for idx, item in ipairs(wins) do
      if vim.api.nvim_win_is_valid(item.winid) then
        vim.api.nvim_win_close(item.winid, true)
      end
      if vim.api.nvim_buf_is_valid(item.bufnr) then
        vim.api.nvim_buf_delete(item.bufnr, { force = true })
      end
      wins[idx] = nil
    end
  end

  return wins
end

function mod.make_tabs()
  ---@class _nougat.t.tabs
  ---@field [integer] { bufnr: integer, winid: integer, tabid: integer, wins: _nougat.t.wins }
  local tabs = {}

  function tabs.init()
    local item = {
      bufnr = vim.api.nvim_get_current_buf(),
      winid = vim.api.nvim_get_current_win(),
      tabid = vim.api.nvim_get_current_tabpage(),
      wins = mod.make_wins().init(),
    }
    table.insert(tabs, item)
    return tabs
  end

  function tabs.add()
    vim.cmd.tabnew()
    local item = {
      bufnr = vim.api.nvim_get_current_buf(),
      winid = vim.api.nvim_get_current_win(),
      tabid = vim.api.nvim_get_current_tabpage(),
      wins = mod.make_wins().init(),
    }
    table.insert(tabs, item)
    return item
  end

  function tabs.cleanup()
    if #tabs > 1 then
      vim.cmd.tabonly({ bang = true })
    end
    if #vim.api.nvim_tabpage_list_wins(0) > 1 then
      vim.cmd.only()
    end

    for idx, item in ipairs(tabs) do
      vim.api.nvim_buf_delete(item.bufnr, { force = true })
      tabs[idx] = nil
    end
  end

  return tabs
end

return mod
