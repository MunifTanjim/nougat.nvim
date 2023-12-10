pcall(require, "luacov")

local buf_cache = require("nougat.cache.buffer")

local t = require("tests.util")

describe("cache.buffer", function()
  before_each(function()
    require("nougat.util.store").clear_all()
  end)

  describe("enable", function()
    it("throws if key is unknown", function()
      t.error(buf_cache.enable, tostring(os.time()))
    end)
  end)

  describe("on", function()
    it("throws if event is unknown", function()
      local err = t.error(buf_cache.on, tostring(os.time()), function() end)
      t.match(err, "unknown event")
    end)
  end)
end)
