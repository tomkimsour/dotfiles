local pattern = "([^:]+):(%d+):(%d+):(%d+):(%d+): (%a+): (.*) %[(%a[%a-]+)%]"
local groups = { "file", "lnum", "col", "end_lnum", "end_col", "severity", "message", "code" }
local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  note = vim.diagnostic.severity.HINT,
}

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        cpp = { "cpplint" },
        hpp = { "cpplint" },
        -- python = { "ament_mypy" },
        -- ["launch"] = { "ament_mypy" },
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
      },
    },
  },
  -- Let clangd query the Nix gcc/clang driver so it discovers libstdc++ and
  -- other implicit system include paths (they are NOT in compile_commands.json).
  -- Without --query-driver, clangd falls back to /usr/include (absent on NixOS)
  -- and every file "Failed to compile, index may be incomplete".
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.clangd = opts.servers.clangd or {}
      local cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=Google",
        "--enable-config",
      }
      local query_driver = "--query-driver="
        .. table.concat({
          "/nix/store/*/bin/*gcc",
          "/nix/store/*/bin/*g++",
          "/nix/store/*/bin/*cc",
          "/nix/store/*/bin/*c++",
          "/nix/store/*/bin/*clang",
          "/nix/store/*/bin/*clang++",
        }, ",")
      local has_query_driver = false
      for _, arg in ipairs(cmd) do
        if type(arg) == "string" and arg:match("^%-%-query%-driver=") then
          has_query_driver = true
          break
        end
      end
      if not has_query_driver then
        table.insert(cmd, query_driver)
      end
      opts.servers.clangd.cmd = cmd
      return opts
    end,
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
          rust = { "rustfmt", lsp_format = "fallback" },
          python = function(bufnr)
            if require("conform").get_formatter_info("ruff", bufnr).available then
              return {
                -- To fix auto-fixable lint errors.
                "ruff_fix",
                -- To run the Ruff formatter.
                "ruff_format",
                -- To organize the imports.
                "ruff_organize_imports",
              }
            else
              return { "isort", "black" }
            end
          end,
          sh = { "shfmt" },
          zsh = { "shfmt" },
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
                vim.env.AMENT_UNCRUSTIFY_CONFIG_FILE
                  or "/opt/ros/humble/lib/python3.10/site-packages/ament_uncrustify/configuration/ament_code_style.cfg",
                "--no-backup",
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
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            -- Add clippy lints for Rust if using rust-analyzer
            checkOnSave = diagnostics == "rust-analyzer",
            -- Enable diagnostics if using rust-analyzer
            diagnostics = {
              enable = diagnostics == "rust-analyzer",
            },
            procMacro = {
              enable = true,
            },
            files = {
              exclude = {
                ".direnv",
                ".git",
                ".jj",
                ".github",
                ".gitlab",
                "bin",
                "node_modules",
                "target",
                "venv",
                ".venv",
              },
              -- Avoid Roots Scanned hanging, see https://github.com/rust-lang/rust-analyzer/issues/12613#issuecomment-2096386344
              watcher = "client",
            },
          },
        },
      },
    },
    config = function(_, opts)
      if LazyVim.has("mason.nvim") then
        local codelldb = vim.fn.exepath("codelldb")
        local codelldb_lib_ext = io.popen("uname"):read("*l") == "Linux" and ".so" or ".dylib"
        local library_path = vim.fn.expand("$MASON/opt/lldb/lib/liblldb" .. codelldb_lib_ext)
        opts.dap = {
          adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
        }
      end
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
      if vim.fn.executable("rust-analyzer") == 0 then
        LazyVim.error(
          "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
          { title = "rustaceanvim" }
        )
      end
    end,
  },
}
