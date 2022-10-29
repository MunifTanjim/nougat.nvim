local core = require("nui.bar.core")

local mod = {}

mod.config = {}

local function generator(ctx)
  local statusline = mod.config.statusline
  local select = mod.config.select

  return vim.api.nvim_win_call(ctx.winid, function()
    local stl = select and select(ctx) or statusline
    return stl:generate(ctx)
  end)
end

local function generator_by_filetype(ctx)
  local by_filetype = mod.config.by_filetype

  return vim.api.nvim_win_call(ctx.winid, function()
    local stl = by_filetype[vim.bo.filetype]
    return stl and stl:generate(ctx) or ""
  end)
end

function mod.setup(options)
  mod.config = vim.tbl_deep_extend("force", mod.config, options)

  if mod.config.by_filetype then
    local stl_by_filetype = core.generator(generator_by_filetype, {
      id = "nougat.wo.statusline.by_filetype",
      context = {},
    })
    local augroup = vim.api.nvim_create_augroup("nougat.statusline.by_filetype", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      callback = function(info)
        if mod.config.by_filetype[info.match] then
          vim.schedule(function()
            vim.api.nvim_buf_call(info.buf, function()
              vim.wo.statusline = stl_by_filetype
            end)
          end)
        end
      end,
    })
  end

  vim.go.statusline = core.generator(generator, {
    id = "nougat.go.statusline",
    context = {},
  })
end

return mod
