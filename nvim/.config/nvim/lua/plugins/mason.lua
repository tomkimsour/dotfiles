return {
  {
    -- Ensure C/C++ debugger is installed
    "mason-org/mason.nvim",
    version = "1.11.0",
    optional = true,
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "codelldb" })
      end
    end,
  },
  {
    require("mason-lspconfig").setup_handlers({
      -- Default handler
      function(server_name)
        require("lspconfig")[server_name].setup({})
      end,
    }),
  },
}
