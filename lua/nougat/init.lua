local mod = {}

function mod.version()
  local dir = vim.fn.fnamemodify(vim.api.nvim_get_runtime_file("lua/nougat/init.lua", false)[1], ":h:h:h")
  local version = vim.fn.systemlist(string.format("cd %s && git rev-parse HEAD", dir))[1]
  return version
end

return mod
