# `nougat.color`

If the color scheme you're using defines the `g:terminal_color_*`
variables, `nougat.nvim` can automatically extract color palette
from it.

If Lua `package.path` _(see `:help lua-package-path`)_ has a
`nougat/color/<colorscheme>.lua` file, where `<colorscheme>` is
the current value of `vim.g.colors_name` _(see `:help g:colors_name`)_,
`nougat.nvim` will try to use that file to get the color palette.

## Usage

You can use the color palette like this:

```lua
local color = require('nougat.color').get()
```

The `color` table will contain color palette for the current colorscheme.

By default, the following fields are expected and are guaranteed to
exist:

```lua
color.red
color.accent.red
color.green
color.accent.green
color.yellow
color.accent.yellow
color.blue
color.accent.blue
color.magenta
color.accent.magenta
color.cyan
color.accent.cyan

color.bg
color.accent.bg
color.bg0
color.bg1
color.bg2
color.bg3
color.bg4

color.fg
color.accent.fg
color.fg0
color.fg1
color.fg2
color.fg3
color.fg4
```

If you use the `color` table to highlight your `NougatItem`, it will always match
the currently active color scheme.

## `nougat.color.<colorscheme>`

For defining `nougat.nvim` color palette for a colorscheme, say `gruvbox`,
you will need to create a file `nougat/color/gruvbox.lua` with the following
structure:

```lua
local mod = {}

function mod.get()
  ---@class nougat.color.gruvbox: nougat.color
  local color = { accent = {} }
  -- set the values here
  return color
end

return mod
```

If the returned `color` table is missing any expected fields, `nougat.nvim`
will fill them with the fallback values.

## `get_hl_def`

_Signature:_ `(hl_name: string) -> nougat_hl_def`

## `get_hl_name`

_Signature:_ `(hl: nougat_hl_def, fallback_hl: nougat_hl_def) -> string`
