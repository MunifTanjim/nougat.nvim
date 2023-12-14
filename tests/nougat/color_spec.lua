pcall(require, "luacov")

local color = require("nougat.color")

local t = require("tests.util")

describe("nougat.color", function()
  ---@type nougat.color
  local c

  local loaded_theme = {}

  local function load_color_theme(name, background, theme)
    vim.g.colors_name = name

    local module_name = "nougat.color." .. name

    package.loaded[module_name] = theme or loaded_theme[module_name]
    loaded_theme[module_name] = package.loaded[module_name]

    if theme then
      vim.api.nvim_exec_autocmds("ColorScheme", { pattern = name })
    elseif background and vim.go.background ~= background then
      vim.go.background = background
      vim.api.nvim_exec_autocmds("ColorScheme", { pattern = name })
    end
  end

  local function assert_color(theme_color, expected_value)
    local hl_name = color.get_hl_name({ bg = theme_color }, {})
    local hl_def = color.get_hl_def(hl_name)
    t.eq(hl_def.bg, expected_value)
  end

  before_each(function()
    require("nougat.store")._clear()

    vim.g.colors_name = ""
    vim.go.background = "dark"

    c = color.get()
  end)

  after_each(function()
    for name in pairs(loaded_theme) do
      package.loaded[name] = nil
      loaded_theme[name] = nil
    end
  end)

  describe(".get", function()
    it("has defaults", function()
      local colors = { "bg", "red", "green", "yellow", "blue", "magenta", "cyan", "fg" }
      local shades = { "bg0", "bg1", "bg2", "bg3", "bg4", "fg0", "fg1", "fg2", "fg3", "fg4" }

      for key, val in pairs(t.tbl_pick(c, colors)) do
        t.eq(val, "." .. key)
      end

      for key, val in pairs(t.tbl_pick(c.accent, colors)) do
        t.eq(val, ".accent." .. key)
      end

      for key, val in pairs(t.tbl_pick(c, shades)) do
        t.eq(val, "." .. key)
      end

      local hl_name = color.get_hl_name({ bg = c.red, fg = c.yellow }, {})
      local hl_def = color.get_hl_def(hl_name)
      t.eq(hl_def.bg, "#ff0000")
      t.eq(hl_def.fg, "#ffff00")
    end)

    it("works for light background", function()
      load_color_theme("nougat", "dark", {
        get = function()
          return {}
        end,
      })

      assert_color(c.accent.bg, "#a9a9a9")
      assert_color(c.accent.fg, "#d3d3d3")

      load_color_theme("ColorScheme", "light")

      assert_color(c.accent.bg, "#d3d3d3")
      assert_color(c.accent.fg, "#a9a9a9")
    end)

    it("works for current colorscheme", function()
      load_color_theme("nougat", vim.go.background, {
        get = function()
          return {
            red = "#dc143c",
            yellow = "#ffcd00",
          }
        end,
      })

      local hl_name, hl_def

      hl_name = color.get_hl_name({ bg = c.red, fg = c.yellow }, {})
      hl_def = color.get_hl_def(hl_name)
      t.eq(hl_def.bg, "#dc143c")
      t.eq(hl_def.fg, "#ffcd00")
    end)
  end)

  describe(".get_hl_def", function()
    local hl_name = "test_nougat.color_get_hl_def"

    it("can handle reverse=true", function()
      vim.api.nvim_set_hl(0, hl_name, { bg = "#ff0000", fg = "#ffff00", reverse = true })
      local hl_def = color.get_hl_def(hl_name)
      t.eq(hl_def.bg, "#ffff00")
      t.eq(hl_def.fg, "#ff0000")
    end)

    it("caches hl def", function()
      t.spy(vim.api, "nvim_get_hl_by_name")

      vim.api.nvim_set_hl(0, hl_name, { bg = "#ff0000", fg = "#ffff00", reverse = true })
      local hl_def = color.get_hl_def(hl_name)

      t.spy(vim.api.nvim_get_hl_by_name).was.called(1)

      t.ref(color.get_hl_def(hl_name), hl_def)

      t.spy(vim.api.nvim_get_hl_by_name).was.called(1)
    end)
  end)

  describe(".get_hl_name", function()
    it("supports 'bg' and 'fg'", function()
      local hl_name = color.get_hl_name({ bg = "bg", fg = "fg" }, { bg = "red", fg = "yellow" })
      local hl_def = color.get_hl_def(hl_name)
      t.eq(hl_def.bg, "#ff0000")
      t.eq(hl_def.fg, "#ffff00")
    end)
  end)
end)
