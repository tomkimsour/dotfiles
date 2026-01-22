return {
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    opts = {},
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  },
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      if not dap.adapters["codelldb"] then
        require("dap").adapters["codelldb"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "codelldb",
            args = {
              "--port",
              "${port}",
            },
          },
        }
      end
      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = {
          {
            type = "codelldb",
            request = "launch",
            name = "Launch file",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
          },
          {
            type = "codelldb",
            request = "launch",
            name = "Debug Test files",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/tests", "file")
            end,
            -- args = {
            --   "--ros-args --log-level DEBUG --ros-args -r __node:=joint_limit_estimator --params-file /home/user/exchange/validation_ros2_ws/install/robot_joint_limit_estimator/share/robot_joint_limit_estimator/config/tiago_motions.yaml --params-file /home/user/exchange/validation_ros2_ws/install/robot_joint_limit_estimator/share/robot_joint_limit_estimator/config/tiago_configuration.yaml --params-file /tmp/launch_params_nix_ez3t",
            -- },
            cwd = "${workspaceFolder}",
          },
          {
            type = "codelldb",
            request = "attach",
            name = "Attach to process",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
}
