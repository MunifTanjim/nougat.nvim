local Item = require("nougat.item")

local get_content = {
  fugitive = function()
    return vim.fn.FugitiveHead()
  end,
  gitsigns = function(_, ctx)
    return vim.b[ctx.bufnr].gitsigns_head
  end,
  [""] = function() end,
}

local mod = {}

function mod.create(opts)
  local config = vim.tbl_deep_extend("force", {
    provider = "auto",
  }, opts.config or {})

  if config.provider == "auto" then
    if pcall(require, "gitsigns") then
      config.provider = "gitsigns"
    elseif vim.api.nvim_get_runtime_file("plugin/fugitive.vim", false)[1] then
      config.provider = "fugitive"
    else
      config.provider = ""
    end
  end

  local item = Item({
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = get_content[config.provider],
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    on_click = opts.on_click,
    context = opts.context,
  })

  return item
end

return mod
