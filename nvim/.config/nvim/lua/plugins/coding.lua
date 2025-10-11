return {
  -- {
  --   "folke/ts-comments.nvim",
  --   opts = {
  --     lang = {
  --       c = "// %s",
  --       cpp = "// %s",
  --       launch = "<!-- %s -->",
  --       gleam = "// %s",
  --       glimmer = "{{! %s }}",
  --       graphql = "# %s",
  --       html = "<!-- %s -->",
  --       ini = "; %s",
  --       ipynb = "# %s",
  --       rust = { "// %s", "/* %s */" },
  --       sql = "-- %s",
  --       svelte = "<!-- %s -->",
  --       typescript = { "// %s", "/* %s */" }, -- langs can have multiple commentstrings
  --       vue = "<!-- %s -->",
  --       xml = "<!-- %s -->",
  --     },
  --   },
  --   event = "VeryLazy",
  -- },
  {
    "p00f/clangd_extensions.nvim",
    opts = {
      -- inlay_hints = {
      --   inline = vim.fn.has("nvim-0.10") == 1,
      --   -- Options other than `highlight' and `priority' only work
      --   -- if `inline' is disabled
      --   -- Only show inlay hints for the current line
      --   only_current_line = false,
      --   -- Event which triggers a refresh of the inlay hints.
      --   -- You can make this { "CursorMoved" } or { "CursorMoved,CursorMovedI" } but
      --   -- note that this may cause higher CPU usage.
      --   -- This option is only respected when only_current_line is true.
      --   only_current_line_autocmd = { "CursorHold" },
      --   -- whether to show parameter hints with the inlay hints or not
      --   show_parameter_hints = true,
      --   -- prefix for parameter hints
      --   parameter_hints_prefix = "<- ",
      --   -- prefix for all the other hints (type, chaining)
      --   other_hints_prefix = "=> ",
      --   -- whether to align to the length of the longest line in the file
      --   max_len_align = false,
      --   -- padding from the left if max_len_align is true
      --   max_len_align_padding = 1,
      --   -- whether to align to the extreme right or not
      --   right_align = false,
      --   -- padding from the right if right_align is true
      --   right_align_padding = 7,
      --   -- The color of the hints
      --   highlight = "Comment",
      --   -- The highlight group priority for extmark
      --   priority = 100,
      -- },
      ast = {
        -- These require codicons (https://github.com/microsoft/vscode-codicons)
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },

        kind_icons = {
          Compound = "",
          Recovery = "",
          TranslationUnit = "",
          PackExpansion = "",
          TemplateTypeParm = "",
          TemplateTemplateParm = "",
          TemplateParamObject = "",
        },
        highlights = {
          detail = "Comment",
        },
      },
      memory_usage = {
        border = "none",
      },
      symbol_info = {
        border = "none",
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    optional = true,
    opts = function()
      require("copilot.api").status = require("copilot.status")
    end,
  },
  -- {
  --   "benlubas/molten-nvim",
  --   version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
  --   lazy = false,
  --   dependencies = { "3rd/image.nvim" },
  --   build = ":UpdateRemotePlugins",
  --   init = function()
  --     -- these are examples, not defaults. Please see the readme
  --     vim.g.molten_image_provider = "image.nvim"
  --     vim.g.molten_output_win_max_height = 20
  --     vim.g.molten_use_border_highlights = true
  --     vim.g.molten_output_win_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
  --     -- add a few new things
  --     -- Auto open/close output window
  --     vim.g.molten_auto_open_output = true
  --     -- Wrap output
  --     vim.g.molten_wrap_output = true
  --     -- Show virtual text for cell status
  --     vim.g.molten_virt_text_output = true
  --
  --     -- don't change the mappings (unless it's related to your bug)
  --   end,
  -- },
  -- {
  --   -- see the image.nvim readme for more information about configuring this plugin
  --   "3rd/image.nvim",
  --   opts = {
  --     backend = "kitty", -- whatever backend you would like to use
  --     max_width = 100,
  --     max_height = 12,
  --     max_height_window_percentage = math.huge,
  --     max_width_window_percentage = math.huge,
  --     window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
  --     window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
  --   },
  -- },
  -- {
  --   "GCBallesteros/jupytext.nvim",
  --   config = function()
  --     require("jupytext").setup({
  --       style = "markdown", -- or "light", "markdown"
  --       output_extension = "py", -- or "md", "jl", etc.
  --       force_ft = "python", -- force filetype
  --       custom_language_formatting = {},
  --     })
  --   end,
  --   ft = { "ipynb" },
  --   lazy = false,
  -- },
}
