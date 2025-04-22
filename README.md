# Menu
Menu ui for neovim ( supports nested menus ) 

![image](https://github.com/user-attachments/assets/c8402279-b86d-432f-ad11-14a76c887ab1)
![image](https://github.com/user-attachments/assets/6da0b1a6-54c5-4ecc-ab06-fce1f17595ac)
![image](https://github.com/user-attachments/assets/d70430e1-74d2-40dd-ba60-0b8919d53af6)

https://github.com/user-attachments/assets/89d96170-e039-4d3d-9640-0fdc3358a833

## Features

- LSP Actions menu
- mapleader which-key menu
- neo-tree support
- nvimtree support

## Installation

Install the plugin with your package manager:

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "nvzone/menu",
  dependencies = { "nvzone/volt" },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
  },
}
```

Default settings:

```lua
  opts = {
    -- Overwrite filetype menu in handler(). If not provided, require("menus.ft." .. filetype) is tried to load the menu.
    ft = {},
    -- The default menu to open in handler(), if filetype specific menu is not found.
    default_menu = "default",
    -- Should we install default mappings? Default mappings presented below.
    default_mappings = false,
    -- Should the menu have a border?
    border = false,
    item_gap = 5,
  },
```

## Usage

To open a menu, you can use:

```lua
require("menu").open(items, opts) 
```

Items is detected to be:
- a function, in which case it is called and it can return a string or a table.
- a string, in which case `require("menus." .. items)` is called. This may result in a function, which is then called.
- the end result has to be a table of menu items.

Opts has the following attributes:
- **mouse**: (`boolean`) When true, will create menu at cursor position.

Menu item has the following attributes:
- **name**: (`string`) The name of the item.
- **cmd**: (`string|fun():any`) The command to execute when item is selected.
- **items**: (`MenuItem[]|fun():MenuItem[]`) Submenu items or a function that returns the submenu items (required for submenu)
- **rtxt**: (`string`) Text to show on the right of the item (optional)
- **hl**: (`string`) The hightlight of the item.

The library provides a default handler:

```lua
require("menu").handler(opts)
```

The handler automatically chooses which menu to open depending on the current filetype.

Opts has the following attributes:
- **mouse**: (`boolean`) 
  - When menu is open and **mouse** is set to true, then menu will be closed and a new menu will be repened at new cursor location.
  - When menu is open and **mouse** is set to false, menu will just be closed.

### For keyboard users

- Use `h` `l` to move between windows 
- Use `q` to close the window
- Press the keybind defined for menu item or scroll to it and press enter, to execute it

### Default mappings

Keyboard users can run the mapping when inside the menu, mouse users can click.

```lua
-- Keyboard users
vim.keymap.set("n", "<C-t>", function() require("menu").handler {mouse = false} end)
-- Mouse users
vim.keymap.set({ "n", "v" }, "<RightMouse>", function() require("menu").handler {mouse = true} end)
```

Same settings in lazy.nvim specification:

```lua
  keys = {
    { mode = "n", "<C-t>", function() require("menu").handler({ mouse = false }) end },
    { mode = "n", "<RightMouse>", function() require("menu").handler({ mouse = true }) end },
    { mode = "v", "<RightMouse>", function() require("menu").handler({ mouse = true }) end },
  },
```

Check example of [defaults menu](https://github.com/NvChad/menu/blob/main/lua/menus/default.lua) to see know syntax of options table.

## :gift_heart: Support

If you like NvChad or its plugins and would like to support it via donation

[![kofi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/siduck)
[![paypal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/siduck13)
[![buymeacoffee](https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/siduck)
[![patreon](https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white)](https://www.patreon.com/siduck)
