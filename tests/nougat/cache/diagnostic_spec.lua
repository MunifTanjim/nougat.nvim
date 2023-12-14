pcall(require, "luacov")

local diag_cache = require("nougat.cache.diagnostic")

local t = require("tests.util")

describe("cache.diagnostic", function()
  local ns

  before_each(function()
    require("nougat.store")._clear()

    ns = vim.api.nvim_create_namespace("test:cache.diagnostic")
  end)

  it("ignores non-normal buffer", function()
    diag_cache.enable()

    local normal_bufnr = vim.api.nvim_get_current_buf()

    vim.diagnostic.set(ns, normal_bufnr, {
      { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.ERROR },
    })
    vim.wait(0)

    local scratch_bufnr = vim.api.nvim_create_buf(false, true)

    vim.diagnostic.set(ns, scratch_bufnr, {
      { lnum = 0, col = 0, message = "", severity = vim.diagnostic.severity.ERROR },
    })
    vim.wait(0)

    t.eq(diag_cache.store[scratch_bufnr][diag_cache.severity.COMBINED], 0)
  end)
end)
