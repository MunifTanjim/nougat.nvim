# Separator

Separator that goes between two `NougatItem`s.

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

Each of them is a function.

_Signature:_ `(hl?: boolean|nougat_separator_hl_def|(fun(item: NougatItem, ctx: nougat_ctx) -> nougat_separator_hl_def)) -> nougat_separator`

If `hl` is `nil` or `false`, highlight will be same as the content.

If `hl` is `true`, highlight will automagically blend in seamlessly with the
previous/next item's highlight.

If `hl` is `nougat_separator_hl_def`, that `table` will be used as highlight.

If `hl` is `function`, the return value will be used as highlight.

**Example**

```lua
sep.left_chevron()
sep.right_lower_triangle_solid(true)
```

