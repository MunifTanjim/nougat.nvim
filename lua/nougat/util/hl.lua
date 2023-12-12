--luacov: disable
local get_hl_def = require("nougat.color").get_hl_def
local get_hl_name = require("nougat.color").get_hl_name

local mod = {
  get_hl_def = function(...)
    vim.deprecate("require('nougat.util.hl').get_hl_def", "require('nougat.color').get_hl_def", "0.5.0", "nougat.nvim")
    return get_hl_def(...)
  end,
  get_hl_name = function(...)
    vim.deprecate(
      "require('nougat.util.hl').get_hl_name",
      "require('nougat.color').get_hl_name",
      "0.5.0",
      "nougat.nvim"
    )
    return get_hl_name(...)
  end,
}

return mod
--luacov: enable
