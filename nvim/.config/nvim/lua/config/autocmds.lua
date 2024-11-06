-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Saves file automatically when leaving insert mode
-- vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
--   pattern = { "*" },
--   command = "silent! wall",
--   nested = true,
-- })
-- ====================================================
-- Uncrustify
-- ====================================================
vim.api.nvim_create_user_command(
  "Uncrustify",
  -- ":!uncrustify -c /home/ekramer/evobot_ecosystem/humble_ws/ament_code_style.cfg --replace %:p -q --no-backup", {}
  ":!ament_uncrustify --reformat %:p",
  {}
)
