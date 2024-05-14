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
    opts = {
      servers = {
        -- ruff = {
        --   -- on_attach = function(client, bufnr)
        --   --   if client.name == "ruff_lsp" then
        --   --     -- Disable hover in favor of Pyright
        --   --     client.server_capabilities.hoverProvider = false
        --   --   end
        --   -- end,
        --   init_options = {
        --     settings = {
        --       -- Any extra CLI arguments for `ruff` go here.
        --       args = {},
        --     },
        --   },
        -- },
        lemminx = {
          filetypes = { "launch" },
        },
        -- Ensure mason installs the server
        clangd = {
          keys = {
            { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
              fname
            ) or require("lspconfig.util").find_git_ancestor(fname)
          end,
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      },
      setup = {
        clangd = function(_, opts)
          local clangd_ext_opts = require("lazyvim.util").opts("clangd_extensions.nvim")
          require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
          return false
        end,
      },
    },
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
