pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.lsp.servers", function()
  local bar, ctx

  local nut

  before_each(function()
    require("nougat.store")._clear()

    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    nut = require("nougat.nut.lsp.servers")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works w/o config", function()
    bar:add_item(nut.create())

    local orig_fn = vim.lsp.get_clients
    vim.lsp.get_clients = function(filter)
      vim.lsp.get_clients = orig_fn
      if filter.bufnr == ctx.bufnr then
        return { { name = "one" } }
      end
      return vim.lsp.get_clients(filter)
    end

    t.eq(bar:generate(ctx), "one")

    local orig_fn = vim.lsp.get_clients
    vim.lsp.get_clients = function(filter)
      vim.lsp.get_clients = orig_fn
      if filter.bufnr == ctx.bufnr then
        return { { name = "one" }, { name = "two" } }
      end
      return vim.lsp.get_clients(filter)
    end

    t.eq(bar:generate(ctx), "one")

    vim.api.nvim_exec_autocmds("LspAttach", {
      buffer = ctx.bufnr,
    })

    t.eq(bar:generate(ctx), "one two")

    local orig_fn = vim.lsp.get_clients
    vim.lsp.get_clients = function(filter)
      vim.lsp.get_clients = orig_fn
      if filter.bufnr == ctx.bufnr then
        return { { name = "two" } }
      end
      return vim.lsp.get_clients(filter)
    end

    t.eq(bar:generate(ctx), "one two")

    vim.api.nvim_exec_autocmds("LspAttach", {
      buffer = ctx.bufnr,
    })

    t.eq(bar:generate(ctx), "two")
  end)

  it("works w/  config", function()
    bar:add_item(nut.create({
      config = {
        content = function(client)
          if client.name == "one" then
            return { content = client.name }
          end
          if client.name == "two" then
            return { { content = "2", hl = { fg = "red" } }, "(", { content = client.name }, ")" }
          end
        end,
        sep = ", ",
      },
    }))

    local orig_fn = vim.lsp.get_clients
    vim.lsp.get_clients = function(filter)
      vim.lsp.get_clients = orig_fn
      if filter.bufnr == ctx.bufnr then
        return { { name = "one" }, { name = "two" } }
      end
      return vim.lsp.get_clients(filter)
    end

    t.eq(
      bar:generate(ctx),
      table.concat({
        "one",
        ", ",
        "%#bg_ffcd00_fg_red_#",
        "2",
        "%#bg_ffcd00_fg_663399_#",
        "(two)",
      })
    )
  end)
end)
