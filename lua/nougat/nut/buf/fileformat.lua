local Item = require("nougat.item")

--luacheck: push no max line length

---@class nougat.nut.buf.fileformat_config.config
---@field text? table<'dos'|'mac'|'unix', string?>

---@class nougat.nut.buf.fileformat_config: nougat_item_config__function
---@field cache? nil
---@field config? nougat.nut.buf.fileformat_config.config|nougat.nut.buf.fileformat_config.config[]
---@field content? nil

--luacheck: pop

---@param item NougatItem
---@param ctx nougat_bar_ctx
local function content(item, ctx)
  local fileformat = vim.api.nvim_buf_get_option(ctx.bufnr, "fileformat")
  return item:config(ctx).text[fileformat] or fileformat
end

local mod = {}

---@param config nougat.nut.buf.fileformat_config
function mod.create(config)
  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = content,
    suffix = config.suffix,
    sep_right = config.sep_right,
    config = vim.tbl_extend("force", {
      text = {},
    }, config.config or {}),
    on_click = config.on_click,
    context = config.context,
    cache = {
      scope = "buf",
      clear = "BufWritePost",
    },
  })

  return item
end

return mod
