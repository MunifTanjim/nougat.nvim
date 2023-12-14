# Store

## `BufStore`

_Signature:_ `(name: string, value?: table) -> NougatCacheStore`

BufStore is used to store cache for buffer.

The `name` param is the identifier for the store.

The buffer store has to be indexed with buffer number.

**Example**

```lua
local BufStore = require("nougat.store").BufStore

local buf_store = BufStore("nougat.nut.dummy", {
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
      buf_store[bufnr].modified = modified
    end)
  end,
})

local dummy_item = Item({
  content = function(item, ctx)
    local cache = buf_store[ctx.bufnr]
    if cache.modified then
      return "+"
    end
  end,
})
```

## `WinStore`

_Signature:_ `(name: string, value?: table) -> NougatCacheStore`

WinStore is used to store cache for window.

The window store has to be indexed with window id.

## `TabStore`

_Signature:_ `(name: string, value?: table) -> NougatCacheStore`

TabStore is used to store cache for tab.

The tab store has to be indexed with tab id.

## `Store`

_Signature:_ `<T: table>(name: string, value: T, config?: { clear?: (store: T) -> nil }) -> T`

Store can be used to store arbitrary values.

**Example**

```lua
local Store = require("nougat.store").Store

local store = Store("nougat.nut.dummy", {
  items = {},
}, {
  clear = function(store)
    for _, val in pairs(store) do
      for k in pairs(val) do
        val[k] = nil
      end
    end
  end,
})

local items = store.items
```
