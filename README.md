# blink-emoji.nvim 😉

An emoji source for [blink.cmp](https://github.com/Saghen/blink.cmp).

## 🎨 Features
- Trigger on colon `:`.
- Ghost text completion.

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
