local Util = require("lazyvim.util")

return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>/",
      Util.telescope("live_grep", { cwd = false }),
      desc = "Live grep cwd",
    },
  },
}
