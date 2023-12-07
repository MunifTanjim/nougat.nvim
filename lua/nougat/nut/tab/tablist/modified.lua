local Item = require("nougat.item")
local buf_cache = require("nougat.cache.buffer")

--luacheck: push no max line length

---@class nougat.nut.tab.tablist.modified_config.config
---@field text string

---@class nougat.nut.tab.tablist.modified_config: nougat_item_config__function
---@field config? nougat.nut.tab.tablist.modified_config.config|nougat.nut.tab.tablist.modified_config.config[]
---@field content? nil
---@field hidden? nil
---@field prepare? nil

--luacheck: pop

local function get_content(item, ctx)
  return item:config(ctx).text
end

local function hidden(item, ctx)
  return not item:cache(ctx)
end

local mod = {}

---@param config nougat.nut.tab.tablist.modified_config
function mod.create(config)
  buf_cache.enable("modified")

  local item = Item({
    priority = config.priority,
    hidden = hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = get_content,
    suffix = config.suffix,
    sep_right = config.sep_right,
    config = vim.tbl_deep_extend("force", {
      text = "+",
    }, config.config or {}),
    on_click = config.on_click,
    context = config.context,
    cache = {
      scope = "buf",
      ---@param ctx nougat.nut.tab.tablist_ctx
      get = function(store, ctx)
        return store[ctx.tab.bufnr].modified
      end,
      store = buf_cache.store,
    },
  })

  return item
end

return mod
