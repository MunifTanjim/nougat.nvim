local Item = require("nougat.item")

--luacheck: push no max line length

---@class nougat.nut.buf.fileencoding_config.config
---@field text? table<'bomb'|'noendofline', string?>

---@class nougat.nut.buf.fileencoding_config: nougat_item_config__function
---@field cache? nil
---@field config? nougat.nut.buf.fileencoding_config.config|nougat.nut.buf.fileencoding_config.config[]
---@field content? nil

--luacheck: pop

---@param item NougatItem
---@param ctx nougat_bar_ctx
local function content(item, ctx)
  local text = item:config(ctx).text
  return table.concat({
    vim.api.nvim_buf_get_option(ctx.bufnr, "fileencoding"),
    vim.api.nvim_buf_get_option(ctx.bufnr, "bomb") and text.bomb or "",
    vim.api.nvim_buf_get_option(ctx.bufnr, "endofline") and "" or text.noendofline,
  })
end

local mod = {}

---@param config nougat.nut.buf.fileencoding_config
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
      text = {
        bomb = "[BOM]",
        noendofline = "[!EOL]",
      },
    }, config.config or {}),
    on_click = config.on_click,
    context = config.context,
  })

  return item
end

return mod
