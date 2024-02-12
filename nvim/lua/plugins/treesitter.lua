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
  end,
  ensure_installed = { "markdown", "markdown_inline" },
  highlight = {
    enable = true,
  },
}
