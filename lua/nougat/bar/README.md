# NougatBar

_Signature:_ `(type: 'statusline'|'tabline'|'winbar', config?: nougat_bar_config) -> NougatBar`

The sweet `NougatBar` represents the `statusline` / `tabline` / `winbar`.

```lua
local Bar = require("nougat.bar")
```

## Parameter: `type`

**Type:** `'statusline'|'tabline'|'winbar'`

Type of the bar.

## Parameter: `config`

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

### `hl`

**Type:** `nil` / `integer` / `string` / `nougat_hl_def` / `(self: NougatBar, ctx: nougat_core_expression_context) -> integer|string|nougat_hl_def`

Specifies the highlight for the bar. Different types of `hl` are treated in the following ways:

- `nil|0`: is treated as the default highlight according to bar `type`
- `1-9`: is treated as `hl-User1..9` (check `:help hl-User1..9`)
- `string`: is used as highlight group name
- `nougat_hl_def`: is used has highlight definition (must have both `bg` and `fg`)

## Methods

### `bar:add_item`

_Signature:_ `(item: string|nougat_item_config|NougatItem) -> NougatItem`

**Example**

```lua
local Item = require("nougat.item")

-- string content
bar:add_item("[nougat.nvim]")
-- or NougatItem config
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
