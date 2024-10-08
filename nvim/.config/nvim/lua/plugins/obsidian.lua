return {
  "epwalsh/obsidian.nvim",
  enabled = true,
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  -- ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    "BufReadPre ~/Documents/work_vault/**.md",
    "BufNewFile ~/Documents/work_vault/**.md",
    "BufReadPre /Users/tomkimsour/Documents/Obsidian Vault/**.md",
    "BufNewFile /Users/tomkimsour/Documents/Obsidian Vault/**.md",
  },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter",
  },
  opts = {
    workspaces = {
      {
        name = "Work vault",
        path = "~/Documents/work_vault/",
      },
    },
    log_level = vim.log.levels.INFO,
  },
}
