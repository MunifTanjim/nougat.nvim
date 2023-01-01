# Cache

Cache for the items. Caching is used for storing the result of complex calculations to
keep the bar evaluation time as small as possible.

The complex calculations can be done in multiple places:

- Outside the bar evaluation process, e.g. using an autocommand. Evaluation time won't
  be affected by this.
- Inside the bar evaluation process, e.g. inside item's `prepare` or `content` callback
  function. Evaluation time will be affected only when cached value is missing or if
  cache value is invalidated.

## `cache.create_store`

_Signature:_ `(type: 'buf'|'win', name: string, default_value?: table) -> table`

The returned `table` is the cache store.

If `type` is `buf`, cache store needs to be indexed with buffer number.

If `type` is `win`, cache store needs to be indexed with window id.

The second paramter `name` is the identifier for the cache store. It is usually the
module name of the item for which the cache store is used.

**Example**

```lua
local create_cache_store = require("nougat.cache").create_store

local cache_store = create_store("buf", "nut.dummy", {
  modified = false,
})

vim.api.nvim_create_autocmd("BufModifiedSet", {
  group = vim.api.nvim_create_augroup("nougat.nut.dummy", { clear = true }),
  callback = function(params)
    local bufnr = params.buf
    vim.schedule(function ()
      -- calculate the value (this is just an example)
      local modified = vim.api.nvim_buf_get_option(bufnr, 'modified')
      -- cache the calculated value
      cache_store[bufnr].modified = modified
    end)
  end,
})

local dummy_item = Item({
  content = function(item, ctx)
    local cache = cache_store[ctx.bufnr]
    if cache.modified then
      return "+"
    end
  end,
})
```
