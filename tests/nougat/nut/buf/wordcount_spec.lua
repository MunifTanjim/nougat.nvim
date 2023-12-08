pcall(require, "luacov")

local Bar = require("nougat.bar")

local t = require("tests.util")

describe("nut.buf.wordcount", function()
  local bar, ctx

  local wordcount

  before_each(function()
    local bufnr = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_win_set_buf(0, bufnr)

    require("nougat.util.store").clear_all()

    bar = Bar("statusline")
    ctx = t.make_ctx(0, {
      ctx = {},
      width = vim.api.nvim_win_get_width(0),
    })

    wordcount = require("nougat.nut.buf.wordcount")
  end)

  after_each(function()
    if ctx.bufnr then
      vim.api.nvim_buf_delete(ctx.bufnr, { force = true })
    end
  end)

  it("works w/o config", function()
    bar:add_item(wordcount.create({}))

    t.eq(bar:generate(ctx), "0")

    vim.api.nvim_put({
      "A quick brown fox",
      "jumps over the",
      "lazy dog",
    }, "", false, true)

    t.eq(bar:generate(ctx), "9")
  end)

  it("works w/ config", function()
    bar:add_item(wordcount.create({
      config = {
        format = function(count)
          return string.format("%s %s", count, count > 1 and "words" or "word")
        end,
      },
    }))

    t.eq(bar:generate(ctx), "0 word")

    vim.api.nvim_put({
      "A quick brown fox",
      "jumps over the",
      "lazy dog",
    }, "", false, true)

    t.eq(bar:generate(ctx), "9 words")
  end)

  it(".hidden.if_not_filetype()", function()
    bar:add_item(wordcount.create({
      hidden = wordcount.hidden.if_not_filetype({
        markdown = true,
      }),
    }))

    t.eq(bar:generate(ctx), "")

    vim.bo[ctx.bufnr].filetype = "markdown"

    t.eq(bar:generate(ctx), "0")
  end)

  it("works in visual mode", function()
    bar:add_item(wordcount.create({}))

    vim.api.nvim_put({
      "A quick brown fox",
      "jumps over the",
      "lazy dog",
    }, "", false, true)

    t.feedkeys("<Esc>gg0v", "x")
    t.eq(bar:generate(ctx), "1")

    t.feedkeys("<Esc>gg0V", "x")
    t.eq(bar:generate(ctx), "4")

    t.feedkeys("<Esc>gg0<C-v><Down><Down>$", "x")
    t.eq(bar:generate(ctx), "9")
  end)
end)
