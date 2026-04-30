# blink-emoji.nvim 😉

An emoji source for [blink.cmp](https://github.com/Saghen/blink.cmp).

## 🎨 Features
- Custom multi-char trigger, default to colon (`:`).
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
          opts = {
            insert = true, -- Insert emoji (default) or complete its name
            ---@type string|table|fun():table
            trigger = ":-)"  -- Customize the trigger. Defaults to ":
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
Write your trigger. (Default `:`).

## 💪 Credit
Based on [hrsh7th/cmp-emoji](https://github.com/hrsh7th/cmp-emoji).

## 📜 License
See [License](./LICENSE).
