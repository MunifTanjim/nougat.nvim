for pkg_name in pairs(package.loaded) do
  if pkg_name:match("^nougat") then
    if pkg_name ~= "nougat.bar.store" then
      package.loaded[pkg_name] = nil
    end
  end
end

local core = require("nui.bar.core")
local Bar = require("nougat.bar")
local bar_util = require("nougat.bar.util")
local Item = require("nougat.item")
local sep = require("nougat.separator")
local u = require("nougat.util")

local nut = {
  buf = {
    diagnostic_count = require("nougat.nut.buf.diagnostic_count").create,
    fileencoding = require("nougat.nut.buf.fileencoding").create,
    fileformat = require("nougat.nut.buf.fileformat").create,
    filename = require("nougat.nut.buf.filename"),
    filestatus = require("nougat.nut.buf.filestatus").create,
    filetype = require("nougat.nut.buf.filetype").create,
    wordcount = require("nougat.nut.buf.wordcount").create,
  },
  git = {
    branch = require("nougat.nut.git.branch").create,
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
  ruler = require("nougat.nut.ruler").create,
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

vim.o.rulerformat = table.concat({
  core.code("p"),
  "%% L:",
  core.code("l"),
  "/",
  core.code("L"),
  " C:",
  core.code("v"),
})

local stl = Bar("statusline")

local mode = nut.mode({
  sep_left = sep.left_half_circle_solid(),
  sep_right = sep.right_half_circle_solid(true),
  config = {
    highlight = {
      normal = {
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
stl:add_item(mode)
stl:add_item({ content = " ", hl = { bg = color.bg2 } })
-- stl:add_item(nut.git.branch({
--   hl = { bg = color.bg3, fg = color.fg1 },
--   prefix = { "  ", " " },
--   suffix = " ",
-- }))

local function bubbly_filename(opts)
  local gray_hl = { bg = color.bg4, fg = color.fg }
  local white_hl = { bg = color.fg, fg = color.bg }

  local sep_left = sep.left_half_circle_solid()
  sep_left.hl.bg = "bg"
  local sep_right = sep.right_half_circle_solid()
  sep_right.hl.bg = "bg"

  local item = Item({
    hl = gray_hl,
    content = function(item, ctx)
      local bar_hl = ctx.ctx.bar_hl

      local config = item:config(ctx)
      local sym = config.symbols

      local parts = ctx.parts
      local part_idx = parts.len

      local has_left_section = false

      local sl_hl_idx = part_idx
      part_idx = part_idx + 3

      part_idx = part_idx + 1
      parts[part_idx] = sep_left.content

      part_idx = core.add_highlight(u.set_hl(gray_hl, bar_hl), nil, parts, part_idx)

      if sym.readonly and vim.bo[ctx.bufnr].readonly then
        has_left_section = true
        part_idx = part_idx + 1
        parts[part_idx] = sym.readonly
      end

      if sym.nomodifiable and not vim.bo[ctx.bufnr].modifiable then
        if has_left_section then
          part_idx = part_idx + 1
          parts[part_idx] = sym.sep
        end

        part_idx = part_idx + 1
        parts[part_idx] = sym.nomodifiable
      end

      if has_left_section then
        sep_left.hl.fg = gray_hl.bg
        core.add_highlight(u.set_hl(sep_left.hl, bar_hl), nil, parts, sl_hl_idx)
        part_idx = part_idx + 1
        parts[part_idx] = " "
        part_idx = core.add_highlight(u.set_hl(white_hl, bar_hl), nil, parts, part_idx)
        part_idx = part_idx + 1
        parts[part_idx] = " "
      else
        sep_left.hl.fg = white_hl.bg
        core.add_highlight(u.set_hl(sep_left.hl, bar_hl), nil, parts, sl_hl_idx)
        part_idx = core.add_highlight(u.set_hl(white_hl, bar_hl), nil, parts, part_idx)
      end

      part_idx = part_idx + 1
      parts[part_idx] = nut.buf.filename.content(item, ctx)

      if sym.modified and vim.bo[ctx.bufnr].modified then
        part_idx = part_idx + 1
        parts[part_idx] = " "

        part_idx = core.add_highlight(u.set_hl(gray_hl, bar_hl), nil, parts, part_idx)
        part_idx = part_idx + 1
        parts[part_idx] = sym.sep
        part_idx = part_idx + 1
        parts[part_idx] = sym.modified

        sep_right.hl.fg = gray_hl.bg
      else
        sep_right.hl.fg = white_hl.bg
      end

      part_idx = core.add_highlight(u.set_hl(sep_right.hl, bar_hl), nil, parts, part_idx)
      part_idx = part_idx + 1
      parts[part_idx] = sep_right.content

      part_idx = core.add_highlight(0, nil, parts, part_idx)

      parts.len = part_idx
    end,
    config = vim.tbl_extend("force", {
      modifier = ":.",
      format = nil,
      unnamed = "[No Name]",
      symbols = {
        modified = "+",
        nomodifiable = "",
        readonly = "RO",
        sep = " ",
      },
    }, opts.config or {}),
  })

  item.cache = nut.buf.filename.cache

  return item
end

stl:add_item(Item({
  prepare = function(item, ctx)
    local data = ctx.ctx
    data.readonly = vim.bo[ctx.bufnr].readonly
    data.modifiable = vim.bo[ctx.bufnr].modifiable
    data.modified = vim.bo[ctx.bufnr].modified

    if data.readonly or not data.modifiable then
      item.hl.bg = color.bg4
    else
      item.hl.bg = color.fg
    end
  end,
  hl = { bg = color.fg, fg = color.bg },
  sep_left = sep.left_half_circle_solid(),
  sep_right = sep.right_half_circle_solid(),
  content = {
    Item({
      hl = { bg = color.bg4, fg = color.bg },
      hidden = function(_, ctx)
        return not ctx.ctx.readonly
      end,
      suffix = " ",
      content = "RO",
    }),
    Item({
      hl = { bg = color.bg4 },
      hidden = function(_, ctx)
        return ctx.ctx.modifiable
      end,
      content = "",
      suffix = " ",
    }),
    nut.buf.filename.create({
      hl = { bg = color.fg, fg = color.bg },
      sep_left = sep.left_half_circle_solid(true),
      sep_right = sep.right_half_circle_solid(true),
    }),
    Item({
      hl = { bg = color.bg4 },
      hidden = function(_, ctx)
        return not ctx.ctx.modified
      end,
      prefix = " ",
      content = "+",
    }),
  },
}))
-- stl:add_item(core.truncation_point())
-- stl:add_item(nut.spacer())
-- stl:add_item(nut.buf.filetype({
--   prefix = " ",
--   suffix = " ",
-- }))
-- stl:add_item(nut.buf.diagnostic_count({
--   hidden = function(item, ctx)
--     return item.cache[ctx.bufnr][item:config(ctx).severity] == 0
--   end,
--   hl = { bg = color.bg3 },
--   prefix = " ",
--   suffix = " ",
--   config = {
--     error = { prefix = " ", fg = color.red },
--     warn = { prefix = " ", fg = color.yellow },
--     info = { prefix = " ", fg = color.blue },
--     hint = { prefix = " ", fg = color.green },
--   },
-- }))
-- stl:add_item(nut.buf.fileencoding({
--   hidden = function(_, ctx)
--     return vim.bo[ctx.bufnr].fileencoding == "utf-8"
--   end,
--   prefix = " ",
--   suffix = " ",
-- }))
-- stl:add_item(nut.buf.fileformat({
--   hidden = function(_, ctx)
--     return vim.bo[ctx.bufnr].fileformat == "unix"
--   end,
--   hl = { bg = color.bg3, fg = "fg" },
--   prefix = " ",
--   suffix = " ",
--   config = {
--     text = {
--       dos = "",
--       unix = "",
--       mac = "",
--     },
--   },
-- }))
-- local wordcount_enabled = {
--   markdown = true,
-- }
-- stl:add_item(nut.buf.wordcount({
--   hidden = function(_, ctx)
--     return not wordcount_enabled[vim.bo[ctx.bufnr].filetype]
--   end,
--   hl = mode,
--   sep_left = sep.space(),
--   config = {
--     format = function(count)
--       return string.format("%d Word%s", count, count > 1 and "s" or "")
--     end,
--   },
-- }))
-- stl:add_item(nut.ruler({
--   hl = mode,
--   sep_left = sep.space(),
--   suffix = " ",
-- }))

local stl_inactive = Bar("statusline")
-- stl_inactive:add_item(mode)
-- stl_inactive:add_item(core.truncation_point())
-- stl_inactive:add_item(nut.buf.filename({
--   prefix = " ",
--   suffix = " ",
-- }))

bar_util.set_statusline(function(ctx)
  return ctx.is_focused and stl or stl_inactive
end)
