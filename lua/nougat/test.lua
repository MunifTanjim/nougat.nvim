for pkg_name in pairs(package.loaded) do
  if pkg_name:match("^nougat") then
    package.loaded[pkg_name] = nil
  end
end

local function get_gruvbox()
  local mod = {
    dark0_hard = "#1d2021",
    dark0 = "#282828",
    dark0_soft = "#32302f",
    dark1 = "#3c3836",
    dark2 = "#504945",
    dark3 = "#665c54",
    dark4 = "#7c6f64",

    light0_hard = "#f9f5d7",
    light0 = "#fbf1c7",
    light0_soft = "#f2e5bc",
    light1 = "#ebdbb2",
    light2 = "#d5c4a1",
    light3 = "#bdae93",
    light4 = "#a89984",

    bright = {
      gray = "#a89984",
      red = "#fb4934",
      green = "#b8bb26",
      yellow = "#fabd2f",
      blue = "#83a598",
      purple = "#d3869b",
      aqua = "#8ec07c",
      orange = "#f38019",
    },

    neutral = {
      gray = "#928374",
      red = "#cc241d",
      green = "#98971a",
      yellow = "#d79921",
      blue = "#458588",
      purple = "#b16286",
      aqua = "#689d6a",
      orange = "#d65d0e",
    },

    faded = {
      gray = "#7c6f64",
      red = "#9d0006",
      green = "#79740e",
      yellow = "#b57614",
      blue = "#076678",
      purple = "#8f3f71",
      aqua = "#427b58",
      orange = "#af3a03",
    },
  }

  mod.dark = {
    bg = mod.dark0,
    bg0_h = mod.dark0_hard,
    bg0 = mod.dark0,
    bg0_s = mod.dark0_soft,
    bg1 = mod.dark1,
    bg2 = mod.dark2,
    bg3 = mod.dark3,
    bg4 = mod.dark4,

    gray = mod.neutral.gray,

    fg = mod.light1,
    fg0 = mod.light0,
    fg1 = mod.light1,
    fg2 = mod.light2,
    fg3 = mod.light3,
    fg4 = mod.light4,

    lightgray = mod.light4,

    red = mod.bright.red,
    green = mod.bright.green,
    yellow = mod.bright.yellow,
    blue = mod.bright.blue,
    purple = mod.bright.purple,
    aqua = mod.bright.aqua,
    orange = mod.bright.orange,

    accent = {
      red = mod.neutral.red,
      green = mod.neutral.green,
      yellow = mod.neutral.yellow,
      blue = mod.neutral.blue,
      purple = mod.neutral.purple,
      aqua = mod.neutral.aqua,
      orange = mod.neutral.orange,
    },
  }

  mod.light = {
    bg = mod.light0,
    bg0_h = mod.light0_hard,
    bg0 = mod.light0,
    bg0_s = mod.light0_soft,
    bg1 = mod.light1,
    bg2 = mod.light2,
    bg3 = mod.light3,
    bg4 = mod.light4,

    gray = mod.neutral.gray,

    fg = mod.dark1,
    fg0 = mod.dark0,
    fg1 = mod.dark1,
    fg2 = mod.dark2,
    fg3 = mod.dark3,
    fg4 = mod.dark4,

    darkgray = mod.dark4,

    red = mod.faded.purple,
    green = mod.faded.green,
    yellow = mod.faded.yellow,
    blue = mod.faded.blue,
    purple = mod.faded.purple,
    aqua = mod.faded.aqua,
    orange = mod.faded.orange,

    accent = {
      red = mod.neutral.red,
      green = mod.neutral.green,
      yellow = mod.neutral.yellow,
      blue = mod.neutral.blue,
      purple = mod.neutral.purple,
      aqua = mod.neutral.aqua,
      orange = mod.neutral.orange,
    },
  }

  return mod
end

local color = get_gruvbox()

local function setup_rich_stl()
  local core = require("nui.bar.core")
  local Bar = require("nougat.bar")
  local Item = require("nougat.item")
  local sep = require("nougat.separator")
  local nut = {
    buf = {
      fileencoding = require("nougat.nut.buf.fileencoding").fileencoding,
      fileformat = require("nougat.nut.buf.fileformat").fileformat,
      filename = require("nougat.nut.buf.filename").create,
      filetype = require("nougat.nut.buf.filetype").filetype,
      wordcount = require("nougat.nut.buf.wordcount").wordcount,
      lsp_active_clients = require("nougat.nut.buf.lsp_active_clients").lsp_active_clients,
      diagnostic_count = require("nougat.nut.buf.diagnostic_count").create,
    },
    mode = require("nougat.nut.mode").create,
    ruler = require("nougat.nut.ruler").create,
    spacer = require("nougat.nut.spacer").create,
  }

  vim.o.rulerformat = table.concat({
    core.code("p"),
    "%% L:",
    core.code("l"),
    "/",
    core.code("L"),
    " C:",
    core.code("v", { align = "left", min_width = 2 }),
  })

  local mode = nut.mode({
    prefix = " ",
    suffix = " ",
    sep_right = sep.right_lower_triangle_solid(true),
  })

  local stl = Bar("statusline")
  stl:add_item(mode)
  stl:add_item(nut.buf.filename({
    prefix = " ",
    suffix = " ",
    -- hl = { bg = "orange" },
    sep_right = sep.right_lower_triangle_solid(true),
  }))
  stl:add_item(nut.buf.lsp_active_clients({
    hidden = function(item, ctx)
      return item.cache[ctx.bufnr].names and #item.cache[ctx.bufnr].names > 0
    end,
    prefix = " ",
    suffix = " ",
    hl = { bg = "lightcyan", fg = "purple" },
    config = {
      text = {
        ["copilot"] = "",
        ["sumneko_lua"] = false,
        ["null-ls"] = function(ctx)
          local sources = require("null-ls.sources").get_available(vim.bo[ctx.bufnr].filetype)
          local names = {}
          for _, source in ipairs(sources) do
            names[#names + 1] = source.name
          end
          return names
        end,
        ["stylua"] = "StyLua",
        ["luacheck"] = "LuaCheck",
      },
    },
    sep_right = sep.right_lower_triangle_solid(true),
  }))
  stl:add_item(nut.spacer())
  stl:add_item(nut.buf.filetype({
    suffix = " ",
  }))
  stl:add_item(nut.buf.fileencoding({
    prefix = " ",
    suffix = " ",
    hidden = function(_, ctx)
      return vim.bo[ctx.bufnr].fileencoding == "utf-8"
    end,
    hl = { bg = "teal", fg = "fg" },
    sep_left = sep.left_upper_triangle_solid(true),
  }))
  stl:add_item(nut.buf.fileformat({
    prefix = " ",
    suffix = " ",
    hidden = function(_, ctx)
      return vim.bo[ctx.bufnr].fileformat == "unix"
    end,
    config = {
      text = {
        dos = "",
        unix = "",
        mac = "",
      },
    },
    -- hl = { bg = "lightgreen", fg = "black" },
    -- sep_left = sep.left_upper_triangle_solid(true),
  }))
  stl:add_item(nut.buf.diagnostic_count({
    hidden = function(item, ctx)
      return item.cache[ctx.bufnr][item.config.severity] == 0
    end,
    hl = { bg = color.dark.bg4, fg = color.dark.aqua },
    sep_left = sep.left_upper_triangle_solid(true),
    prefix = " ",
    suffix = " ",
    config = {
      error = { prefix = " ", fg = color.dark.red },
      warn = { prefix = " ", fg = color.dark.yellow },
      info = { prefix = " ", fg = color.dark.blue },
      hint = { prefix = " ", fg = color.dark.green },
      sep = sep.space().content,
    },
  }))
  stl:add_item(nut.buf.diagnostic_count({
    hidden = function(item, ctx)
      return item.cache[ctx.bufnr][item.config.severity] == 0
    end,
    hl = { bg = color.dark.red, fg = "black" },
    sep_left = sep.left_upper_triangle_solid(true),
    prefix = "  ",
    suffix = " ",
    config = {
      severity = vim.diagnostic.severity.ERROR,
    },
  }))
  stl:add_item(nut.buf.diagnostic_count({
    hidden = function(item, ctx)
      return item.cache[ctx.bufnr][item.config.severity] == 0
    end,
    hl = { bg = color.dark.yellow, fg = "black" },
    sep_left = sep.left_upper_triangle_solid(true),
    prefix = "  ",
    suffix = " ",
    config = {
      severity = vim.diagnostic.severity.WARN,
    },
  }))
  local word_count_enabled = {
    markdown = true,
    -- lua = true,
  }
  stl:add_item(nut.buf.wordcount({
    hidden = function()
      return not word_count_enabled[vim.bo.filetype]
    end,
    hl = { bg = color.dark.purple },
    sep_left = sep.left_upper_triangle_solid(true),
    config = {
      format = function(count)
        if count < 2 then
          return count .. " Word"
        end
        return count .. " Words"
      end,
    },
  }))
  stl:add_item(nut.ruler({
    hl = mode,
    sep_left = sep.left_upper_triangle_solid(true),
    prefix = " ",
    suffix = " ",
  }))

  local inactive_stl = Bar("statusline")
  inactive_stl:add_item(mode)

  local neotree_stl = Bar("statusline")
  neotree_stl:add_item(Item({
    type = "raw",
    content = "NEO-TREE",
    prefix = " ",
    suffix = " ",
    hl = {
      bg = "fg",
      fg = "bg",
    },
  }))

  local fugitive_stl = Bar("statusline")
  fugitive_stl:add_item(Item({
    type = "raw",
    content = "FUGITIVE",
    prefix = " ",
    suffix = " ",
    hl = {
      bg = "fg",
      fg = "bg",
    },
  }))

  local by_filetype = {
    ["neo-tree"] = neotree_stl,
    ["fugitive"] = fugitive_stl,
  }

  ---@class nougat_setup_statusline_options
  ---@field select? fun(ctx: nui_bar_core_expression_context): NougatBar
  ---@field statusline NougatBar

  ---@param config nougat_setup_statusline_options
  local function setup_statusline(config)
    config = config or {}

    local function generator(ctx)
      return vim.api.nvim_win_call(ctx.winid, function()
        local statusline = config.select and config.select(ctx) or config.statusline
        return statusline:generate(ctx)
      end)
    end

    vim.go.statusline = core.generator(generator, {
      id = "nougat_statusline",
      context = {},
    })
  end

  setup_statusline({
    select = function(ctx)
      return by_filetype[vim.bo[ctx.bufnr].filetype] or ctx.is_focused and stl or inactive_stl
    end,
    statusline = stl,
  })
end

local function setup_minimal_stl()
  local nougat_stl = require("nougat.statusline")
  local core = require("nui.bar.core")
  local Bar = require("nougat.bar")
  local sep = require("nougat.separator")
  local Item = require("nougat.item")
  local nut = {
    buf = {
      diagnostic_count = require("nougat.nut.buf.diagnostic_count").create,
      filename = require("nougat.nut.buf.filename").create,
      fileencoding = require("nougat.nut.buf.fileencoding").create,
      fileformat = require("nougat.nut.buf.fileformat").create,
      filetype = require("nougat.nut.buf.filetype").create,
      wordcount = require("nougat.nut.buf.wordcount").create,
    },
    git = {
      branch = require("nougat.nut.git.branch").create,
    },
    mode = require("nougat.nut.mode").create,
    ruler = require("nougat.nut.ruler").create,
    spacer = require("nougat.nut.spacer").create,
  }

  vim.o.rulerformat = table.concat({
    core.code("p"),
    "%% L:",
    core.code("l"),
    "/",
    core.code("L"),
    " C:",
    core.code("v", { align = "left", min_width = 2 }),
  })

  local stl = Bar("statusline")

  local mode = nut.mode({
    prefix = " ",
    suffix = " ",
    sep_right = sep.right_chevron_solid(true),
  })
  stl:add_item(mode)
  local wordcount_enabled = {
    markdown = true,
  }
  stl:add_item(nut.buf.wordcount({
    hidden = function(_, ctx)
      return not wordcount_enabled[vim.bo[ctx.bufnr].filetype]
    end,
    hl = { bg = "darksalmon", fg = "bg" },
    prefix = " ",
    suffix = " ",
    sep_right = sep.right_chevron_solid(true),
    config = {
      format = function(count)
        return string.format("%d Word%s", count, count > 1 and "s" or "")
      end,
    },
  }))
  stl:add_item(nut.git.branch({
    hl = { bg = "gray", fg = "black" },
    sep_right = sep.right_chevron_solid(true),
    prefix = "  ",
    suffix = " ",
  }))
  stl:add_item(nut.buf.filename({
    prefix = " ",
    suffix = " ",
  }))
  stl:add_item(nut.spacer())

  -- statusline:add_item(nut.buf.diagnostic_count({
  --   hidden = function(item, ctx)
  --     return item.cache[ctx.bufnr][item.config.severity] == 0
  --   end,
  --   hl = { bg = "gray" },
  --   sep_left = sep.left_chevron_solid(true),
  --   prefix = " ",
  --   suffix = " ",
  --   config = {
  --     error = { prefix = " ", fg = "red" },
  --     warn = { prefix = " ", fg = "yellow" },
  --     info = { prefix = " ", fg = "lightblue" },
  --     hint = { prefix = " ", fg = "lightgreen" },
  --   },
  -- }))
  -- statusline:add_item(nut.buf.diagnostic_count({
  --   hidden = function(item, ctx)
  --     return item.cache[ctx.bufnr][item.config.severity] == 0
  --   end,
  --   hl = { bg = color.dark.accent.red },
  --   sep_left = sep.left_chevron_solid(true),
  --   prefix = " ",
  --   suffix = " ",
  --   config = {
  --     severity = vim.diagnostic.severity.ERROR,
  --   },
  -- }))
  stl:add_item(nut.buf.filetype({
    sep_left = sep.left_chevron_solid(true),
    prefix = " ",
    suffix = " ",
  }))
  stl:add_item(nut.buf.fileencoding({
    sep_left = sep.left_chevron_solid(true),
    prefix = " ",
    suffix = " ",
  }))
  stl:add_item(nut.buf.fileformat({
    hl = { bg = "gray", fg = "black" },
    sep_left = sep.left_chevron_solid(true),
    prefix = " ",
    suffix = " ",
    config = {
      text = {
        dos = "",
        unix = "",
        mac = "",
      },
    },
  }))
  stl:add_item(nut.ruler({
    hl = mode,
    sep_left = sep.left_chevron_solid(true),
    prefix = " ",
    suffix = " ",
  }))

  local inactive_stl = Bar("statusline")
  inactive_stl:add_item(mode)

  local neotree_stl = Bar("statusline")
  neotree_stl:add_item(Item({
    content = "NEO-TREE",
    prefix = " ",
    suffix = " ",
    hl = {
      bg = "fg",
      fg = "bg",
    },
  }))

  local fugitive_stl = Bar("statusline")
  fugitive_stl:add_item(Item({
    content = "FUGITIVE",
    prefix = " ",
    suffix = " ",
    hl = {
      bg = "fg",
      fg = "bg",
    },
  }))

  local help_stl = Bar("statusline")
  local help_mode = nut.mode({
    hidden = true,
  })
  help_stl:add_item(help_mode)
  help_stl:add_item(Item({
    hl = help_mode,
    content = "HELP",
    prefix = " ",
    suffix = " ",
  }))
  help_stl:add_item(Item({
    type = "code",
    content = "t",
    prefix = " ",
    suffix = " ",
  }))
  help_stl:add_item(nut.spacer())
  help_stl:add_item(nut.ruler({
    hl = help_mode,
    prefix = " ",
    suffix = " ",
  }))

  local stl_idx = 1
  local stls = {
    stl,
    neotree_stl,
  }

  nougat_stl.setup({
    statusline = stl,
    by_filetype = {
      ["neo-tree"] = neotree_stl,
      ["fugitive"] = fugitive_stl,
      help = help_stl,
      fzf = help_stl,
      TelescopePrompt = help_stl,
    },
    select = function(ctx)
      return ctx.is_focused and stls[stl_idx] or inactive_stl
    end,
  })

  vim.keymap.set("n", "<C-n>", function()
    stl_idx = stl_idx + 1
    if stl_idx > #stls then
      stl_idx = 1
    end
  end)
end

setup_minimal_stl()
