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

---

## :notebook: Links

- Discussion: [MunifTanjim/nougat.nvim/discussions](https://github.com/MunifTanjim/nougat.nvim/discussions)
- Wiki: [MunifTanjim/nougat.nvim/wiki](https://github.com/MunifTanjim/nougat.nvim/wiki)
- `nui.bar`: [MunifTanjim/nui.nvim - lua/nui/bar](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/bar)

## :scroll: License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.
