# NougatBar

_Signature:_ `(type: 'statusline'|'tabline'|'winbar', options?: table) -> NougatBar`

The sweet `NougatBar` represents the `statusline` / `tabline` / `winbar`.

```lua
local Bar = require("nougat.bar")
```

## Parameter: `type`

**Type:** `'statusline'|'tabline'|'winbar'`

Type of the bar.

## Parameter: `options`

### `breakpoints`

**Type:** `integer[]` (optional)

It sets the responsive breakpoints for all the items added to the bar.

The table should be a list of ascending/descending integers.

For ascending list, breakpoints are treated as _min width_ and
the first element must be `0`.

For descending list, breakpoints are treated as _max width_ and
the first element must be `math.huge`.

**Example**

```lua
local breakpoint = { l = 1, m = 2, s = 3 }
local breakpoints = { [breakpoint.l] = math.huge, [breakpoint.m] = 128, [breakpoint.s] = 80 }

local bar = Bar('statusline', { breakpoints = breakpoints })
```

## Methods

### `bar:add_item`

_Signature:_ `(item: string|table|NougatItem) -> NougatItem`

**Example**

```lua
local Item = require("nougat.item")

-- string content
bar:add_item("[nougat.nvim]")
-- or NougatItem options
bar:add_item({
  prefix = "[",
  content = "nougat.nvim",
  suffix = "]",
})
-- or NougatItem
bar:add_item(Item({
  prefix = "[",
  content = "nougat.nvim",
  suffix = "]",
}))
```
