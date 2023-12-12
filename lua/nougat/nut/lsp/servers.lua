local Item = require("nougat.item")
local core = require("nougat.core")
local get_hl_name = require("nougat.color").get_hl_name

--luacheck: push no max line length

---@class nougat.nut.lsp.servers_config.config
---@field content? fun(client: lsp.Client, item: NougatItem, ctx: nougat_bar_ctx):nil|string|string[]|{content:string,hl?:nougat_hl_def}|{content:string,hl?:nougat_hl_def}[]
---@field sep? string

---@class nougat_nut_lsp_servers_config: nougat_item_config__function
---@field cache?: nil
---@field config? nougat.nut.lsp.servers_config.config|nougat.nut.lsp.servers_config.config[]
---@field content? nil
---@field hl? nougat_hl_def

--luacheck: pop

---@param item NougatItem
---@param ctx nougat_bar_ctx
local function get_content(item, ctx)
  ---@type nougat.nut.lsp.servers_config.config
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
            local item_hl = item.hl or ctx.hl
            ---@cast item_hl nougat_hl_def
            part_idx = core.add_highlight(get_hl_name(item_hl --[[@as nougat_hl_def]], ctx.hl), nil, parts, part_idx)
          end
        else
          part_idx = part_idx + 1
          parts[part_idx] = part
        end
      end
      part_idx = part_idx + 1
      parts[part_idx] = config.sep
    end
  end
  return table.concat(parts, nil, 1, part_idx - 1)
end

local mod = {}

---@param config nougat_nut_lsp_servers_config
function mod.create(config)
  config = config or {}

  local item = Item({
    init = config.init,
    priority = config.priority,
    hidden = config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = get_content,
    suffix = config.suffix,
    sep_right = config.sep_right,
    config = vim.tbl_deep_extend("force", {
      content = function(client)
        return client.name
      end,
      sep = " ",
    }, config.config or {}),
    on_click = config.on_click,
    context = config.context,
    ctx = config.ctx,
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
