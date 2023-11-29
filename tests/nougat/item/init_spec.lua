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

  describe("o.type=lua_expr", function()
    describe("function", function()
      local function assert_context(context, ctx)
        t.type(context.bufnr, "number")
        t.type(context.tabid, "number")
        t.type(context.winid, "number")
        t.type(context.is_focused, "boolean")
        t.eq(context.ctx, ctx)
      end

      it("w/o context", function()
        local fn_params

        local item = Item({
          type = "lua_expr",
          align = "left",
          max_width = 8,
          min_width = 4,
          content = function(...)
            fn_params = { ... }
            return "Lua"
          end,
        })

        local fn_name, fn_id = t.match(item.content, "%%-4%.8{v:lua%.(nougat_.+)%((.+)%)}")

        t.eq(_G[fn_name](tonumber(fn_id)), "Lua")

        assert_context(fn_params[1], item)
      end)

      it("w/ context", function()
        local fn_params

        local item_context = {}
        local item = Item({
          type = "lua_expr",
          align = "left",
          max_width = 8,
          min_width = 4,
          content = function(...)
            fn_params = { ... }
            return "Lua"
          end,
          context = item_context,
        })

        local fn_name, fn_id = t.match(item.content, "%%-4%.8{v:lua%.(nougat_.+)%((.+)%)}")

        t.eq(_G[fn_name](tonumber(fn_id)), "Lua")

        assert_context(fn_params[1], item_context)
      end)

      it(".expand=true", function()
        local item = Item({
          type = "lua_expr",
          content = function() end,
          expand = true,
        })

        t.match(item.content, "%%{%%v:lua%.nougat_.+%(.+%)%%}")
      end)
    end)

    it("number", function()
      t.eq(
        Item({
          type = "lua_expr",
          content = 42,
        }).content,
        "%{luaeval('42')}"
      )
    end)

    it("string", function()
      t.eq(
        Item({
          type = "lua_expr",
          content = "'Lua'",
        }).content,
        "%{luaeval('''Lua''')}"
      )
    end)
  end)

  describe("o.type=literal", function()
    describe("w/ opts", function()
      it("boolean", function()
        t.eq(
          Item({
            type = "literal",
            content = true,
            align = "left",
            max_width = 5,
          }).content,
          "%-.5{'true'}"
        )
      end)

      it("number", function()
        t.eq(
          Item({
            type = "literal",
            content = 7,
            leading_zero = true,
            min_width = 3,
          }).content,
          "%03{'7'}"
        )
      end)

      it("string", function()
        t.eq(
          Item({
            type = "literal",
            content = "'%string%'",
            align = "right",
          }).content,
          "%{'''%string%'''}"
        )
      end)
    end)

    describe("w/o opts", function()
      it("boolean", function()
        t.eq(
          Item({
            type = "literal",
            content = true,
          }).content,
          "true"
        )
      end)

      it("number", function()
        t.eq(
          Item({
            type = "literal",
            content = 42,
          }).content,
          "42"
        )
      end)

      it("string", function()
        t.eq(
          Item({
            type = "literal",
            content = "'%string%'",
          }).content,
          "'%%string%%'"
        )
      end)
    end)
  end)

  describe("o.type=tab_label", function()
    it("label", function()
      t.eq(
        Item({
          type = "tab_label",
          content = "label",
          tabnr = 7,
        }).content,
        "%7Tlabel%T"
      )
    end)

    it("close label", function()
      t.eq(
        Item({
          type = "tab_label",
          content = "x",
          tabnr = 7,
          close = true,
        }).content,
        "%7Xx%X"
      )
    end)

    it("close current label", function()
      t.eq(
        Item({
          type = "tab_label",
          content = "x",
          tabnr = 0,
          close = true,
        }).content,
        "%999Xx%X"
      )
    end)

    it("w/o opts", function()
      t.eq(
        Item({
          type = "tab_label",
          content = "x",
        }).content,
        Item({
          type = "literal",
          content = "x",
          align = "right",
        }).content
      )
    end)
  end)

  describe("fn content", function()
    it("works", function()
      local context = {}
      local item

      local function content(self, ctx)
        t.ref(self, item)
        t.ref(ctx, context)
        return "Lua"
      end

      item = Item({ content = content })

      t.eq(item.content, content)
      t.eq(item:content(context), "Lua")
    end)
  end)
          return "Lua"
        end,
      })

      t.type(item.content, "function")

      item:content(context)
    end)
  end)
end)
