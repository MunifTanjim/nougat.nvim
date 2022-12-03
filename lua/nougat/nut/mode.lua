local Item = require("nougat.item")
local create_cache_store = require("nougat.cache").create_store

local cache_store = create_cache_store("win", "nut.mode", { mode = "", group = "" })

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

local function refresh(item, ctx)
  local mode = ctx.is_focused and vim.api.nvim_get_mode().mode or "-"
  local cache = item.cache[ctx.winid]
  if cache.mode ~= mode then
    cache.mode, cache.group = mode, mode_group[mode]
  end
end

local function get_content(item, ctx)
  local mode = item.cache[ctx.winid].mode
  return item:config(ctx).text[mode] or mode
end

local function get_hl(item, ctx)
  return item:config(ctx).highlight[item.cache[ctx.winid].group]
end

local mod = {}

function mod.create(opts)
  opts = opts or {}

  local item = Item({
    hidden = opts.hidden,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_deep_extend("keep", opts.config or {}, {
      text = default_text,
      highlight = default_highlight,
    }),
  })

  item.cache = cache_store

  item.content = get_content

  item.hl = get_hl

  item.refresh = refresh

  return item
end

return mod
