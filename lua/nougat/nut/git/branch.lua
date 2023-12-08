local Item = require("nougat.item")

--luacheck: push no max line length

---@class nougat.nut.git.branch_config: nougat_item_config__function
---@field cache? nil
---@field config? { provider: 'auto'|'fugitive'|'gitsigns' }
---@field content? nil

--luacheck: pop

local get_content = {
  fugitive = function()
    return vim.fn.FugitiveHead(7)
  end,
  gitsigns = function(_, ctx)
    return vim.fn.getbufvar(ctx.bufnr, "gitsigns_head", false)
  end,
}

local mod = {}

---@param config? nougat.nut.git.branch_config
function mod.create(config)
  config = config or {}

  local provider = config.config and config.config.provider or "auto"

  if provider == "auto" then
    if vim.api.nvim_get_runtime_file("plugin/fugitive.vim", false)[1] then
      provider = "fugitive"
    elseif pcall(require, "gitsigns") then
      provider = "gitsigns"
    else
      provider = ""
    end
  end

  local content = get_content[provider]

  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = content,
    suffix = config.suffix,
    sep_right = config.sep_right,
    on_click = config.on_click,
    context = config.context,
    cache = {
      scope = "buf",
      clear = "BufModifiedSet",
    },
  })

  if type(content) == "nil" then
    item.hidden = true
  end

  return item
end

return mod
