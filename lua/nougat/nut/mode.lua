local Item = require("nougat.item")
local on_event = require("nougat.util").on_event

local mode_group = {
  ["n"] = "normal",
  ["no"] = "normal",
  ["nov"] = "normal",
  ["noV"] = "normal",
  ["no"] = "normal",
  ["niI"] = "normal",
  ["niR"] = "normal",
  ["niV"] = "normal",
  ["nt"] = "normal",
  ["ntT"] = "normal",

  ["v"] = "visual",
  ["vs"] = "visual",
  ["V"] = "visual",
  ["Vs"] = "visual",
  [""] = "visual",
  ["s"] = "visual",

  ["s"] = "visual",
  ["S"] = "visual",
  [""] = "visual",

  ["i"] = "insert",
  ["ic"] = "insert",
  ["ix"] = "insert",

  ["R"] = "replace",
  ["Rc"] = "replace",
  ["Rx"] = "replace",
  ["Rv"] = "replace",
  ["Rvc"] = "replace",
  ["Rvx"] = "replace",

  ["c"] = "commandline",
  ["cv"] = "commandline",
  ["ce"] = "commandline",
  ["r"] = "commandline",
  ["rm"] = "commandline",
  ["r?"] = "commandline",
  ["!"] = "commandline",

  ["t"] = "terminal",

  ["-"] = "inactive",
}

local default_text = {
  ["n"] = "NORMAL",
  ["no"] = "OP PENDING",
  ["nov"] = "OP PENDING CHAR",
  ["noV"] = "OP PENDING LINE",
  ["no"] = "OP PENDING BLOCK",
  ["niI"] = "INSERT (NORMAL)",
  ["niR"] = "REPLACE (NORMAL)",
  ["niV"] = "V REPLACE (NORMAL)",
  ["nt"] = "TERMINAL NORMAL",
  ["ntT"] = "TERMINAL (NORMAL)",

  ["v"] = "VISUAL",
  ["vs"] = "SELECT (VISUAL)",
  ["V"] = "V-LINE",
  ["Vs"] = "SELECT (V-LINE)",
  [""] = "V-BLOCK",
  ["s"] = "SELECT (V-BLOCK)",

  ["s"] = "SELECT",
  ["S"] = "S-LINE",
  [""] = "S-BLOCK",

  ["i"] = "INSERT",
  ["ic"] = "INSERT COMPL GENERIC",
  ["ix"] = "INSERT COMPL",

  ["R"] = "REPLACE",
  ["Rc"] = "REPLACE COMP GENERIC",
  ["Rx"] = "REPLACE COMP",
  ["Rv"] = "V REPLACE",
  ["Rvc"] = "V REPLACE COMP GENERIC",
  ["Rvx"] = "V REPLACE COMP",

  ["c"] = "COMMAND",
  ["cv"] = "VIM EX",
  ["ce"] = "EX",
  ["r"] = "PROMPT",
  ["rm"] = "MORE PROMPT",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",

  ["t"] = "TERMINAL",

  ["-"] = "INACTIVE",
}

local default_highlight = {
  normal = {
    bg = "fg",
    fg = "bg",
  },
  visual = {
    bg = "orange",
    fg = "bg",
  },
  insert = {
    bg = "lightblue",
    fg = "bg",
  },
  replace = {
    bg = "violet",
    fg = "bg",
  },
  commandline = {
    bg = "lightgreen",
    fg = "bg",
  },
  terminal = {
    bg = "teal",
    fg = "fg",
  },
  inactive = {
    bg = "fg",
    fg = "bg",
  },
}

local cache = {
  mode = "n",
  group = mode_group["n"],
}

on_event("ModeChanged", function()
  local event = vim.v.event
  local old_mode, new_mode = event.old_mode, event.new_mode
  cache.mode, cache.group = new_mode, mode_group[new_mode]
  if old_mode == "t" then
    vim.schedule(function()
      vim.cmd("redrawstatus")
    end)
  end
end)

local function get_content(item, ctx)
  local mode = ctx.is_focused and cache.mode or "-"
  return item:config(ctx).text[mode] or mode
end

local function get_hl(item, ctx)
  return item:config(ctx).highlight[ctx.is_focused and cache.group or "inactive"]
end

local mod = {}

function mod.create(opts)
  opts = opts or {}

  local item = Item({
    hidden = opts.hidden,
    hl = get_hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = get_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_deep_extend("keep", opts.config or {}, {
      text = default_text,
      highlight = default_highlight,
    }),
    on_click = opts.on_click,
    context = opts.context,
  })

  return item
end

return mod
