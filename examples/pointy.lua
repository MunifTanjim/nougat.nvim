local core = require("nui.bar.core")
local Bar = require("nougat.bar")
local bar_util = require("nougat.bar.util")
local create_cache_store = require("nougat.cache").create_store
local Item = require("nougat.item")
local sep = require("nougat.separator")

local nut = {
  buf = {
    diagnostic_count = require("nougat.nut.buf.diagnostic_count").create,
    filename = require("nougat.nut.buf.filename").create,
    filestatus = require("nougat.nut.buf.filestatus").create,
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
  prefix = " ",
  suffix = " ",
  sep_right = sep.right_chevron_solid(true),
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

local gitstatus_cache = create_cache_store("buf", "examples.bubbly.gitstatus", {
  head = "",
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
      local cache = gitstatus_cache[bufnr]

      cache.head = vim.fn.getbufvar(bufnr, "gitsigns_head", "")

      local status = vim.fn.getbufvar(bufnr, "gitsigns_status_dict", false)
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

local stl = Bar("statusline")
stl:add_item(mode)
stl:add_item(Item({
  prepare = function(_, ctx)
    ctx.gitstatus = gitstatus_cache[ctx.bufnr]
  end,
  hl = { bg = color.purple, fg = color.bg },
  prefix = "  ",
  content = function(_, ctx)
    return ctx.gitstatus.head
  end,
  suffix = " ",
  sep_right = sep.right_chevron_solid(true),
}))
local filename = stl:add_item(nut.buf.filename({
  hl = { bg = color.bg3 },
  prefix = " ",
  suffix = " ",
}))
local filestatus = stl:add_item(nut.buf.filestatus({
  hl = { bg = color.bg3 },
  suffix = " ",
  sep_right = sep.right_chevron_solid(true),
  config = {
    modified = "",
    nomodifiable = "",
    readonly = "",
    sep = " ",
  },
}))
stl:add_item(nut.spacer())
stl:add_item(nut.buf.diagnostic_count({
  hidden = false,
  hl = { bg = color.red, fg = color.bg },
  sep_left = sep.left_chevron_solid(true),
  prefix = " ",
  suffix = " ",
  config = {
    severity = vim.diagnostic.severity.ERROR,
  },
}))
stl:add_item(nut.buf.diagnostic_count({
  hidden = false,
  hl = { bg = color.yellow, fg = color.bg },
  sep_left = sep.left_chevron_solid(true),
  prefix = " ",
  suffix = " ",
  config = {
    severity = vim.diagnostic.severity.WARN,
  },
}))
stl:add_item(nut.buf.diagnostic_count({
  hidden = false,
  hl = { bg = color.blue, fg = color.bg },
  sep_left = sep.left_chevron_solid(true),
  prefix = " ",
  suffix = " ",
  config = {
    severity = vim.diagnostic.severity.INFO,
  },
}))
stl:add_item(nut.buf.diagnostic_count({
  hl = { bg = color.green, fg = color.bg },
  sep_left = sep.left_chevron_solid(true),
  prefix = " ",
  suffix = " ",
  config = {
    severity = vim.diagnostic.severity.HINT,
  },
}))
stl:add_item(nut.buf.filetype({
  hl = { bg = color.bg1 },
  sep_left = sep.left_chevron_solid(true),
  prefix = " ",
  suffix = " ",
}))
stl:add_item(Item({
  hl = { bg = color.bg2, fg = color.blue },
  sep_left = sep.left_chevron_solid(true),
  prefix = "  ",
  content = core.group({
    core.code("l"),
    ":",
    core.code("c"),
  }),
  suffix = " ",
}))
stl:add_item(Item({
  hl = { bg = color.blue, fg = color.bg },
  sep_left = sep.left_chevron_solid(true),
  prefix = " ",
  content = core.code("P"),
  suffix = " ",
}))

local stl_inactive = Bar("statusline")
stl_inactive:add_item(mode)
stl_inactive:add_item(filename)
stl_inactive:add_item(filestatus)
stl_inactive:add_item(nut.spacer())

bar_util.set_statusline(function(ctx)
  return ctx.is_focused and stl or stl_inactive
end)
