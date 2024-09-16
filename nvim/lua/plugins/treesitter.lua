return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- add tsx and treesitter
    vim.list_extend(opts.ensure_installed, {
      "tsx",
      "typescript",
      "markdown",
      "markdown_inline",
    })
    opts.parsers.get_parser_configs().just = {
      install_info = {
        url = "https://github.com/IndianBoy42/tree-sitter-just", -- local path or git repo
        files = { "src/parser.c", "src/scanner.c" },
        branch = "main",
        -- use_makefile = true -- this may be necessary on MacOS (try if you see compiler errors)
      },
    }
  end,
  ensure_installed = { "markdown", "markdown_inline" },
  highlight = {
    enable = true,
  },
  {
    "IndianBoy42/tree-sitter-just",
  },
}
