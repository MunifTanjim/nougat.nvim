pcall(require, "luacov")

local Item = require("nougat.item")

local t = require("tests.util")

describe("NougatItem", function()
  it("can be initialized", function()
    local item = Item({ content = "" })
    t.type(item.id, "number")
  end)

  describe(":init", function()
    it("is called properly", function()
      local init_params

      local item = Item({
        init = function(...)
          init_params = { ... }
        end,
        content = "",
      })

      t.eq(#init_params, 1)
      t.eq(item, init_params[1])
    end)
  end)

  describe("o.type=code", function()
    it("n", function()
      t.eq(
        Item({
          type = "code",
          content = "n",
          align = "left",
          max_width = 8,
          min_width = 4,
          leading_zero = true,
        }).content,
        "%-04.8n"
      )

      t.eq(
        Item({
          type = "code",
          content = "n",
          align = "right",
          max_width = 8,
          min_width = 4,
          leading_zero = true,
        }).content,
        "%04.8n"
      )
    end)
  end)

  describe("o.type=vim_expr", function()
    it("&option", function()
      t.eq(
        Item({
          type = "vim_expr",
          content = "&filetype",
          align = "left",
          max_width = 8,
          min_width = 4,
        }).content,
        "%-4.8{&filetype}"
      )
    end)

    it("*:variable", function()
      t.eq(
        Item({
          type = "vim_expr",
          content = "g:colors_name",
        }).content,
        "%{g:colors_name}"
      )
    end)

    it(".expand=true", function()
      t.eq(
        Item({
          type = "vim_expr",
          content = "'%4.8{&filetype}'",
          expand = true,
        }).content,
        "%{%'%4.8{&filetype}'%}"
      )
    end)
  end)
end)
