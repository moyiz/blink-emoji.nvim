# blink-emoji.nvim 😉

An emoji source for [blink.cmp](https://github.com/Saghen/blink.cmp).

## 🎨 Features
- Trigger on colon `:` (configurable).
- Ghost text completion support.

## 🔨 Installation

### 💤 lazy.nvim
```lua
{
  "saghen/blink.cmp",
  dependencies = {
      "moyiz/blink-emoji.nvim",
  },
  opts = {
    sources = {
      default = {
        ...
        "emoji",
      },
      providers = {
        emoji = {
          module = "blink-emoji",
          name = "Emoji",
          score_offset = 15, -- Tune by preference
          ---@type blink-emoji.config
          opts = {
            insert = true,
            pre_trigger = function()
              return { "", " ", "\t" }
            end,
            trigger = function()
              return { ":" }
            end,
          },
          should_show_items = function()
            return vim.tbl_contains(
              -- Enable emoji completion only for git commits and markdown.
              -- By default, enabled for all file-types.
              { "gitcommit", "markdown" },
              vim.o.filetype
            )
          end,
        }
      }
    }
  }
}
```

## 📘 Usage
Press `:`.

## 💪 Credit
Based on [hrsh7th/cmp-emoji](https://github.com/hrsh7th/cmp-emoji).

## 📜 License
See [License](./LICENSE).
