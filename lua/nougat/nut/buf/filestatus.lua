local Item = require("nougat.item")
local buf_cache = require("nougat.cache.buffer")

--luacheck: push no max line length

---@class nougat.nut.buf.filestatus_config.config
---@field modified? false|string
---@field nomodifiable? false|string
---@field readonly? false|string
---@field sep? string

---@class nougat.nut.buf.filestatus_config: nougat_item_config__function
---@field config? nougat.nut.buf.filestatus_config.config|nougat.nut.buf.filestatus_config.config[]
---@field content? nil

--luacheck: pop

-- re-used table
local o_parts = { len = 0 }

local function get_content(item, ctx)
  local bufnr = ctx.bufnr
  local config = item:config(ctx)

  local part_idx = 0

  if config.readonly and buf_cache.get("readonly", bufnr) then
    part_idx = part_idx + 1
    o_parts[part_idx] = config.readonly
    part_idx = part_idx + 1
    o_parts[part_idx] = config.sep
  end
  if config.modified and buf_cache.get("modified", bufnr) then
    part_idx = part_idx + 1
    o_parts[part_idx] = config.modified
    part_idx = part_idx + 1
    o_parts[part_idx] = config.sep
  end
  if config.nomodifiable and not buf_cache.get("modifiable", bufnr) then
    part_idx = part_idx + 1
    o_parts[part_idx] = config.nomodifiable
    part_idx = part_idx + 1
    o_parts[part_idx] = config.sep
  end

  o_parts.len = part_idx > 0 and part_idx - 1 or part_idx

  return o_parts
end

local mod = {}

---@param config nougat.nut.buf.filestatus_config
function mod.create(config)
  buf_cache.enable("modified")
  buf_cache.enable("modifiable")
  buf_cache.enable("readonly")

  local item = Item({
    priority = config.priority,
    hidden = config.hidden,
    hl = config.hl,
    sep_left = config.sep_left,
    prefix = config.prefix,
    content = get_content,
    suffix = config.suffix,
    sep_right = config.sep_right,
    config = vim.tbl_extend("force", {
      modified = "+",
      nomodifiable = "-",
      readonly = "RO",
      sep = ",",
    }, config.config or {}),
    on_click = config.on_click,
    context = config.context,
  })

  return item
end

return mod
