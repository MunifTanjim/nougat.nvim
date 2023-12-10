local core = require("nougat.core")
local get_hl_def = require("nougat.util.hl").get_hl_def
local get_hl_name = require("nougat.util.hl").get_hl_name

---@class nougat_lazy_item_hl
---@field c? false|nougat_hl_def content (`false` means `content` w/o hl)
---@field c_idx? integer content index
---@field sl? false|nougat_separator_hl_def sep left (`false` means `sep_left` w/o hl)
---@field sl_idx? integer sep left index
---@field sr? false|nougat_separator_hl_def sep right (`false` means `sep_right` w/o hl)
---@field sr_idx? integer sep right index
---@field fc_idx? integer first child index
---@field lc_idx? integer last child index
---@field fb? nougat_hl_def fallback
---@field x? boolean skip highlight

-- re-used table
---@type nougat_hl_def
local o_sep_hl = {}

---@param hl nougat_hl_def|nougat_separator_hl_def
---@param far_hl? nougat_hl_def
---@param near_hl? nougat_hl_def
---@param curr_hl? nougat_hl_def
---@param next_hl? nougat_hl_def
---@return nougat_hl_def sep_hl
local function prepare_sep_left_hl(hl, far_hl, near_hl, curr_hl, next_hl)
  o_sep_hl.bg = hl.bg or curr_hl and curr_hl.bg or "bg"
  o_sep_hl.fg = hl.fg or curr_hl and curr_hl.bg or next_hl and next_hl.bg or "bg"

  if o_sep_hl.bg == -1 then
    o_sep_hl.bg = near_hl and near_hl.bg or far_hl and far_hl.bg or nil
  elseif o_sep_hl.fg == -1 then
    o_sep_hl.fg = near_hl and near_hl.bg or far_hl and far_hl.bg or nil
  end

  return o_sep_hl
end

---@param hl nougat_hl_def|nougat_separator_hl_def
---@param prev_hl? nougat_hl_def
---@param curr_hl? nougat_hl_def
---@param near_hl? nougat_hl_def
---@param far_hl? nougat_hl_def
---@return nougat_hl_def sep_hl
local function prepare_sep_right_hl(hl, prev_hl, curr_hl, near_hl, far_hl)
  o_sep_hl.bg = hl.bg or curr_hl and curr_hl.bg or "bg"
  o_sep_hl.fg = hl.fg or prev_hl and prev_hl.bg or curr_hl and curr_hl.bg or "bg"

  if o_sep_hl.bg == 1 then
    o_sep_hl.bg = near_hl and near_hl.bg or far_hl and far_hl.bg or nil
  elseif o_sep_hl.fg == 1 then
    o_sep_hl.fg = near_hl and near_hl.bg or far_hl and far_hl.bg or nil
  end

  return o_sep_hl
end

---@param bar NougatBar
---@param ctx nougat_core_expression_context
---@return nougat_hl_def bar_hl
local function resolve_bar_hl(bar, ctx)
  local highlight = bar.hl

  if type(highlight) == "function" then
    highlight = highlight(bar, ctx)
  end

  if highlight == 0 then
    local hl_name = bar._hl_name[ctx.is_focused]
    return get_hl_def(hl_name)
  end

  if type(highlight) == "table" then
    return highlight
  end

  if type(highlight) == "string" then
    return get_hl_def(highlight)
  end

  if type(highlight) == "number" then
    return get_hl_def("User" .. highlight)
  end

  error("missing bar highlight")
end

---@param hl? nougat_item_hl
---@param item NougatItem
---@param ctx nougat_bar_ctx
---@return nougat_hl_def|false item_hl
local function resolve_item_hl(hl, item, ctx)
  local highlight = hl

  if type(highlight) == "function" then
    highlight = highlight(item, ctx)
  end

  if not highlight or type(highlight) == "table" then
    return highlight or false
  end

  if type(highlight) == "string" then
    return get_hl_def(highlight)
  end

  if type(highlight) == "number" then
    return get_hl_def("User" .. highlight)
  end

  return false
end

local mod = {
  resolve_bar_hl = resolve_bar_hl,
  resolve_item_hl = resolve_item_hl,
}

---@param ctx nougat_bar_ctx
---@param fallback_hl nougat_hl_def
function mod.prepare_highlights(ctx, fallback_hl)
  local hls = ctx.hls
  local hl_idx = hls.len

  local parts = ctx.parts

  for idx = 1, hl_idx do
    local hl = hls[idx]

    if hl.sl then
      -- for parent:
      -- - last child of prev sibling
      -- - or prev sibling
      -- for first child:
      -- - parent
      -- for children:
      -- - prev sibling
      local near_prev_hl = idx > 1 and hls[idx - 1] or nil
      -- for first child:
      -- - prev sibling of parent
      local far_prev_hl = ((near_prev_hl and idx == near_prev_hl.fc_idx) and idx > 2) and hls[idx - 2] or nil
      -- for parent
      -- - first child
      local near_next_hl = hl.fc_idx and hls[hl.fc_idx] or nil

      core.add_highlight(
        get_hl_name(
          prepare_sep_left_hl(
            hl.sl,
            far_prev_hl and (far_prev_hl.c or far_prev_hl.fb) or nil,
            near_prev_hl and (near_prev_hl.c or near_prev_hl.fb) or nil,
            hl.c,
            near_next_hl and (near_next_hl.c or near_next_hl.fb) or nil
          ),
          hl.fb or fallback_hl
        ),
        nil,
        parts,
        hl.sl_idx
      )
    end

    if hl.c then
      core.add_highlight(get_hl_name(hl.c, hl.fb or fallback_hl), nil, parts, hl.c_idx)
    end

    if hl.sr then
      -- for parent:
      -- - last child
      local prev_hl = hl.lc_idx and hls[hl.lc_idx] or nil
      -- for parent:
      -- - next sibling
      -- for children:
      -- - next sibling
      -- for last child:
      -- - next sibling of parent
      local near_next_hl = hl.lc_idx and (hl.lc_idx + 1 <= hl_idx and hls[hl.lc_idx + 1])
        or idx + 1 <= hl_idx and hls[idx + 1]
        or nil
      -- for parent:
      -- - first child of next sibling
      -- for last child:
      -- - first child of next sibling of parent
      local far_next_hl = (near_next_hl and near_next_hl.fc_idx) and hls[near_next_hl.fc_idx] or nil

      core.add_highlight(
        get_hl_name(
          prepare_sep_right_hl(
            hl.sr,
            prev_hl and (prev_hl.c or prev_hl.fb) or nil,
            hl.c,
            near_next_hl and (near_next_hl.c or near_next_hl.fb) or nil,
            far_next_hl and (far_next_hl.c or far_next_hl.fb) or nil
          ),
          hl.fb or fallback_hl
        ),
        nil,
        parts,
        hl.sr_idx
      )
    end
  end
end

return mod
