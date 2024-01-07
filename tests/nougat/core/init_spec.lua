pcall(require, "luacov")

local core = require("nougat.core")
local t = require("tests.util")

describe("core", function()
  local ctx

  before_each(function()
    require("nougat.store")._clear()

    ctx = t.make_ctx(0)
  end)

  describe("_G.nougat_core_generator_fn", function()
    it("gracefully handles unknown id", function()
      local id = math.random(1000, 2000)
      t.eq(
        vim.api.nvim_eval_statusline("%!v:lua.nougat_core_generator_fn(" .. id .. ")", { winid = ctx.winid }).str,
        ""
      )
    end)
  end)

  describe("_G.nougat_core_expression_fn", function()
    it("gracefully handles unknown id", function()
      local id = math.random(1000, 2000)
      t.eq(
        vim.api.nvim_eval_statusline("%{v:lua.nougat_core_expression_fn(" .. id .. ")}", { winid = ctx.winid }).str,
        ""
      )
    end)
  end)

  describe(".generator", function()
    it("re-uses fn_id if function is same", function()
      local spy = t.spy()
      local function gen_fn(context)
        spy(context)
        return "GEN"
      end

      local gen = core.generator(gen_fn)

      t.eq(gen, "%!v:lua.nougat_core_generator_fn(1)")
      t.eq(vim.api.nvim_eval_statusline(gen, { winid = ctx.winid }).str, "GEN")
      t.eq(spy.calls[1].refs[1], {
        bufnr = ctx.bufnr,
        winid = ctx.winid,
        tabid = ctx.tabid,
        is_focused = ctx.is_focused,
      })

      t.eq(gen, core.generator(gen_fn))
      t.eq(vim.api.nvim_eval_statusline(gen, { winid = ctx.winid }).str, "GEN")
      t.eq(spy.calls[2].refs[1], {
        bufnr = ctx.bufnr,
        winid = ctx.winid,
        tabid = ctx.tabid,
        is_focused = ctx.is_focused,
      })

      local context = { a = 1 }
      t.eq(gen, core.generator(gen_fn, { context = context }))
      t.eq(vim.api.nvim_eval_statusline(gen, { winid = ctx.winid }).str, "GEN")
      t.eq(spy.calls[3].refs[1], {
        bufnr = ctx.bufnr,
        winid = ctx.winid,
        tabid = ctx.tabid,
        is_focused = ctx.is_focused,
        ctx = context,
      })
      t.ref(spy.calls[3].refs[1].ctx, context)

      context = { b = 2 }
      t.eq(gen, core.generator(gen_fn, { context = context }))
      t.eq(vim.api.nvim_eval_statusline(gen, { winid = ctx.winid }).str, "GEN")
      t.eq(spy.calls[4].refs[1], {
        bufnr = ctx.bufnr,
        winid = ctx.winid,
        tabid = ctx.tabid,
        is_focused = ctx.is_focused,
        ctx = context,
      })
      t.ref(spy.calls[4].refs[1].ctx, context)
    end)

    it("generates new fn_id if function is different", function()
      t.eq(
        core.generator(function()
          return "ONE"
        end),
        "%!v:lua.nougat_core_generator_fn(1)"
      )

      t.eq(
        core.generator(function()
          return "TWO"
        end),
        "%!v:lua.nougat_core_generator_fn(2)"
      )
    end)

    it("respects provided id to identify function", function()
      local id = "test:core:generator"
      t.eq(
        core.generator(function()
          return "ONE"
        end, { id = id }),
        "%!v:lua.nougat_core_generator_fn(1)"
      )

      t.eq(
        core.generator(function()
          return "TWO"
        end, { id = id }),
        "%!v:lua.nougat_core_generator_fn(1)"
      )
    end)

    it("can handle string expression", function()
      _G.nougat_core_test_vim_version = function()
        _G.nougat_core_test_vim_version = nil
        return tostring(vim.version())
      end

      local gen = core.generator("v:lua.nougat_core_test_vim_version()")

      t.eq(vim.api.nvim_eval_statusline(gen, { winid = ctx.winid }).str, tostring(vim.version()))
    end)
  end)

  describe(".group", function()
    it("can handle string content", function()
      t.eq(core.group("GROUP", nil), "%(GROUP%)")
    end)
  end)

  describe(".add_highlight", function()
    it("can handle integer", function()
      local parts = { len = 0 }
      parts.len = core.add_highlight(1, nil, parts, parts.len)
      t.eq(table.concat(parts, nil, 1, parts.len), "%1*")
    end)
  end)

  describe(".highlight", function()
    it("can handle integer", function()
      t.eq(core.highlight(1), "%1*")
    end)
  end)
end)
