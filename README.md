
# 📋 LazyClip

Enhanced Neovim clipboard manager.

## ✨ Features

- 📋 **Automatic Clipboard History**: Tracks all yanked text automatically
- ⏰ **Timestamps**: See when each item was copied
- 🖼️ **Live Preview**: Preview clipboard content with syntax highlighting
- ⌨️ **Quick Access**: Number keys (1-9) for instant pasting
- 🗑️ **Item Management**: Delete items with `d` key
- 📄 **Pagination**: Navigate through large clipboard history
- 🎨 **Beautiful UI**: Rounded borders and syntax highlighting
- 💬 **Better Notifications**: Improved feedback messages

## 🚀 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "atiladefreitas/lazyclip",
  config = function()
    require("lazyclip").setup({
      -- Configuration options
    })
  end,
}
```

## ⚙️ Configuration

Default configuration:

```lua
require("lazyclip").setup({
  max_history = 100,          -- Maximum clipboard items to store
  items_per_page = 9,         -- Items shown per page
  min_chars = 5,              -- Minimum characters to save an item
  window = {
    width = 70,               -- Window width
    height = 12,              -- Window height
    border = "rounded",       -- Border style
  },
  keymaps = {
    close_window = "q",       -- Close the clipboard window
    prev_page = "h",          -- Previous page
    next_page = "l",          -- Next page
    paste_selected = "<CR>",  -- Paste selected item
    move_up = "k",            -- Move cursor up
    move_down = "j",          -- Move cursor down
    delete_item = "d",        -- Delete current item
  },
})
```

## 🔧 Usage

### Basic Usage

1. **Open Clipboard Manager**: `<leader>Cw` (or `:LazyClip`)
2. **Navigate**: Use `j`/`k` or arrow keys to move
3. **Paste Item**: Press `<Enter>` or the item number (1-9)
4. **Delete Item**: Press `d` on any item
5. **Close Window**: Press `q`

### Features

- **Timestamps**: See when each item was copied (e.g., `5m`, `2h`, `1d`)
- **Pagination**: Use `h`/`l` to navigate through multiple pages
- **Live Preview**: See full content with syntax highlighting in the preview window

## 🎯 Commands

- `:LazyClip` - Open the clipboard manager

## 🔗 Keybindings

### In Clipboard Window

| Key | Action |
|-----|--------|
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `h` | Previous page |
| `l` | Next page |
| `1-9` | Quick paste item |
| `<Enter>` | Paste selected item |
| `d` | Delete item |
| `q` | Close window |

## 🎨 Highlights

The plugin uses several highlight groups that can be customized:

- `LazyClipNormal` - Normal text
- `LazyClipBorder` - Window border
- `LazyClipSelected` - Selected line
- `LazyClipIndex` - Item numbers [1], [2], etc.
- `LazyClipContent` - Clipboard content text
- `LazyClipTimestamp` - Time indicators (5m, 2h)
- `LazyClipPageInfo` - Page information

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
