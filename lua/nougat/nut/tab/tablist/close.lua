local core = require("nougat.core")
local Item = require("nougat.item")

--luacheck: push no max line length

---@class nougat.nut.tab.tablist.close_config.config
---@field text string

---@class nougat.nut.tab.tablist.close_config: nougat_item_config__function
---@field config? nougat.nut.tab.tablist.close_config.config|nougat.nut.tab.tablist.close_config.config[]
---@field content? nil
---@field prepare? nil

--luacheck: pop

-- re-used table
local o_label_opts = { tabnr = nil, close = true }

local function get_content(item, ctx)
  local config = item:config(ctx)
  o_label_opts.tabnr = ctx.tab.tabnr
  return core.label(config.text, o_label_opts)
end

local mod = {}

---@param config nougat.nut.tab.tablist.close_config
function mod.create(config)
  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = get_content,
    suffix = config.suffix,
    sep_right = config.sep_right,
    config = vim.tbl_deep_extend("force", {
      text = "X",
    }, config.config or {}),
    on_click = config.on_click,
    context = config.context,
  })

  return item
end

return mod
