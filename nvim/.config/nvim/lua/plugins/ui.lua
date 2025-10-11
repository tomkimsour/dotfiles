return {
  { "vuciv/golf" },
  {
    "folke/todo-comments.nvim",
    lazy = true,
    opts = {
      search = { pattern = [[\b(KEYWORDS)(\([^\)]*\))?:]] },
      highlight = {
        -- DONE(CX):https://github.com/folke/todo-comments.nvim/issues/10
        -- SOLVED: https://github.com/folke/todo-comments.nvim/issues/332
        pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
      },
    },
  },
  {
    "xiyaowong/transparent.nvim",
    enabled = false,
    lazy = true,
    config = function()
      require("transparent").setup({ -- Optional, you don't have to run setup.
        groups = { -- table: default groups
          "Normal",
          "NormalNC",
          "Comment",
          "Constant",
          "Special",
          "Identifier",
          "Statement",
          "PreProc",
          "Type",
          "Underlined",
          "Todo",
          "String",
          "Function",
          "Conditional",
          "Repeat",
          "Operator",
          "Structure",
          "LineNr",
          "NonText",
          "SignColumn",
          "CursorLine",
          "CursorLineNr",
          "StatusLine",
          "StatusLineNC",
          "EndOfBuffer",
        },
        extra_groups = {
          -- "NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
          "NvimTreeNormal", -- NvimTree
        }, -- table: additional groups that should be cleared
        exclude_groups = {}, -- table: groups you don't want to clear
      })
      require("transparent").clear_prefix("NeoTree")
      -- require("transparent").clear_prefix("lualine")
      require("transparent").clear_prefix("BufferLine")
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    enabled = false,
    lazy = true,
  },
}
