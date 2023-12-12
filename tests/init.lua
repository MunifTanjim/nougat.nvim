local root_dir = vim.fn.fnamemodify(vim.trim(vim.fn.system("git rev-parse --show-toplevel")), ":p"):gsub("/$", "")

package.path = string.format(
  table.concat({
    "%s",
    "%s/?.lua",
    "%s/?/init.lua",
  }, ";"),
  package.path,
  root_dir,
  root_dir
)

vim.opt.packpath:prepend(root_dir .. "/.tests/site")

vim.cmd([[
  packadd plenary.nvim
]])

vim.cmd([[
  hi StatusLine guibg=#ffcd00 guifg=#663399

  hi DiagnosticError guifg=#ff0000
  hi DiagnosticWarn guifg=#ffff00
  hi DiagnosticInfo guifg=#00ff00
  hi DiagnosticHint guifg=#00ffff
]])
