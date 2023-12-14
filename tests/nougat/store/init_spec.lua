pcall(require, "luacov")

local s = require("nougat.store")

local t = require("tests.util")

describe("store", function()
  before_each(function()
    require("nougat.store")._cleanup()
  end)

  describe("Store", function()
    it("works", function()
      local store = s.Store("test:store:Store", {
        a = { x = 1 },
        b = { y = 2 },
      }, {
        clear = function(store)
          store.a.x = 1
          store.b.y = 2
        end,
      })

      t.eq(store.a.x, 1)
      t.eq(store.b.y, 2)

      store.a.x = 11
      store.b.y = 22

      t.eq(store.a.x, 11)
      t.eq(store.b.y, 22)

      store:clear()

      t.eq(store.a.x, 1)
      t.eq(store.b.y, 2)
    end)

    it("has default clear function", function()
      local store = s.Store("test:store:Store", {
        a = { x = 1 },
        c = 3,
      })

      t.eq(store.a.x, 1)
      t.eq(store.c, 3)

      store:clear()

      t.eq(store.a.x, nil)
      t.eq(store.c, nil)
    end)

    it("throws if reserved top-level key exists", function()
      t.match(
        t.error(s.Store, "test:store:Store", { clear = 1 }, { clear = function() end }),
        "found reserved top%-level key: clear"
      )
      t.match(
        t.error(s.Store, "test:store:Store", { name = 1 }, { clear = function() end }),
        "found reserved top%-level key: name"
      )
      t.match(
        t.error(s.Store, "test:store:Store", { type = 1 }, { clear = function() end }),
        "found reserved top%-level key: type"
      )
    end)

    it("throws if trying to set reserved top-level key", function()
      local store = s.Store("test:store:Store", {}, { clear = function() end })

      local err = t.error(function()
        store.name = ""
      end)
      t.match(err, "not allowed to set reserved top%-level key: " .. "name")
    end)

    it("throws if creating same store w/ different value", function()
      local name = tostring(os.time())
      local value = {}
      local config = { clear = function() end }

      local store = s.Store(name, value, config)

      t.ref(s.Store(name, value, config), store)

      local err = t.error(s.Store, name, {}, config)
      t.match(err, "store already created with different value")
    end)
  end)

  describe("BufStore", function()
    local store

    before_each(function()
      store = s.BufStore("test:store:BufStore")
    end)

    it("clears on BufWipeout", function()
      local bufnr = vim.api.nvim_create_buf(false, true)
      store[bufnr].a = 1

      t.eq(store[bufnr].a, 1)

      vim.api.nvim_buf_delete(bufnr, { force = true })

      vim.wait(0)

      t.eq(store[bufnr].a, nil)
    end)

    it("supports lazy initial value", function()
      local bufnr = vim.api.nvim_get_current_buf()

      local value = {}

      local store = s.BufStore("test:store:initial_value", value)

      t.eq(store[bufnr].a, nil)

      value.a = 1

      t.eq(store[bufnr].a, 1)
    end)

    it("throws if creating same store w/ different value", function()
      local name = tostring(os.time())
      local value = {}

      local store = s.BufStore(name, value)

      t.ref(s.BufStore(name, value), store)

      local err = t.error(function()
        return s.BufStore(name, {})
      end)
      t.match(err, "store already created with different value")
    end)
  end)

  describe("WinStore", function()
    local store

    before_each(function()
      store = s.WinStore("test:store:WinStore")
    end)

    it("clears on BufWipeout", function()
      vim.cmd.vnew()

      local winid = vim.api.nvim_get_current_win()

      store[winid].a = 1

      t.eq(store[winid].a, 1)

      vim.cmd.quit()

      vim.wait(0)

      t.eq(store[winid].a, nil)
    end)
  end)

  describe("TabStore", function()
    local store

    before_each(function()
      store = s.TabStore("test:store:TabStore")
    end)

    it("clears on TabClose", function()
      vim.cmd.tabnew()

      local tabid = vim.api.nvim_get_current_tabpage()

      store[tabid].a = 1

      t.eq(store[tabid].a, 1)

      vim.cmd.tabclose()

      vim.wait(0)

      t.eq(store[tabid].a, nil)
    end)
  end)
end)
