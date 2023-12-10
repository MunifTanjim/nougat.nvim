pcall(require, "luacov")

local cache = require("nougat.cache")

local t = require("tests.util")

describe("cache", function()
  before_each(function()
    require("nougat.util.store").clear_all()
  end)

  it("supports lazy initial_value", function()
    local bufnr = vim.api.nvim_get_current_buf()

    local initial_value = {}

    local store = cache.create_store("buf", "test:cache:initial_value", initial_value)

    t.eq(store[bufnr].a, nil)

    initial_value.a = 1

    t.eq(store[bufnr].a, 1)
  end)

  it("throws if creating same store w/ different initial_value", function()
    local name = tostring(os.time())
    local initial_value = {}

    local store = cache.create_store("buf", name, initial_value)

    t.ref(cache.create_store("buf", name, initial_value), store)

    local err = t.error(function()
      return cache.create_store("buf", name, {})
    end)
    t.match(err, "cache store already created with different initial_value")
  end)

  describe("get", function()
    it("works", function()
      local bufnr = vim.api.nvim_get_current_buf()

      local name = "test:cache:get"
      local store = cache.create_store("buf", name)
      store[bufnr].a = 1

      t.eq(cache.get("buf", name, bufnr).a, 1)
    end)
  end)

  describe("type=buf", function()
    local store

    before_each(function()
      store = cache.create_store("buf", "test:cache:type=buf")
    end)

    it("clears on BufWipeout", function()
      local bufnr = vim.api.nvim_create_buf(false, true)
      store[bufnr].a = 1

      t.eq(store[bufnr].a, 1)

      vim.api.nvim_buf_delete(bufnr, { force = true })

      vim.wait(0)

      t.eq(store[bufnr].a, nil)
    end)
  end)

  describe("type=win", function()
    local store

    before_each(function()
      store = cache.create_store("win", "test:cache:type=win")
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

  describe("type=tab", function()
    local store

    before_each(function()
      store = cache.create_store("tab", "test:cache:type=tab")
    end)

    it("clears on BufWipeout", function()
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
