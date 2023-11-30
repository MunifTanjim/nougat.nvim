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

  describe("string content", function()
    it("works", function()
      t.eq(Item({ content = "Lua" }).content, "Lua")
    end)
  end)

  describe("table content", function()
    it("string elements", function()
      local item = Item({
        content = { "L", "u", "a" },
      })

      t.eq(item.content.len, 3)
      t.type(item.content.next, "function")
    end)

    it("item elements", function()
      local item = Item({
        content = {
          Item({ content = "L" }),
          Item({ content = "u" }),
          Item({ content = "a" }),
        },
      })

      t.eq(item.content.len, 3)
      t.type(item.content.next, "function")
    end)
  end)

  describe("o.on_click", function()
    it("fn content", function()
      local spy = t.spy()

      local context = {}

      local item = Item({
        content = function()
          return "Lua"
        end,
        on_click = function(id, click_count, mouse_button, modifiers, ctx)
          spy(id, click_count, mouse_button, modifiers)
          t.assert_ctx(ctx)
          t.ref(ctx.ctx, context)
        end,
        context = context,
      })

      t.type(item.content, "function")

      local ctx = t.make_ctx(0, { ctx = context })

      local click_fn, fn_id = t.get_click_fn(item:content(ctx), "Lua")
      click_fn(fn_id, 1, "l", "s")

      t.spy(spy).was.called_with(fn_id, 1, "l", "s")

      local n_click_fn, n_fn_id = t.get_click_fn(item:content(ctx), "Lua")
      t.ref(n_click_fn, click_fn)
      t.eq(n_fn_id, fn_id)

      n_click_fn(fn_id, 1, "l", "s")

      t.spy(spy).was.called(2)
    end)

    it("string content", function()
      local fn_id, click_fn
      local spy = t.spy()

      local item
      item = Item({
        content = "Lua",
        on_click = function(id, click_count, mouse_button, modifiers, ctx)
          spy(id, click_count, mouse_button, modifiers)
          t.assert_ctx(ctx)
          t.ref(ctx.ctx, item)
        end,
      })

      click_fn, fn_id = t.get_click_fn(item.content, "Lua")
      click_fn(fn_id, 1, "l", "s")

      t.spy(spy).was.called_with(fn_id, 1, "l", "s")
    end)
  end)

  describe("o.cache", function()
    it("throws if missing both .scope and .store", function()
      local err = t.error(function()
        Item({
          content = function()
            return "Lua"
          end,
          cache = {},
        })
      end)
      t.match(err, "one of cache.scope or cache.store is required")
    end)

    it("creates store with .scope", function()
      local store
      local item = Item({
        content = function()
          return "Lua"
        end,
        cache = {
          scope = "buf",
          get = function(cstore, ctx)
            store = cstore
            return store[ctx.bufnr]
          end,
        },
      })

      local ctx = t.make_ctx(0, nil)
      local cache = item:cache(ctx)

      t.type(store, "table")
      t.ref(cache, store[ctx.bufnr])
    end)

    it("sets default cache getter for .scope", function()
      local store = require("nougat.cache").create_store("win", "tests.item.default_cache_getter")

      local item = Item({
        content = function()
          return "Lua"
        end,
        cache = {
          scope = "win",
          store = store,
        },
      })

      local ctx = t.make_ctx(0, { breakpoint = 0 })

      local cache = item:cache(ctx)

      t.ref(cache, store[ctx.winid][ctx.breakpoint])
    end)

    describe(".clear", function()
      local function create_item(clear)
        local content_spy = t.spy()
        local item = Item({
          content = function(_, ctx)
            content_spy()
            return tostring(ctx.winid)
          end,
          cache = {
            scope = "buf",
            clear = clear,
          },
        })
        return item, content_spy
      end

      before_each(function()
        require("nougat.util.store").clear_all()
      end)

      it("event", function()
        local event = "BufModifiedSet"

        local item, content_spy = create_item(event)
        local ctx = t.make_ctx(0, { breakpoint = 0 })

        local content = item:content(ctx)

        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(1)

        vim.api.nvim_exec_autocmds("BufModifiedSet", {
          buffer = ctx.bufnr,
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(2)
      end)

      it("event[]", function()
        local event = { "BufModifiedSet", "BufWinLeave" }

        local item, content_spy = create_item(event)
        local ctx = t.make_ctx(0, { breakpoint = 0 })

        local content = item:content(ctx)

        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(1)

        vim.api.nvim_exec_autocmds("BufModifiedSet", {
          buffer = ctx.bufnr,
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(2)

        vim.api.nvim_exec_autocmds("BufWinLeave", {
          buffer = ctx.bufnr,
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(3)
      end)

      it("{event,get_id}", function()
        local event = {
          "User NougatItemTest",
          function(info)
            return info.data.bufnr
          end,
        }

        local item, content_spy = create_item(event)
        local ctx = t.make_ctx(0, { breakpoint = 0 })

        local content = item:content(ctx)

        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(1)

        vim.api.nvim_exec_autocmds("User", {
          pattern = vim.split(event[1], " ")[2],
          data = { bufnr = ctx.bufnr },
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(2)
      end)

      it("{event[],get_id}", function()
        local event = {
          { "User NougatItemTestA", "User NougatItemTestB" },
          function(info)
            return info.data.bufnr
          end,
        }

        local item, content_spy = create_item(event)
        local ctx = t.make_ctx(0, { breakpoint = 0 })

        local content = item:content(ctx)

        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(1)

        vim.api.nvim_exec_autocmds("User", {
          pattern = vim.split(event[1][1], " ")[2],
          data = { bufnr = ctx.bufnr },
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(2)

        vim.api.nvim_exec_autocmds("User", {
          pattern = vim.split(event[1][2], " ")[2],
          data = { bufnr = ctx.bufnr },
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(3)
      end)

      it("(event|event[]|{event,get_id}|{event[],get_id})[]", function()
        local event = {
          "BufModifiedSet",
          { "BufWinEnter", "BufWinLeave" },
          {
            "User NougatItemTestA",
            function(info)
              return info.data.A
            end,
          },
          {
            { "User NougatItemTestB1", "User NougatItemTestB2" },
            function(info)
              return info.data.B
            end,
          },
        }

        local item, content_spy = create_item(event)
        local ctx = t.make_ctx(0, { breakpoint = 0 })

        local content = item:content(ctx)

        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(1)

        vim.api.nvim_exec_autocmds(event[1], {
          buffer = ctx.bufnr,
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(2)

        vim.api.nvim_exec_autocmds(event[2][1], {
          buffer = ctx.bufnr,
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(3)

        vim.api.nvim_exec_autocmds(event[2][2], {
          buffer = ctx.bufnr,
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(4)

        vim.api.nvim_exec_autocmds("User", {
          pattern = vim.split(event[3][1], " ")[2],
          data = { A = ctx.bufnr },
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(5)

        vim.api.nvim_exec_autocmds("User", {
          pattern = vim.split(event[4][1][1], " ")[2],
          data = { B = ctx.bufnr },
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(6)

        vim.api.nvim_exec_autocmds("User", {
          pattern = vim.split(event[4][1][2], " ")[2],
          data = { B = ctx.bufnr },
        })

        t.eq(item:content(ctx), content)
        t.eq(item:content(ctx), content)
        t.spy(content_spy).was.called(7)
      end)
    end)
  end)
end)
