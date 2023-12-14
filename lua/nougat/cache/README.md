# Cache

Cache for the items. Caching is used for storing the result of complex calculations to
keep the bar evaluation time as small as possible.

The complex calculations can be done in multiple places:

- Outside the bar evaluation process, e.g. using an autocommand. Evaluation time won't
  be affected by this.
- Inside the bar evaluation process, e.g. inside item's `prepare` or `content` callback
  function. Evaluation time will be affected only when cached value is missing or if
  cache value is invalidated.

Nougat provides some built-in cache store.

## Buffer Cache

### filetype

```lua
local buffer_cache = require("nougat.cache.buffer")
local buffer_cache_store = buffer_cache.store

buffer_cache.enable("filetype")

local cache = buffer_cache_store[bufnr]
print(cache.filetype)

buffer_cache.on("filetype.change", function(filetype, cache, bufnr)
  print(filetype)
end)
```

### gitstatus

```lua
local buffer_cache = require("nougat.cache.buffer")
local buffer_cache_store = buffer_cache.store

buffer_cache.enable("gitstatus")

local cache = buffer_cache_store[bufnr]
local gitstatus = cache.gitstatus
print(gitstatus.added, gitstatus.changed, gitstatus.removed, gitstatus.total)

buffer_cache.on("gitstatus.change", function(gitstatus, cache, bufnr)
  print(gitstatus.added, gitstatus.changed, gitstatus.removed, gitstatus.total)
end)
```

### modified

```lua
local buffer_cache = require("nougat.cache.buffer")
local buffer_cache_store = buffer_cache.store

buffer_cache.enable("modified")

local cache = buffer_cache_store[bufnr]
print(cache.filetype)

buffer_cache.on("modified.change", function(modified, cache, bufnr)
  print(modified)
end)
```

## Diagnostic Cache

```lua
local diagnostic_cache = require("nougat.cache.diagnostic")
local severity = diagnostic_cache.severity

diagnostic_cache.enable()

diagnostic_cache.on("change", function(cache, bufnr)
  print(
    cache[severity.ERROR],
    cache[severity.WARN],
    cache[severity.INFO],
    cache[severity.HINT],
    cache[severity.COMBINED],
  )
end)
```
