local Item = require("nougat.item")

local buffer_cache = require("nougat.cache.buffer")

buffer_cache.enable("modified")

-- re-used table
local o_parts = { len = 0 }

local function get_content(item, ctx)
  local bufnr = ctx.bufnr
  local config = item:config(ctx)

  local part_idx = 0

  local buf_cache = item.buf_cache[bufnr]

  if config.readonly and vim.api.nvim_buf_get_option(bufnr, "readonly") then
    part_idx = part_idx + 1
    o_parts[part_idx] = config.readonly
    part_idx = part_idx + 1
    o_parts[part_idx] = config.sep
  end
  if config.modified and buf_cache.modified then
    part_idx = part_idx + 1
    o_parts[part_idx] = config.modified
    part_idx = part_idx + 1
    o_parts[part_idx] = config.sep
  end
  if config.nomodifiable and not vim.api.nvim_buf_get_option(bufnr, "modifiable") then
    part_idx = part_idx + 1
    o_parts[part_idx] = config.nomodifiable
    part_idx = part_idx + 1
    o_parts[part_idx] = config.sep
  end

  o_parts.len = part_idx > 0 and part_idx - 1 or part_idx

  return o_parts
end

local mod = {}

function mod.create(opts)
  local item = Item({
    priority = opts.priority,
    hidden = opts.hidden,
    hl = opts.hl,
    sep_left = opts.sep_left,
    prefix = opts.prefix,
    content = get_content,
    suffix = opts.suffix,
    sep_right = opts.sep_right,
    config = vim.tbl_extend("force", {
      modified = "+",
      nomodifiable = "-",
      readonly = "RO",
      sep = ",",
    }, opts.config or {}),
    on_click = opts.on_click,
    context = opts.context,
  })

  item.buf_cache = buffer_cache.store

  return item
end

return mod
