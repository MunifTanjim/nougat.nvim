local Item = require("nougat.item")
local core = require("nougat.core")
local get_hl_name = require("nougat.util.hl").get_hl_name

--luacheck: push no max line length

---@class nougat_nut_lsp_servers_config_config
---@field content? fun(client: lsp.Client, item: NougatItem, ctx: nougat_ctx):nil|string|string[]|{content:string,hl?:nougat_hl_def}|{content:string,hl?:nougat_hl_def}[]
---@field sep? string

---@class nougat_nut_lsp_servers_config: nougat_item_config__function
---@field content? nil
---@field config nougat_nut_lsp_servers_config_config|nougat_nut_lsp_servers_config_config[]

--luacheck: pop

local function get_content(item, ctx)
  ---@type nougat_nut_lsp_servers_config_config
  local config = item:config(ctx)
  local clients = vim.lsp.get_clients({ bufnr = ctx.bufnr })
  local part_idx, parts = 0, {}
  for _, client in ipairs(clients) do
    local content = config.content(client, item, ctx)
    if content then
      if not content[1] then
        content = { content }
      end
      for idx = 1, #content do
        local part = content[idx]
        if type(part) == "table" then
          if part.hl then
            part_idx = core.add_highlight(get_hl_name(part.hl, ctx.hl), nil, parts, part_idx)
          end
          part_idx = part_idx + 1
          parts[part_idx] = part.content
          if part.hl then
            part_idx = core.add_highlight(get_hl_name(item.hl or ctx.hl, ctx.hl), nil, parts, part_idx)
          end
        else
          part_idx = part_idx + 1
          parts[part_idx] = part
        end
        part_idx = part_idx + 1
        parts[part_idx] = config.sep
      end
    end
  end
  return table.concat(parts, nil, 1, part_idx - 1)
end

local mod = {}

---@param opts nougat_nut_lsp_servers_config
function mod.create(opts)
  local config = vim.tbl_deep_extend("force", {
    content = function(client)
      return client.name
    end,
    sep = " ",
  }, opts.config or {})
  ---@cast config nougat_nut_lsp_servers_config_config|nougat_nut_lsp_servers_config_config[]

  local item = Item({
    init = opts.init,
    priority = opts.priority,
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = get_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = config,
    on_click = opts.on_click,
    context = opts.context,
    ctx = opts.ctx,
    cache = {
      scope = "buf",
      clear = {
        "LspAttach",
        "LspDetach",
      },
    },
  })

  return item
end

return mod
