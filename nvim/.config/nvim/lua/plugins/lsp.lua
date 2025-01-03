local pattern = "([^:]+):(%d+):(%d+):(%d+):(%d+): (%a+): (.*) %[(%a[%a-]+)%]"
local groups = { "file", "lnum", "col", "end_lnum", "end_col", "severity", "message", "code" }
local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  note = vim.diagnostic.severity.HINT,
}

return {
  {
    "folke/neoconf.nvim",
    opts = {

      -- name of the local settings files
      local_settings = ".neoconf.json",
      -- name of the global settings file in your Neovim config directory
      global_settings = "neoconf.json",
      -- import existing settings from other plugins
      import = {
        vscode = true, -- local .vscode/settings.json
        coc = true, -- global/local coc-settings.json
        nlsp = true, -- global/local nlsp-settings.nvim json settings
      },
      -- send new configuration to lsp clients when changing json settings
      live_reload = true,
      -- set the filetype to jsonc for settings files, so you can use comments
      -- make sure you have the jsonc treesitter parser installed!
      filetype_jsonc = true,
      plugins = {
        -- configures lsp clients with settings in the following order:
        -- - lua settings passed in lspconfig setup
        -- - global json settings
        -- - local json settings
        lspconfig = {
          enabled = true,
        },
        -- configures jsonls to get completion in .nvim.settings.json files
        jsonls = {
          enabled = true,
          -- only show completion in json settings for configured lsp servers
          configured_servers_only = true,
        },
        -- configures lua_ls to get completion of lspconfig server settings
        lua_ls = {
          -- by default, lua_ls annotations are only enabled in your neovim config directory
          enabled_for_neovim_config = true,
          -- explicitely enable adding annotations. Mostly relevant to put in your local .nvim.settings.json file
          enabled = false,
        },
      },
    },
  },
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
        "cpplint",
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        cpp = { "cpplint" },
        hpp = { "cpplint" },
        python = { "ament_mypy" },
        ["launch"] = { "ament_mypy" },
        -- Use the "*" filetype to run linters on all filetypes.
        -- ['*'] = { 'global linter' },
        -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
        -- ['_'] = { 'fallback linter' },
        -- ["*"] = { "typos" },
      },
      -- LazyVim extension to easily override linter options
      -- or add custom linters.
      linters = {
        -- To find how to configure cpplint I looked at the source code under ~/.local and I used ros2 ament_cpplint source code as a reference
        cpplint = {
          cmd = "cpplint",
          args = {
            "--counting=detailed",
            "--extensions=c,cc,cpp,cxx",
            "--headers=h,hh,hpp,hxx",
            "--linelength=100",
            "--filter=-build/c++11,-runtime/references,-whitespace/braces,-whitespace/indent,-whitespace/parens,-whitespace/semicolon",
          },
        },
        ament_mypy = {
          cmd = "mypy",
          stdin = false,
          ignore_exitcode = true,
          -- mypy --config-file /opt/ros/humble/lib/python3.10/site-packages/ament_mypy/configuration/ament_mypy.ini robot_state_publisher.launch.py
          args = {
            "--config-file",
            "/opt/ros/humble/lib/python3.10/site-packages/ament_mypy/configuration/ament_mypy.ini",
            "$FILENAME",
            function()
              return vim.fn.exepath("python3") or vim.fn.exepath("python")
            end,
          },
          -- When returns false, the formatter will not be used
          -- condition = function()
          --   -- Check if ament_mypy is in PATH
          --   return vim.fn.executable("ament_mypy") == 1
          -- end,
          parser = require("lint.parser").from_pattern(
            pattern,
            groups,
            severities,
            { ["source"] = "mypy" },
            { end_col_offset = 0 }
          ),
        },
        -- -- Example of using selene only when a selene.toml file is present
        -- selene = {
        --   -- `condition` is another LazyVim extension that allows you to
        --   -- dynamically enable/disable linters based on the context.
        --   condition = function(ctx)
        --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- options for vim.diagnostic.config()
      ---@type vim.diagnostic.Opts
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
          -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
          -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
          -- prefix = "icons",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
          },
        },
      },
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = true,
      },
      -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the code lenses.
      codelens = {
        enabled = false,
      },
      -- add any global capabilities here
      capabilities = {},
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the LazyVim formatter,
      -- but can be also overridden when specified
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
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
            )
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
            "--fallback-style=Google",
            "--enable-config",
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
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_fallback = true, -- not recommended to change
        },
        formatters_by_ft = {
          lua = { "stylua" },
          python = function(bufnr)
            if require("conform").get_formatter_info("ruff", bufnr).available then
              return { "ruff" }
            else
              return { "isort", "black" }
            end
          end,
          sh = { "shfmt" },
          cpp = { "clang-format", "ament_uncrustify" },
          hpp = { "clang-format", "ament_uncrustify" },
          json = { "prettierd" },
          xml = { "xmlformat" },
          urdf = { "xmlformat" },
          xacro = { "xmlformat" },
          tex = { "latexindent" },
          bib = { "latexindent" },
        },
        lang_to_ext = {
          bash = "sh",
          latex = "tex",
          markdown = "md",
          python = "py",
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
          ament_uncrustify = {
            command = "uncrustify",
            args = function(self, ctx)
              return {
                "-q",
                "-l",
                vim.bo[ctx.buf].filetype:upper(),
                "-c",
                "/opt/ros/humble/lib/python3.10/site-packages/ament_uncrustify/configuration/ament_code_style.cfg",
                "--replace",
              }
            end,
            -- When returns false, the formatter will not be used
            condition = function()
              -- Check if ament_uncrustify is in PATH
              return vim.fn.executable("ament_uncrustify") == 1
            end,
          },
        },
      }
      return opts
    end,
  },
}
