local core = require("nui.bar.core")
local Bar = require("nougat.bar")
local bar_util = require("nougat.bar.util")
local create_cache_store = require("nougat.cache").create_store
local Item = require("nougat.item")
local sep = require("nougat.separator")

local nut = {
  buf = {
    filename = require("nougat.nut.buf.filename").create,
    filetype = require("nougat.nut.buf.filetype").create,
  },
  git = {
    branch = require("nougat.nut.git.branch").create,
  },
  mode = require("nougat.nut.mode").create,
  spacer = require("nougat.nut.spacer").create,
}

local color = {
  bg = "#1d2021",
  bg0_h = "#1d2021",
  bg0 = "#282828",
  bg0_s = "#32302f",
  bg1 = "#3c3836",
  bg2 = "#504945",
  bg3 = "#665c54",
  bg4 = "#7c6f64",

  gray = "#928374",

  fg = "#ebdbb2",
  fg0 = "#fbf1c7",
  fg1 = "#ebdbb2",
  fg2 = "#d5c4a1",
  fg3 = "#bdae93",
  fg4 = "#a89984",

  lightgray = "#a89984",

  red = "#fb4934",
  green = "#b8bb26",
  yellow = "#fabd2f",
  blue = "#83a598",
  purple = "#d3869b",
  aqua = "#8ec07c",
  orange = "#f38019",

  accent = {
    red = "#cc241d",
    green = "#98971a",
    yellow = "#d79921",
    blue = "#458588",
    purple = "#b16286",
    aqua = "#689d6a",
    orange = "#d65d0e",
  },
}

local mode = nut.mode({
  sep_left = sep.left_half_circle_solid(true),
  sep_right = sep.right_half_circle_solid(true),
  config = {
    highlight = {
      normal = {
        bg = "fg",
        fg = color.bg,
      },
      visual = {
        bg = color.orange,
        fg = color.bg,
      },
      insert = {
        bg = color.blue,
        fg = color.bg,
      },
      replace = {
        bg = color.purple,
        fg = color.bg,
      },
      commandline = {
        bg = color.green,
        fg = color.bg,
      },
      terminal = {
        bg = color.accent.green,
        fg = color.bg,
      },
      inactive = {},
    },
  },
})

local filename = (function()
  local item = Item({
    prepare = function(_, ctx)
      local data = ctx.ctx
      data.readonly = vim.bo[ctx.bufnr].readonly
      data.modifiable = vim.bo[ctx.bufnr].modifiable
      data.modified = vim.bo[ctx.bufnr].modified
    end,
    hl = { bg = "fg", fg = color.bg },
    sep_left = sep.left_half_circle_solid({ fg = sep.hl.child_bg }),
    content = {
      Item({
        hl = { bg = color.bg4, fg = color.fg },
        hidden = function(_, ctx)
          return not ctx.ctx.readonly
        end,
        suffix = " ",
        content = "RO",
      }),
      Item({ content = core.truncation_point() }),
      Item({
        hl = { bg = color.bg4, fg = color.fg },
        hidden = function(_, ctx)
          return ctx.ctx.modifiable
        end,
        content = "",
        suffix = " ",
      }),
      nut.buf.filename({
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
    sep_right = sep.right_half_circle_solid({ fg = sep.hl.child_bg }),
  })

  return item
end)()

local gitstatus_cache = create_cache_store("buf", "examples.bubbly.gitstatus", {
  added = nil,
  changed = nil,
  removed = nil,
  total = 0,
})

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("nougat.examples.bubby.gitstatus", { clear = true }),
  pattern = "GitSignsUpdate",
  callback = function(params)
    local bufnr = params.buf
    vim.schedule(function()
      local status = vim.b[bufnr].gitsigns_status_dict
      local cache = gitstatus_cache[bufnr]
      if status and status.added then
        cache.added = status.added > 0 and tostring(status.added) or nil
        cache.changed = status.changed > 0 and tostring(status.changed) or nil
        cache.removed = status.removed > 0 and tostring(status.removed) or nil
        cache.total = status.added + status.changed + status.removed
      else
        cache.total = 0
      end
    end)
  end,
})

local gitstatus = (function()
  local item = Item({
    prepare = function(item, ctx)
      ctx.gitstatus = item.cache[ctx.bufnr]
    end,
    hidden = function(_, ctx)
      return ctx.gitstatus.total == 0
    end,
    hl = { bg = color.fg, fg = color.bg },
    sep_left = sep.left_half_circle_solid({ fg = sep.hl.child_bg }),
    content = {
      Item({
        hl = { bg = color.green },
        hidden = function(_, ctx)
          return not ctx.gitstatus.added
        end,
        prefix = "+",
        content = function(_, ctx)
          return ctx.gitstatus.added
        end,
        suffix = function(_, ctx)
          return (ctx.gitstatus.changed or ctx.gitstatus.removed) and " " or ""
        end,
      }),
      Item({
        hl = { bg = color.blue },
        hidden = function(_, ctx)
          return not ctx.gitstatus.changed
        end,
        prefix = function(_, ctx)
          return ctx.gitstatus.added and " ~" or "~"
        end,
        content = function(_, ctx)
          return ctx.gitstatus.changed
        end,
        suffix = function(_, ctx)
          return ctx.gitstatus.removed and " " or ""
        end,
      }),
      Item({
        hl = { bg = color.red },
        hidden = function(_, ctx)
          return not ctx.gitstatus.removed
        end,
        prefix = function(_, ctx)
          return (ctx.gitstatus.added or ctx.gitstatus.changed) and " -" or "-"
        end,
        content = function(_, ctx)
          return ctx.gitstatus.removed
        end,
      }),
    },
    sep_right = sep.right_half_circle_solid({ fg = sep.hl.child_bg }),
  })

  item.cache = gitstatus_cache

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

-- renders space if `condition` evaluates to `true`
---@param condition nougat_item_hidden
local function space_cond(condition)
  local hidden = type(condition) == "function" and function(item, ctx)
    return not condition(item, ctx)
  end or condition

  return {
    content = sep.space().content,
    hidden = hidden,
  }
end

local stl = Bar("statusline")
stl:add_item(mode)
stl:add_item(sep.space())
stl:add_item(nut.git.branch({
  hl = { bg = color.purple, fg = color.bg },
  sep_left = sep.left_half_circle_solid(true),
  prefix = " ",
  sep_right = sep.right_half_circle_solid(true),
}))
stl:add_item(sep.space())
stl:add_item(gitstatus)
stl:add_item(space_cond(function(_, ctx)
  return ctx.gitstatus.total > 0
end))
stl:add_item(filename)
stl:add_item(sep.space())
stl:add_item(nut.spacer())
stl:add_item(nut.buf.filetype({
  hl = { bg = color.blue, fg = color.bg },
  sep_left = sep.left_half_circle_solid(true),
  sep_right = sep.right_half_circle_solid(true),
}))
stl:add_item(sep.space())
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

bar_util.set_statusline(function(ctx)
  return ctx.is_focused and stl or stl_inactive
end)
