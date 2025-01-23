return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    sources = { "filesystem", "buffers", "git_status" },
    open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        always_show = { -- remains visible even if other settings would normally hide it
          ".config",
        },
        hide_by_name = {
          ".git",
          ".DS_Store",
          "thumbs.db",
          "build_pal_deploy",
          "install_pal_deploy",
          "build_pal_deploy_release",
          "install_pal_deploy_release",
        },
      },
      bind_to_cwd = false,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
    window = {
      mappings = {
        ["l"] = "open",
        ["h"] = "close_node",
        ["<space>"] = "none",
        ["Y"] = {
          function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg("+", path, "c")
          end,
          desc = "Copy Path to Clipboard",
        },
        ["O"] = {
          function(state)
            require("lazy.util").open(state.tree:get_node().path, { system = true })
          end,
          desc = "Open with System Application",
        },
        ["P"] = { "toggle_preview", config = { use_float = false } },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      git_status = {
        symbols = {
          unstaged = "󰄱",
          staged = "󰱒",
        },
      },
    },
  },

  { "jamestthompson3/nvim-remote-containers" },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    opts = {},
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
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
            name = "Launch robot_joint_limit_estimator",
            program = "/home/user/exchange/validation_ros2_ws/install/robot_joint_limit_estimator/lib/robot_joint_limit_estimator/joint_limit_estimator_node",
            args = {
              "--ros-args --log-level DEBUG --ros-args -r __node:=joint_limit_estimator --params-file /home/user/exchange/validation_ros2_ws/install/robot_joint_limit_estimator/share/robot_joint_limit_estimator/config/tiago_motions.yaml --params-file /home/user/exchange/validation_ros2_ws/install/robot_joint_limit_estimator/share/robot_joint_limit_estimator/config/tiago_configuration.yaml --params-file /tmp/launch_params_nix_ez3t",
            },
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
