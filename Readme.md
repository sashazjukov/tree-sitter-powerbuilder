# Tree-sitter Grammar for Power Builder language

This is my own implementation of the tree-sitter grammer file for Power Builder langage syntax highlighting.

Work is still in progress, but most of usefull things are implemented! 
So we can now fill the power of the NeoVim editor for Power Builder files types!


![image](https://github.com/user-attachments/assets/048c8b7f-e1a9-4314-8d55-d071577bd16b) ![image](https://github.com/user-attachments/assets/22ae7f0c-2322-447d-b63e-0cba470d1852)


## What is implemented

Grammer for file types:

- .srw (Window)
- .sru (UserObject)
- .srd (DataWindow)
- .srf (Function)

Query files:

- highlight.scm - Syntax highlighting
- aerial.scm - Outline for Aerial plugin
- injections.scm - Inline SQL highlighting
- a bit in other .scm files

## How to build - generate and test

see tree-sitter manual

```sh
tree-sitter generate #must do!
#some test commnads
tree-sitter parse .\example-file.sru
tree-sitter highlight .\example-file.sru
tree-sitter parse --debug .\example-file.srw | bat --color=always -l javascript
```

** Check test_grammer.ps1 **

## How to use (Install to nvim)

Please refare to tree-sitter manual how to do it in correct way, as below is just what I remeber from my experience, and how I use it.

- Add simlinks to the scm files from this repo to ...\nvim\after\queries\powerbuilder folder
![image](https://github.com/user-attachments/assets/2342722a-1e64-47bf-ac51-6b577e2cbb4d)


- Add to your init.lua

```lua
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.powerbuilder = {
  install_info = {
    url = "d:/SIMLINKS/tree-sitter-powerbuilder/", -- Update this path to your local repo path
    files = { "src/parser.c" },
    branch = "main",
    generate_requires_npm = false,
    requires_generate_from_grammar = true,
  },
  filetype = "powerbuilder",
}
```

- I have this lua file in plugins folder

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        -- We'll add our custom parser here once created
        vim.list_extend(opts.ensure_installed, { "powerbuilder" })
      end
    end,
    config = function(_, opts)
      -- Add filetype detection for PowerBuilder files
      vim.filetype.add {
        extension = {
          srw = "powerbuilder",
          sru = "powerbuilder",
          srd = "powerbuilder",
          srf = "powerbuilder",
          srm = "powerbuilder",
        },
      }
      require("cmp").setup.filetype({ "powerbuilder" }, { sources = {
        { name = "buffer" },
      } })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- PowerBuilder file extensions
      filetype = {
        "srw",
        "sru",
        "srd",
        "srf",
        "srm",
      },
    },
  },
}
```

- And you maybe will need to place this code to somewhere (maybe treesitter.lua plugin file)

```lua
vim.filetype.add {
      extension = {
        srw = "powerbuilder",
        sru = "powerbuilder",
        srd = "powerbuilder",
        srf = "powerbuilder",
      },
```

- Inside Nvim type a command to build and import .so file to nvim (I could not (and did not whant to spend much time) find a way how to build this file outside nvim on Windows :) )

```sh
:TSInstallFromGrammar PowerBuiilder
```

- Restart nvim
- Open any Power Builder file type (but you will need to setup color theme, see below example that I use)
  ![image](https://github.com/user-attachments/assets/2e32d8fa-7d87-43de-8a05-068d722a48ec)

- Here is my clolor defention for astrotheme.lua
```lua
return {
  "AstroNvim/astrotheme",
  config = function()
    require("astrotheme").setup {
      plugins = { -- Allows for individual plugin overrides using plugin name and value from above.
        -- ["bufferline.nvim"] = false,
        ["dashboard-nvim"] = true,
      },
      highlights = {
        astrodark = {
          -- first parameter is the highlight table and the second parameter is the color palette table
          modify_hl_groups = function(hl, c) -- modify_hl_groups function allows you to modify hl groups,
            hl.Normal = { bg = "#000000" }
            hl.NormalNC = { bg = "#111111" }
            hl.NormalFloat = { bg = "#000000" }
            hl.Visual = { bg = "#335533" }
            hl.MatchParen = { bg = "#004400", underline = true }
            hl.WinSeparator = { fg = "#aaaaaa" }
            hl.CursorLineNr = { fg = "#aaaaaa" }
            hl.FloatBorder = { fg = "#aaaaaa" } -- Border of floating windows
            hl.Search = { bg = "#006600" }
            hl.IlluminatedWordText = { bg = "#005500" }
            hl.IlluminatedWordRead = { bg = "#005500" }
            hl.IlluminatedWordWrite = { bg = "#553300" }

            hl.WinBar = { fg = "#00bb00" }
            hl.WinBarNC = { fg = "#008800" }

            --=[ Aerial ]=-
            hl.AerialFunctionIcon = { fg = "#ee99ee" }
            hl.AerialFunction = { fg = "#aa99cc" }
            hl.AerialEvent = { fg = "#eebbee" }
            hl.AerialClass = { fg = "#00bbbb" }
            hl.AerialFile = { fg = "#33aa99" }
            hl.AerialField = { fg = "#996666" }
            --

            hl.NotificationInfo = { fg = "#FFFFFF", bg = "#6666bb" }
            hl.NotificationWarning = { fg = "#FFFFFF", bg = "#dddd00" }
            hl.NotificationError = { fg = "#FFFFFF", bg = "#bb0000" }
            hl.QuickFixLine = { bg = "#333300" }
          end,

          ["@class.name"] = { fg = "#00bbbb" },
          ["@variable.member"] = { fg = "#00bbbb" },
          ["@variable.member.sql"] = { fg = "#00bbbb" },
          -- ["@varibale.array_call"] = { fg = "#ff5555", bold = false },
          ["@variable.member_left"] = { fg = "#aaaaaa" },
          ["@variable.local"] = { fg = "#cbcbcb" },

          ["@sql.block"] = { bg = "#333333" },
          ["@sql.parameter"] = { fg = "#bbbbbb", bold = true, bg = "#333333" },

          ["@keyword.sql"] = { fg = "#9999ff", bold = true },
          ["@keyword.control.conditional"] = { fg = "#55ffcc", bold = false },

          ["@punctuation.delimiter"] = { fg = "#884444" },
          ["@operator"] = { fg = "#cc3333" },
          ["@operator.logical"] = { fg = "#5555cc", bold = true },

          ["@function_prototype"] = { bg = "#202020", italic = true },
          ["@function"] = { fg = "#ee88ee" },

          ["@keyword.directive"] = { fg = "#777777", bg = "#202020", italic = true },
          ["@keyword"] = { fg = "#33aa99" },
          ["@keyword.type"] = { fg = "#999900" },
          ["@keyword.return"] = { fg = "#dd5555" },

          ["@event_prototype"] = { italic = true },

        },
      },
    }
  end,
}
```
