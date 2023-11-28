![GitHub Workflow Status: CI](https://img.shields.io/github/actions/workflow/status/MunifTanjim/nougat.nvim/ci.yml?branch=main&label=CI&style=for-the-badge)
[![Coverage](https://img.shields.io/codecov/c/gh/MunifTanjim/nougat.nvim/main?style=for-the-badge)](https://codecov.io/gh/MunifTanjim/nougat.nvim)
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

## :inbox_tray: Installation

Install the plugins with your preferred plugin manager. For example:

**With [`lazy.nvim`](https://github.com/folke/lazy.nvim)**

```lua
{
  "MunifTanjim/nougat.nvim",
},
```

<details>
<summary>
<strong>With <a href="https://github.com/wbthomason/packer.nvim"><code>packer.nvim</code></a></strong>
</summary>

```lua
use({
  "MunifTanjim/nougat.nvim",
})
```
</details>

<details>
<summary>
<strong>With <a href="https://github.com/junegunn/vim-plug"><code>vim-plug</code></a></strong>
</summary>

```vim
Plug 'MunifTanjim/nougat.nvim'
```
</details>

## Usage

`nougat.nvim` is at your disposal to build exactly what you want.

### Examples

A handful of examples are available to get you started.

#### Bubbly

Source: [bubbly.lua](examples/bubbly.lua)

![Bubbly Statusline](https://github.com/MunifTanjim/nougat.nvim/wiki/media/bubbly-statusline.png)

#### Pointy

Source: [pointy.lua](examples/pointy.lua)

![Pointy Statusline](https://github.com/MunifTanjim/nougat.nvim/wiki/media/pointy-statusline.png)

#### Slanty

Source: [slanty.lua](examples/slanty.lua)

![Slanty Statusline](https://github.com/MunifTanjim/nougat.nvim/wiki/media/slanty-statusline.png)

---

## :gear: NougatBar

The sweet `NougatBar` represents the `statusline` / `tabline` / `winbar`.

**[Check Detailed Documentation for `nougat.bar`](lua/nougat/bar)**

## :gear: NougatItem

Each `NougatBar` is made of a bunch of `NougatItem`.

**[Check Detailed Documentation for `nougat.item`](lua/nougat/item)**

## :gear: Separator

Separator that goes between two `NougatItem`s.

**[Check Detailed Documentation for `nougat.separator`](lua/nougat/separator)**

## :gear: Cache

**[Check Detailed Documentation for `nougat.cache`](lua/nougat/cache)**

## :bar_chart: Profiler

The built-in profiler can be used with the `:Nougat profile` command.

---

## :notebook: Links

- Discussion: [MunifTanjim/nougat.nvim/discussions](https://github.com/MunifTanjim/nougat.nvim/discussions)
- Wiki: [MunifTanjim/nougat.nvim/wiki](https://github.com/MunifTanjim/nougat.nvim/wiki)

## :scroll: License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.
