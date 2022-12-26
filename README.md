![GitHub Workflow Status: CI](https://img.shields.io/github/actions/workflow/status/MunifTanjim/nougat.nvim/ci.yml?branch=main&label=CI&style=for-the-badge)
![License](https://img.shields.io/github/license/MunifTanjim/nougat.nvim?color=%231385D0&style=for-the-badge)

# :chocolate_bar: nougat.nvim

Hyperextensible plugin for Neovim's `'statusline'`, `'tabline'` and `'winbar'`.

## :sparkles: Features

- :hammer_and_wrench: Hyperextensible.
- :rocket: Fast, Performance focused, Submillisecond evaluation time.
- :package: Modular design, only use what you need.
- :crystal_ball: Dynamic `statusline` / `tabline` / `winbar`.
- :page_with_curl: Filetype specific `statusline` / `winbar`.
- :nail_care: Fancy separators.
- :computer_mouse: Mouse-click.
- :briefcase: Caching out-of-the-box.
- :desktop_computer: Responsive breakpoints.
- :bar_chart: Built-in profiler.
- :peanuts: Common items included.

## :spider_web: Requirements

- Neovim >= 0.7.0
- [`MunifTanjim/nui.nvim`](https://github.com/MunifTanjim/nui.nvim)

## :inbox_tray: Installation

Install the plugins with your preferred plugin manager. For example:

**With [`packer.nvim`](https://github.com/wbthomason/packer.nvim)**

```lua
use({
  'MunifTanjim/nougat.nvim',
  requires = {
    "MunifTanjim/nui.nvim",
  },
})
```

<details>
<summary>
<strong>With <a href="https://github.com/junegunn/vim-plug"><code>vim-plug</code></a></strong>
</summary>

```vim
Plug 'MunifTanjim/nougat.nvim'
Plug 'MunifTanjim/nui.nvim'
```

</details>

## :gear: Module: NougatBar

_Signature:_ `(type: 'statusline'|'tabline'|'winbar', options?: table) -> NougatBar`

The sweet nougat bar.

```lua
local Bar = require("nougat.bar")
```

### Parameter: `type`

**Type:** `'statusline'|'tabline'|'winbar'`

Type of the bar.

### Parameter: `options`

#### `breakpoints`

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

### Methods

#### `bar:add_item`

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

## :gear: Module: NougatItem

_Signature:_ `(options?: table) -> NougatItem`

Each nougat bar is made of a bunch of items.

```lua
local Item = require("nougat.item")
```

### Parameter: `options`

> **Note** > **Common Options**

#### `refresh`

**Type:** `(self: NougatItem, ctx: nougat_ctx) -> nil`

If provided, the function is called before each item is evaluated. It can be used to
collect data for the functions called later in the item evaluation cycle.

#### `hidden`

**Type:** `boolean` or `(self: NougatItem, ctx: nougat_ctx) -> boolean`

Specifies if the item should be hidden.

#### `hl`

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

#### `content`

**Type:** `string` or `string[]` or `NougatItem[]` or `(self: NougatItem, ctx: nougat_ctx) -> nil|string|string[]|NougatItem[]` (required)

The content of the item.

If content is `nil`, `prefix` and `suffix` options will be ignored.

If content is a list of `NougatItem`s, each of those items will also be evaluated.

#### `sep_left` and `sep_right`

**Type:** `nougat_separator` or `nougat_separator[]`

Left and right separator for the item.

`nougat_separtor` is a `table`:

| Key       | Type                  | Description         |
| --------- | --------------------- | ------------------- |
| `content` | `string`              | separator character |
| `hl`      | `table`               | separator highlight |
| `hl.bg`   | `string` / `-1` / `1` | background color    |
| `hl.fg`   | `string` / `-1` / `1` | foreground color    |

For `hl.bg` and `hl.fg`:

- `string` can be a named color (e.g. `rebeccapurple`) or hex code (e.g. `#663399`)
- `-1` means highlight color from the previous item.
- `1` means highlight color from the next item.

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

#### `prefix` and `suffix`

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

#### `context`

**Type:** `boolean|number|string|table` or `(ctx: nui_bar_core_expression_context) -> nui_bar_core_expression_context`

If provided, it will be attached to the `ctx` parameter of the `on_click` option as
`ctx.ctx`.

If `context` is function, it receives the `nui_bar_core_expression_context` table as `ctx` parameter and it should
return the same table, storing `boolean|number|string|table` as `ctx.ctx`.

Default value is the item itself.

#### `on_click`

**Type:** `(handler_id: integer, click_count: integer, mouse_button: string, modifiers: string, ctx: nui_bar_core_expression_context) -> nil` or `string`

If provided, this function is called when the item is clicked.

**Parameters**

- `handler_id`: _irrelevant (lower-level `nui.bar` implementation details)_
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
- `ctx`: `nui_bar_core_expression_context`

`nui_bar_core_expression_context` is a table:

| Key          | Type                                      | Description                   |
| ------------ | ----------------------------------------- | ----------------------------- |
| `ctx`        | `boolean` / `number` / `string` / `table` | value of the `context` option |
| `bufnr`      | `integer`                                 | buffer number                 |
| `winid`      | `integer`                                 | window id                     |
| `tabid`      | `integer`                                 | tab id                        |
| `is_focused` | `boolean`                                 | `true` if window is focused   |

If `on_click` is a `string`, it is treated as the name of a vimscript function. Value of the
`context` option will not be available to the vimscript function.

#### `config`

**Type:** `table|table[]`

This stores item specific configuration. Like `sep_left` / `sep_right` / `prefix` / `suffix`,
`config` also supports breakpoints.

> **Note** > **Type-specific Options**

#### `type`

**Type:** `nil|'code'|'vim_expr'|'lua_expr'|'literal'|'tab_label'`

With specific `type`, item can:

- take additional type-specific options
- treat `content` option differently

| `type` Type   | `content` Type                                                           | Notes                                                             |
| ------------- | ------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| `'code'`      | `string`                                                                 | one of the item codes listed in `:help 'statusline'`              |
| `'vim_expr'`  | `number` / `string`                                                      | `string` is treated as vimscript                                  |
| `'lua_expr'`  | `number` / `string` / `(ctx: nui_bar_core_expression_context) -> string` | for `function`, the `ctx` parameter is same as `on_click` option. |
| `'literal'`   | `boolean` / `number` / `string`                                          |                                                                   |
| `'tag_label'` | `number` / `string`                                                      |                                                                   |

#### `align`

_Accepted for `type`:_ `'code'|'vim_expr'|'lua_expr'|'literal'`

**Type:** `'left'|'right'`

Default value is `'right'`.

#### `leading_zero`

_Accepted for `type`:_ `'code'|'vim_expr'|'lua_expr'|'literal'`

**Type:** `boolean`

If `true`, adds leading zeros to to items with numeric content (when
content width is less than `min_width` and `align` is `'right'`).

#### `max_width` and `min_width`

_Accepted for `type`:_ `'code'|'vim_expr'|'lua_expr'|'literal'`

**Type:** `integer`

Maximum/minimum width of the item content.

#### `expand`

_Accepted for `type`:_ `'vim_expr'|'lua_expr'`

**Type:** `boolean`

If `true`, the result of vim expression or lua expression is expanded again.

#### `close`

_Accepted for `type`:_ `'tab_label'`

**Type:** `boolean`

If `true`, clicking on the item closes the corresponding tab.

Otherwise, clicking on the item switches to the corresponding tab.

#### `tabnr`

_Accepted for `type`:_ `'tab_label'`

**Type:** `integer`

Associates the item with the specified tab number.

> **Note**
> Advance Options

#### `on_init_breakpoints`

**Type:** `(self: NougatItem, breakpoints: integer[]) -> nil`

Used to prepare item's internals for the bar's breakpoints.

If provided, it is called when the item is added to the bar.

### Methods

#### `item:config`

_Signature:_ `(ctx: nougat_ctx) -> table`

Returns the config for the current breakpoint.

## :gear: Module: Nougat Separator

Separator that goes between two items.

```lua
local sep = require("nougat.separator")
```

These are the built-in separators:

- `none`
- `space`
- `vertical`
- `heavy_veritcal`
- `double_vertical`
- `full_block`
- `left_chevron`
- `left_chevron_solid`
- `right_chevron`
- `right_chevron_solid`
- `falling_diagonal`
- `rising_diagonal`
- `left_lower_triangle_solid`
- `left_upper_triangle_solid`
- `right_lower_triangle_solid`
- `right_upper_triangle_solid`
- `left_half_circle`
- `left_half_circle_solid`
- `right_half_circle`
- `right_half_circle_solid`

Each of them is a function and returns `nougat_separator`.

**Example**

```lua
sep.left_chevron()
sep.right_lower_triangle_solid(true)
```

If the first parameter `use_hl_transition` is `true`, that separator's highlight will
automagically blend in seamlessly with the previous/next item's highlight.

## :gear: Module: Cache

Cache for the items. Caching is used for storing the result of complex calculations to
keep the bar evaluation time as small as possible.

The complex calculations can be done in multiple places:

- Outside the bar evaluation process, e.g. using an autocommand. Evaluation time won't
  be affected by this.
- Inside the bar evaluation process, e.g. inside item's `refresh` or `content` callback
  function. Evaluation time will be affected only when cached value is missing or if
  cache value is invalidated.

### `cache.create_store`

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
    -- calculate the value (this is just an example)
    local modified = vim.bo[bufnr].modified
    -- cache the calculated value
    cache_store[bufnr].modified = modified
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

## :notebook: Links

- Discussion: [MunifTanjim/nougat.nvim/discussions](https://github.com/MunifTanjim/nougat.nvim/discussions)
- Wiki: [MunifTanjim/nougat.nvim/wiki](https://github.com/MunifTanjim/nougat.nvim/wiki)
- `nui.bar`: [MunifTanjim/nui.nvim - lua/nui/bar](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/bar)

## :scroll: License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.
