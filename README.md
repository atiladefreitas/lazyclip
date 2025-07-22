
# LazyClip

LazyClip is a powerful yet minimalist clipboard manager for Neovim, designed with simplicity and efficiency in mind. It integrates seamlessly with your Neovim setup and provides an intuitive floating window to browse and paste clipboard history. LazyClip is especially crafted for users of **Lazy.nvim** and works great with popular Neovim distributions.

## 🚀 Features

- 📋 View up to **9 clipboard items** per page in a **floating window**.
- 🔢 Fixed numbered slots `[1]` to `[9]` for quick reference.
- 🌟 **Paste with ease**: Use number keys or `<Enter>` to paste items directly into your editor.
- ⏮️ Navigate clipboard history with `H` (previous page) and `L` (next page).
- ⏰ **Timestamps**: See when each item was copied with time indicators.
- 🖼️ **Live Preview**: Preview clipboard content with syntax highlighting.
- 🗑️ **Delete items**: Remove unwanted clipboard entries with `d` key.
- 💬 **Better notifications**: Enhanced feedback messages for all actions.
- 🛠️ Compatible with **Lazy.nvim** for effortless installation.

---

## 📦 Installation

### Prerequisites

- Neovim `>= 0.10.0`
- [Lazy.nvim](https://github.com/folke/lazy.nvim) as your plugin manager.

### Using Lazy.nvim

```lua
return {
        "atiladefreitas/lazyclip",
        config = function()
            require("lazyclip").setup({
                -- your custom config here (optional)
            })
        end,
        keys = {
            { "Cw", desc = "Open Clipboard Manager" },
        },
        -- Optional: Load plugin when yanking text
        event = { "TextYankPost" },
}
```

Run the following commands in Neovim to install LazyClip:

```vim
:Lazy sync
```

### Default Configuration

LazyClip comes with sensible defaults that you can override:

```lua
{
    -- Core settings
    max_history = 100,      -- Maximum number of items to keep in history
    items_per_page = 9,     -- Number of items to show per page
    min_chars = 5,          -- Minimum characters required to store item
    
    -- Window appearance
    window = {
        relative = "editor",
        width = 70,         -- Width of the floating window
        height = 12,        -- Height of the floating window
        border = "rounded", -- Border style
    },
    
    -- Internal keymaps for the lazyclip window
    keymaps = {
        close_window = "q",      -- Close the clipboard window
        prev_page = "h",         -- Go to previous page
        next_page = "l",         -- Go to next page
        paste_selected = "<CR>", -- Paste the selected item
        move_up = "k",           -- Move selection up
        move_down = "j",         -- Move selection down
        delete_item = "d"        -- Delete selected item
    }
}
```
---

## 🛠️ Usage

1. **Yank text** in Neovim as usual using commands like `y`, `yy`, or `yank`.
2. Open LazyClip with `<leader>Cw`.
3. Browse through the last **9 copied items** in a floating window.
4. **Paste an item**:
   - Press the corresponding **number key** (`1-9`).
   - Or, navigate to the desired item with `j`/`k` and press `<Enter>`.
5. Use `h` and `l` to navigate pages when you have more than 9 items.
6. **Delete items** you no longer need with `d`.
7. **See timestamps** showing when each item was copied (e.g., `5m`, `2h`, `1d`).
8. **Preview content** in the dedicated preview window with syntax highlighting.
9. Press `q` to close the window.

---

## 📥 Backlog

Planned features and improvements for future versions of LazyClip:

#### Core Features

- [ ] System Clipboard Integration.
- [ ] Persistent Clipboard History.
- [ ] Clipboard Size Configuration

#### UI Enhancements

- [ ] Customizable Floating Window.
- [ ] Highlight Current Item.
- [ ] Multi-Item Paste.

#### Quality of Life

- [x] Keybinding Configurability.
- [x] Timestamps for clipboard entries.
- [x] Live Preview with syntax highlighting.
- [x] Item deletion functionality.
- [x] Better notifications and feedback.
- [ ] Performance Optimization.

---

## 📝 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🔖 Versioning

We use [Semantic Versioning](https://semver.org/) for versioning. For the available versions, see the [tags on this repository](https://github.com/atiladefreitas/lazyclip/tags).

---

## 🤝 Contributing

Contributions are welcome! If you'd like to improve LazyClip, feel free to:
- Submit an issue for bugs or feature requests.
- Create a pull request with your enhancements.

---

## 🌟 Acknowledgments

LazyClip was built with the Neovim community in mind. Special thanks to all the developers who contribute to the Neovim ecosystem and plugins like [Lazy.nvim](https://github.com/folke/lazy.nvim).

---

## All my plugins
| Repository | Description | Stars |
|------------|-------------|-------|
| [LazyClip](https://github.com/atiladefreitas/lazyclip) | A Simple Clipboard Manager | ![Stars](https://img.shields.io/github/stars/atiladefreitas/lazyclip?style=social) |
| [Dooing](https://github.com/atiladefreitas/dooing) | A Minimalist Todo List Manager | ![Stars](https://img.shields.io/github/stars/atiladefreitas/dooing?style=social) |
| [TinyUnit](https://github.com/atiladefreitas/tinyunit) | A Practical CSS Unit Converter | ![Stars](https://img.shields.io/github/stars/atiladefreitas/tinyunit?style=social) |


---

## 📬 Contact

If you have any questions, feel free to reach out:
- [LinkedIn](https://linkedin.com/in/atilafreitas)
- Email: contact@atiladefreitas.com
