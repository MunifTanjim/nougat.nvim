local core = require("nougat.core")
local iu = require("nougat.item.util")
local ic = require("nougat.item.cache")
local create_store = require("nougat.cache").create_store
local u = require("nougat.util")

--luacheck: push no max line length

---@alias nougat_item_content string|string[]|NougatItem[]|(fun(self: NougatItem, ctx: nougat_bar_ctx):nil|string|string[]|NougatItem[])
---@alias nougat_item_hl integer|string|nougat_hl_def|(fun(self: NougatItem, ctx: nougat_bar_ctx): integer|string|nougat_hl_def)
---@alias nougat_item_affix string[]|(fun(item: NougatItem, ctx: nougat_bar_ctx):string)
---@alias nougat_item_hidden boolean|(fun(self: NougatItem, ctx: nougat_bar_ctx):boolean)

---@alias nougat_item_config.cache.clear__event string|string[]
---@alias nougat_item_config.cache.clear__get_id (fun(info: table): integer)
---@alias nougat_item_config.cache.clear nougat_item_config.cache.clear__event | { [1]: nougat_item_config.cache.clear__event, [2]?: nougat_item_config.cache.clear__get_id } | { [1]: nougat_item_config.cache.clear__event, [2]?: nougat_item_config.cache.clear__get_id }[]

---@class nougat_item_config.cache
---@field name? string
---@field get? fun(store: NougatCacheStore, ctx: nougat_bar_ctx):table
---@field scope? 'buf'|'win'|'tab'
---@field initial_value? table
---@field store? NougatCacheStore
---@field clear? nougat_item_config.cache.clear

---@class nougat_item_config__nil
---@field init? fun(self: NougatItem): nil
---@field prepare? fun(self: NougatItem, ctx: nougat_bar_ctx):nil
---@field hidden? nougat_item_hidden|NougatItem
---@field hl? nougat_item_hl|NougatItem
---@field content? string|string[]|NougatItem[]
---@field sep_left? nougat_separator|nougat_separator[]
---@field sep_right? nougat_separator|nougat_separator[]
---@field prefix? string|nougat_item_affix
---@field suffix? string|nougat_item_affix
---@field context? nougat_core_item_options_context
---@field on_click? string|nougat_core_click_handler
---@field priority? integer
---@field ctx? table

---@class nougat_item_config__core: nougat_item_config__nil
---@field align? 'left'|'right'
---@field leading_zero? boolean
---@field max_width? integer
---@field min_width? integer

---@class nougat_item_config__code: nougat_item_config__core
---@field type 'code'
---@field content string

---@class nougat_item_config__vim_expr: nougat_item_config__core
---@field type 'vim_expr'
---@field content string
---@field expand? boolean

---@class nougat_item_config__lua_expr: nougat_item_config__core
---@field type 'lua_expr'
---@field content number|string|nougat_core_expression_fn
---@field expand? boolean

---@class nougat_item_config__literal: nougat_item_config__core
---@field type 'literal'
---@field content boolean|number|string

---@class nougat_item_config__tab_label: nougat_item_config__nil
---@field type 'tab_label'
---@field content number|string
---@field close? boolean
---@field tabnr? integer

---@class nougat_item_config__function: nougat_item_config__nil
---@field content fun(self: NougatItem, ctx: nougat_bar_ctx):nil|string|string[]|NougatItem[]
---@field config? table|table[]
---@field cache? nougat_item_config.cache

---@alias nougat_item_config nougat_item_config__nil|nougat_item_config__code|nougat_item_config__vim_expr|nougat_item_config__lua_expr|nougat_item_config__literal|nougat_item_config__tab_label|nougat_item_config__function

--luacheck: pop

local o_clickable_parts = { len = 0 }

---@param item NougatItem
---@param ctx nougat_bar_ctx
local function clickable_fn_content_processor(item, ctx)
  local part_idx = core.add_clickable("", {
    id = item._on_click_id,
    context = item._on_click_context or item,
    on_click = item._on_click,
  }, o_clickable_parts, 0)

  local end_delim = o_clickable_parts[part_idx]

  o_clickable_parts.len = part_idx - 2

  local ctx_parts = ctx.parts
  ctx.parts = o_clickable_parts
  local content = item:_clickable_fn_content(ctx) or ""
  ctx.parts = ctx_parts

  if #content > 0 then
    o_clickable_parts[part_idx - 1] = content
  else -- no content returned
    if part_idx == o_clickable_parts.len then -- no parts added
      -- discard clickable parts
      part_idx = part_idx - 7
    else
      part_idx = o_clickable_parts.len
      o_clickable_parts[part_idx + 1] = end_delim
    end
  end

  return table.concat(o_clickable_parts, nil, 1, part_idx)
end

local item_hidden_processor = {
  boolean = function(item)
    return item._item_hidden.hidden
  end,
  ["function"] = function(item, ctx)
    return item._item_hidden:hidden(ctx)
  end,
}

---@param item NougatItem
---@param ctx nougat_bar_ctx
local function item_hl_processor(item, ctx)
  return type(item._item_hl.hl) == "function" and item._item_hl:hl(ctx) or item._item_hl.hl
end

local get_next_id = u.create_id_generator()

---@param class NougatItem
---@param config nougat_item_config
local function init(class, config)
  ---@class NougatItem
  local self = setmetatable({}, { __index = class })

  self.id = get_next_id()

  self.ctx = config.ctx or {}

  self.hl = config.hl
  if type(config.hl) == "table" and config.hl.id then
    self._item_hl = config.hl --[[@as NougatItem]]
    self.hl = item_hl_processor
  end

  self.sep_left = iu.normalize_sep(-1, config.sep_left)
  self.prefix = type(config.prefix) == "string" and { config.prefix } or config.prefix
  self.suffix = type(config.suffix) == "string" and { config.suffix } or config.suffix
  self.sep_right = iu.normalize_sep(1, config.sep_right)

  self.prepare = config.prepare

  self.hidden = config.hidden
  if type(self.hidden) == "table" then
    self._item_hidden = self.hidden --[[@as NougatItem]]
    self.hidden = item_hidden_processor[type(self._item_hidden.hidden)]
  end

  self.priority = config.priority

  if config.type == "code" then
    ---@cast config nougat_item_config__code
    self.content = core.code(config.content, {
      align = config.align,
      leading_zero = config.leading_zero,
      min_width = config.min_width,
      max_width = config.max_width,
    })
  elseif config.type == "vim_expr" then
    ---@cast config nougat_item_config__vim_expr
    self.content = core.expression(config.content, {
      align = config.align,
      expand = config.expand,
      is_vimscript = true,
      leading_zero = config.leading_zero,
      min_width = config.min_width,
      max_width = config.max_width,
    })
  elseif config.type == "lua_expr" then
    ---@cast config nougat_item_config__lua_expr
    self.content = core.expression(config.content, {
      id = self.id .. "_expression_fn",
      align = config.align,
      context = config.context or self,
      expand = config.expand,
      leading_zero = config.leading_zero,
      min_width = config.min_width,
      max_width = config.max_width,
    })
  elseif config.type == "literal" then
    ---@cast config nougat_item_config__literal
    local has_opts = config.align or config.leading_zero or config.min_width or config.max_width
    self.content = core.literal(config.content, has_opts and {
      align = config.align,
      leading_zero = config.leading_zero,
      min_width = config.min_width,
      max_width = config.max_width,
    } or nil)
  elseif config.type == "tab_label" then
    ---@cast config nougat_item_config__tab_label
    self.content = core.label(config.content, {
      close = config.close,
      tabnr = config.tabnr,
    })
  else
    ---@cast config nougat_item_config__nil|nougat_item_config__function
    self.content = config.content
  end

  if config.on_click then
    if type(self.content) == "function" then
      self._clickable_fn_content = self.content
      self._on_click = config.on_click
      self._on_click_id = self.id .. "_click_handler"
      self._on_click_context = config.context
      self.content = clickable_fn_content_processor
    else
      ---@diagnostic disable-next-line: param-type-mismatch
      self.content = core.clickable(self.content, {
        id = self.id .. "_click_handler",
        context = config.context or self,
        on_click = config.on_click,
      })
    end
  end

  if config.cache then
    ---@type nougat_item_config.cache
    local cache = config.cache

    if cache.store then
      self._cache_store = cache.store
    elseif cache.scope then
      self._cache_store = create_store(cache.scope, cache.name or self.id .. "_cache_store", cache.initial_value)
    end
    assert(type(self._cache_store) == "table", "one of cache.scope or cache.store is required")

    if cache.get then
      self._cache_get = cache.get
      self.cache = ic.cache_getter._wrap_fn
    elseif cache.scope then
      self.cache = ic.cache_getter[cache.scope]
    end
    assert(type(self.cache) == "function", "one of cache.get or cache.scope is required")

    self._cache_type = (cache.store or cache.initial_value) and "manual" or "auto"
    if self._cache_type == "auto" and type(self.content) == "function" then
      self._cached_fn_content = self.content
      self.content = ic.cached_fn_content_processor
    end

    if cache.clear then
      ic.process_item_cache_clear(cache.clear, self._cache_store, cache.scope)
    end
  end

  if type(self.content) == "table" then
    self.content.len = #self.content
    if not iu.has_priority_content(self.content) then
      self.content.next = u.get_next_list_item
    end

    if self.content[1] and self.content[1].id then
      -- NougatItem[]

      self.content._overflow = "hide-all"

      for i = 1, #self.content do
        if self.content[i].priority then
          self.content._overflow = "hide-self"
          break
        end
      end
    end
  end

  self._config = config.config or {}

  if config.init then
    config.init(self)
  end

  return self
end

---@class NougatItem
---@field id integer
---@field hl? nougat_item_hl
---@field sep_left? nougat_separator[]
---@field prefix? nougat_item_affix
---@field content nougat_item_content
---@field suffix? nougat_item_affix
---@field sep_right? nougat_separator[]
---@field hidden? nougat_item_hidden
---@field prepare? fun(self: NougatItem, ctx: nougat_bar_ctx):nil
---@field ctx table
local Item = setmetatable({}, {
  __call = init,
  __name = "NougatItem",
})

---@param breakpoints integer[]
function Item:_init_breakpoints(breakpoints)
  iu.prepare_config_breakpoints(self, breakpoints)
  iu.prepare_property_breakpoints(self, "sep_left", breakpoints)
  iu.prepare_property_breakpoints(self, "prefix", breakpoints)
  iu.prepare_property_breakpoints(self, "suffix", breakpoints)
  iu.prepare_property_breakpoints(self, "sep_right", breakpoints)

  if type(self.content) == "table" and self.content[1] and self.content[1].id then
    for idx = 1, self.content.len do
      self.content[idx]:_init_breakpoints(breakpoints)
    end
  end
end

---@param ctx nougat_bar_ctx
function Item:config(ctx)
  return self._config[ctx.breakpoint] or self._config
end

---@alias NougatItem.constructor fun(config: nougat_item_config): NougatItem
---@type NougatItem|NougatItem.constructor
local NougatItem = Item

return NougatItem
