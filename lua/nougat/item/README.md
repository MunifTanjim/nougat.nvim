# NougatItem

_Signature:_ `(options?: table) -> NougatItem`

Each `NougatBar` is made of a bunch of `NougatItem`.

```lua
local Item = require("nougat.item")
```

## Parameter: `options`

> **Note**:
> **Common Options**

### `prepare`

**Type:** `(self: NougatItem, ctx: nougat_ctx) -> nil`

If provided, the function is called before each item is evaluated. It can be used to
prepare data for the functions called later in the item evaluation cycle.

### `hidden`

**Type:** `boolean` or `(self: NougatItem, ctx: nougat_ctx) -> boolean`

Specifies if the item should be hidden.

### `hl`

**Type:** `integer` or `string` or `nougat_hl_def` or `(self: NougatItem, ctx: nougat_ctx) -> integer|string|nougat_hl_def` or `NougatItem`

Specifies the highlight for the item. Different types of `hl` are treated in the following ways:

- `0`: resets to the bar's default highlight
- `1-9`: is treated as `hl-User1..9` (check `:help hl-User1..9`)
- `string`: is used as highlight group name
- `nougat_hl_def`: is merged with the bar's default highlight

If a function is passed, the return value is treated as mentioned above.

`nougat_hl_def` is a table:

| Key      | Type                       | Description      |
| -------- | -------------------------- | ---------------- |
| `bg`     | `string` / `"bg"` / `"fg"` | background color |
| `fg`     | `string` / `"bg"` / `"fg"` | foreground color |
| `bold`   | `boolean`                  | bold flag        |
| `italic` | `boolean`                  | italic flag      |

For `bg` and `fg`, the special value `"bg"` / `"fg"` refers to the bar's default background / foreground color.

If a `NougatItem` is passed, that item's highlight will be used instead.

### `content`

**Type:** `string` or `string[]` or `NougatItem[]` or `(self: NougatItem, ctx: nougat_ctx) -> nil|string|string[]|NougatItem[]` (required)

The content of the item.

If content is `nil`, `prefix` and `suffix` options will be ignored.

If content is a list of `NougatItem`s, each of those items will also be evaluated.

### `sep_left` and `sep_right`

**Type:** `nougat_separator` or `nougat_separator[]`

Left and right separator for the item.

`nougat_separtor` is a `table`:

| Key       | Type                      | Description         |
| --------- | ------------------------- | ------------------- |
| `content` | `string`                  | separator character |
| `hl`      | `nougat_separator_hl_def` | separator highlight |
| `hl.bg`   | `string` / `number`       | background color    |
| `hl.fg`   | `string` / `number`       | foreground color    |

For `hl.bg` and `hl.fg`:

- `string` can be a named color (e.g. `rebeccapurple`) or hex code (e.g. `#663399`)
- `number` can be one of the values from `require("nougat.separator").hl`

If a list of `nougat_separator` is passed, they will be used for appropriate breakpoints.

**Example**

```lua
local sep = require("nougat.separator")

-- right_chevron_solid for large screen, no right separator for medium and small screen
bar:add_item({
  sep_right = {
    [breakpoint.l] = sep.right_chevron_solid(),
    [breakpoint.m] = sep.none(),
  }
})
```

### `prefix` and `suffix`

**Type:** `string` or `string[]`

Prefix and suffix for the item.

If a list of `string` is passed, they will be used for appropriate breakpoints.

```lua
-- "[" for large screen, no prefix for medium and small screen
bar:add_item({
  prefix = {
    [breakpoint.l] = "[",
    [breakpoint.m] = "",
  }
})
```

### `context`

**Type:** `boolean|number|string|table` or `(ctx: nougat_core_expression_context) -> nougat_core_expression_context`

If provided, it will be attached to the `ctx` parameter of the `on_click` option as
`ctx.ctx`.

If `context` is function, it receives the `nougat_core_expression_context` table as `ctx` parameter and it should
return the same table, storing `boolean|number|string|table` as `ctx.ctx`.

Default value is the item itself.

### `on_click`

**Type:** `(handler_id: integer, click_count: integer, mouse_button: string, modifiers: string, ctx: nougat_core_expression_context) -> nil` or `string`

If provided, this function is called when the item is clicked.

**Parameters**

- `handler_id`: _irrelevant (lower-level `nougat.core` implementation details)_
- `click_count`: number of mouse clicks
- `mouse_button`:
  - `"l"` - left
  - `"r"` - right
  - `"m"` - middle
  - or other unknowns
- `modifiers`:
  - `"s"` - shift
  - `"c"` - control
  - `"a"` - alt
  - `"m"` - meta
  - or other unknowns
- `ctx`: `nougat_core_expression_context`

`nougat_core_expression_context` is a table:

| Key          | Type                                      | Description                   |
| ------------ | ----------------------------------------- | ----------------------------- |
| `ctx`        | `boolean` / `number` / `string` / `table` | value of the `context` option |
| `bufnr`      | `integer`                                 | buffer number                 |
| `winid`      | `integer`                                 | window id                     |
| `tabid`      | `integer`                                 | tab id                        |
| `is_focused` | `boolean`                                 | `true` if window is focused   |

If `on_click` is a `string`, it is treated as the name of a vimscript function. Value of the
`context` option will not be available to the vimscript function.

### `config`

**Type:** `table|table[]`

This stores item specific configuration. Like `sep_left` / `sep_right` / `prefix` / `suffix`,
`config` also supports breakpoints.

> **Note**:
> **Type-specific Options**

### `type`

**Type:** `nil|'code'|'vim_expr'|'lua_expr'|'literal'|'tab_label'`

With specific `type`, item can:

- take additional type-specific options
- treat `content` option differently

| `type` Type   | `content` Type                                                          | Notes                                                             |
| ------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `'code'`      | `string`                                                                | one of the item codes listed in `:help 'statusline'`              |
| `'vim_expr'`  | `number` / `string`                                                     | `string` is treated as vimscript                                  |
| `'lua_expr'`  | `number` / `string` / `(ctx: nougat_core_expression_context) -> string` | for `function`, the `ctx` parameter is same as `on_click` option. |
| `'literal'`   | `boolean` / `number` / `string`                                         |                                                                   |
| `'tag_label'` | `number` / `string`                                                     |                                                                   |

### `align`

_Accepted for `type`:_ `'code'|'vim_expr'|'lua_expr'|'literal'`

**Type:** `'left'|'right'`

Default value is `'right'`.

### `leading_zero`

_Accepted for `type`:_ `'code'|'vim_expr'|'lua_expr'|'literal'`

**Type:** `boolean`

If `true`, adds leading zeros to to items with numeric content (when
content width is less than `min_width` and `align` is `'right'`).

### `max_width` and `min_width`

_Accepted for `type`:_ `'code'|'vim_expr'|'lua_expr'|'literal'`

**Type:** `integer`

Maximum/minimum width of the item content.

### `expand`

_Accepted for `type`:_ `'vim_expr'|'lua_expr'`

**Type:** `boolean`

If `true`, the result of vim expression or lua expression is expanded again.

### `close`

_Accepted for `type`:_ `'tab_label'`

**Type:** `boolean`

If `true`, clicking on the item closes the corresponding tab.

Otherwise, clicking on the item switches to the corresponding tab.

### `tabnr`

_Accepted for `type`:_ `'tab_label'`

**Type:** `integer`

Associates the item with the specified tab number.

### `cache`

#### `cache.get`

**Type:** `function`

_Signature:_ `(store: table<integer, table>, ctx: nougat_ctx) -> table`

This is used to get the value from cache store for the current context.

#### `cache.initial_value`

**Type:** `table`

If cache store is created by `NougatItem`, this will be used as initial value for the cache.

#### `cache.scope`

**Type:** `'buf'|'win'|'tab'`

If `cache.scope` is present and `cache.store` is missing, it will be used create cache store.

It will also be used if `cache.invalidate` is `string`, for making id extractor from autocmd event. 

#### `cache.store`

**Type:** `table<integer, table>`

If cache store is given, `NougatItem` will not automatically cache the item content.

If it is missing, `NougatItem` will create a cache store using `cache.scope` and
automatically cache the item content.

#### `cache.invalidate`

**Type:** `string` or `{ [1]: string, [2]: (info: table) -> integer }`

If `cache.invalidate` is `string`, it'll be used as the name for autocmd event.

If `cache.invalidate` is `table`:
- First element should be `string`, used as the name for autocmd event.
- Second element should be `function`, used to extract id from autocmd event.

> **Note**:
> **Advance Options**

### `on_init_breakpoints`

**Type:** `(self: NougatItem, breakpoints: integer[]) -> nil`

Used to prepare item's internals for the bar's breakpoints.

If provided, it is called when the item is added to the bar.

## Methods

### `item:cache`

_Signature:_ `(ctx: nougat_ctx) -> table`

Returns the cache for current context.

_Only available when `cache` option is present._

### `item:config`

_Signature:_ `(ctx: nougat_ctx) -> table`

Returns the config for the current breakpoint.
