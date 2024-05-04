return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "clangd",
        "clang-format",
        "codelldb",
        "cpplint",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opt = {
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
  },
  {
    "stevearc/conform.nvim",
    opts = function()
      ---@class ConformOpts
      local opts = {
        -- LazyVim will use these options when formatting with the conform.nvim formatter
        format = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_fallback = true, -- not recommended to change
        },
        ---@type table<string, conform.FormatterUnit[]>
        formatters_by_ft = {
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
          cpp = { "clang-format" },
          hpp = { "clang-format" },
        },
        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
          -- # Example of using dprint only when a dprint.json file is present
          -- dprint = {
          --   condition = function(ctx)
          --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          --   end,
          -- },
          --
          -- # Example of using shfmt with extra args
          -- shfmt = {
          --   prepend_args = { "-i", "2", "-ci" },
          -- },
        },
      }
      return opts
    end,
  },
}
