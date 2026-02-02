# Tree-sitter Grammar for Power Builder language

This is my own implementation of the tree-sitter grammer file for Power Builder langage syntax highlighting.

Work is still in progress but most of usefull things are implemented!

## What is implemented

Grammer for file types:

- .srw (Window)
- .sru (UserObject)
- .srd (DataWindow)
- .srf (Function)

Query files:

- highlight.scm - syntax highlighting
- aerial.scm - Outline for Aerial plugin
- injections.scm - Inline SQL highlighting

## how to build - generate and test

```sh
tree-sitter generate #must do!
tree-sitter parse .\example-file.sru | bat --color=always -l javascript
tree-sitter parse .\example-file.srw --debug  | bat --color=always -l javascript
```

** Check test_grammer.ps1 **

## How to use (Install to nvim)

Please refare to tree-sitter manual how to do it in correct way, as below is just what I remeber from my experience.

- Add simlinks to the scm files from this repo to ...\nvim\after\queries\powerbuilder folder
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
- Open any Power Builder file type

**Screenshots will come**
