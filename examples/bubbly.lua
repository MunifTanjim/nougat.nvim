local nougat = require("nougat")
local core = require("nougat.core")
local Bar = require("nougat.bar")
local Item = require("nougat.item")
local sep = require("nougat.separator")

local nut = {
  buf = {
    diagnostic_count = require("nougat.nut.buf.diagnostic_count").create,
    filename = require("nougat.nut.buf.filename").create,
    filetype = require("nougat.nut.buf.filetype").create,
  },
  git = {
    branch = require("nougat.nut.git.branch").create,
    status = require("nougat.nut.git.status"),
  },
  tab = {
    tablist = {
      tabs = require("nougat.nut.tab.tablist").create,
      close = require("nougat.nut.tab.tablist.close").create,
      icon = require("nougat.nut.tab.tablist.icon").create,
      label = require("nougat.nut.tab.tablist.label").create,
      modified = require("nougat.nut.tab.tablist.modified").create,
    },
  },
  mode = require("nougat.nut.mode").create,
  spacer = require("nougat.nut.spacer").create,
  truncation_point = require("nougat.nut.truncation_point").create,
}

---@type nougat.color
local color = require("nougat.color").get()

local mode = nut.mode({
  sep_left = sep.left_half_circle_solid(true),
  sep_right = sep.right_half_circle_solid(true),
})

local filename = (function()
  local item = Item({
    prepare = function(_, ctx)
      local bufnr, data = ctx.bufnr, ctx.ctx
      data.readonly = vim.api.nvim_buf_get_option(bufnr, "readonly")
      data.modifiable = vim.api.nvim_buf_get_option(bufnr, "modifiable")
      data.modified = vim.api.nvim_buf_get_option(bufnr, "modified")
    end,
    sep_left = sep.left_half_circle_solid(true),
    content = {
      Item({
        hl = { bg = color.bg4, fg = color.fg },
        hidden = function(_, ctx)
          return not ctx.ctx.readonly
        end,
        suffix = " ",
        content = "RO",
      }),
      Item({
        hl = { bg = color.bg4, fg = color.fg },
        hidden = function(_, ctx)
          return ctx.ctx.modifiable
        end,
        content = "",
        suffix = " ",
      }),
      nut.buf.filename({
        hl = { bg = color.fg, fg = color.bg },
        prefix = function(_, ctx)
          local data = ctx.ctx
          if data.readonly or not data.modifiable then
            return " "
          end
          return ""
        end,
        suffix = function(_, ctx)
          local data = ctx.ctx
          if data.modified then
            return " "
          end
          return ""
        end,
      }),
      Item({
        hl = { bg = color.bg4, fg = color.fg },
        hidden = function(_, ctx)
          return not ctx.ctx.modified
        end,
        prefix = " ",
        content = "+",
      }),
    },
    sep_right = sep.right_half_circle_solid(true),
  })

  return item
end)()

local ruler = (function()
  local scroll_hl = {
    [true] = { bg = color.bg3 },
    [false] = { bg = color.bg4 },
  }

  local item = Item({
    content = {
      Item({
        hl = { bg = color.bg4 },
        sep_left = sep.left_half_circle_solid(true),
        content = core.group({
          core.code("l"),
          ":",
          core.code("c"),
        }, { align = "left", min_width = 8 }),
        suffix = " ",
      }),
      Item({
        hl = function(_, ctx)
          return scroll_hl[ctx.is_focused]
        end,
        prefix = " ",
        content = core.code("P"),
        sep_right = sep.right_half_circle_solid(true),
      }),
    },
  })

  return item
end)()

-- renders space only when item is rendered
---@param item NougatItem
local function paired_space(item)
  return Item({
    content = sep.space().content,
    hidden = item,
  })
end

local stl = Bar("statusline")
stl:add_item(mode)
stl:add_item(sep.space())
stl:add_item(nut.git.branch({
  hl = { bg = color.magenta, fg = color.bg },
  sep_left = sep.left_half_circle_solid(true),
  prefix = " ",
  sep_right = sep.right_half_circle_solid(true),
}))
stl:add_item(sep.space())
local gitstatus = stl:add_item(nut.git.status.create({
  hl = { fg = color.bg },
  sep_left = sep.left_half_circle_solid(true),
  content = {
    nut.git.status.count("added", {
      hl = { bg = color.green },
      prefix = "+",
      suffix = function(_, ctx)
        return (ctx.gitstatus.changed > 0 or ctx.gitstatus.removed > 0) and " " or ""
      end,
    }),
    nut.git.status.count("changed", {
      hl = { bg = color.blue },
      prefix = function(_, ctx)
        return ctx.gitstatus.added > 0 and " ~" or "~"
      end,
      suffix = function(_, ctx)
        return ctx.gitstatus.removed > 0 and " " or ""
      end,
    }),
    nut.git.status.count("removed", {
      hl = { bg = color.red },
      prefix = function(_, ctx)
        return (ctx.gitstatus.added > 0 or ctx.gitstatus.changed > 0) and " -" or "-"
      end,
    }),
  },
  sep_right = sep.right_half_circle_solid(true),
}))
stl:add_item(paired_space(gitstatus))
stl:add_item(filename)
stl:add_item(sep.space())
stl:add_item(nut.spacer())
stl:add_item(nut.truncation_point())
stl:add_item(nut.buf.filetype({
  hl = { bg = color.blue, fg = color.bg },
  sep_left = sep.left_half_circle_solid(true),
  sep_right = sep.right_half_circle_solid(true),
}))
stl:add_item(sep.space())
local diagnostic_count = stl:add_item(nut.buf.diagnostic_count({
  hl = { bg = color.bg4 },
  sep_left = sep.left_half_circle_solid(true),
  sep_right = sep.right_half_circle_solid(true),
  config = {
    error = { prefix = " " },
    warn = { prefix = " " },
    info = { prefix = " " },
    hint = { prefix = "󰌶 " },
  },
}))
stl:add_item(paired_space(diagnostic_count))
stl:add_item(ruler)
stl:add_item(sep.space())

local stl_inactive = Bar("statusline")
stl_inactive:add_item(mode)
stl_inactive:add_item(sep.space())
stl_inactive:add_item(filename)
stl_inactive:add_item(sep.space())
stl_inactive:add_item(nut.spacer())
stl_inactive:add_item(ruler)
stl_inactive:add_item(sep.space())

nougat.set_statusline(function(ctx)
  return ctx.is_focused and stl or stl_inactive
end)

local tal = Bar("tabline")

tal:add_item(nut.tab.tablist.tabs({
  active_tab = {
    hl = { bg = color.bg, fg = color.blue },
    prefix = " ",
    suffix = " ",
    content = {
      nut.tab.tablist.icon({ suffix = " " }),
      nut.tab.tablist.label({}),
      nut.tab.tablist.modified({ prefix = " ", config = { text = "●" } }),
      nut.tab.tablist.close({ prefix = " ", config = { text = "󰅖" } }),
    },
    sep_left = sep.left_half_circle_solid({ bg = "bg", fg = color.bg }),
    sep_right = sep.right_half_circle_solid({ bg = "bg", fg = color.bg }),
  },
  inactive_tab = {
    hl = { bg = color.bg2, fg = color.fg2 },
    prefix = " ",
    suffix = " ",
    content = {
      nut.tab.tablist.icon({ suffix = " " }),
      nut.tab.tablist.label({}),
      nut.tab.tablist.modified({ prefix = " ", config = { text = "●" } }),
      nut.tab.tablist.close({ prefix = " ", config = { text = "󰅖" } }),
    },
    sep_left = sep.left_half_circle_solid({ bg = "bg", fg = color.bg2 }),
    sep_right = sep.right_half_circle_solid({ bg = "bg", fg = color.bg2 }),
  },
}))

nougat.set_tabline(tal)
