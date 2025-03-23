-- ~/.config/nvim/lua/plugins/java.lua
return {
  {
    "nvim-java/nvim-java",
    lazy = false,
    dependencies = {
      "nvim-java/lua-async-await",
      "neovim/nvim-lspconfig",
      "folke/neoconf.nvim",
      "MunifTanjim/nui.nvim",
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      -- 1. Initialize nvim-java first
      require('java').setup({
        root_markers = { "build.gradle", ".git", "pom.xml" }, -- For Gradle project detection
        jdk = {
          path = "/usr/lib/jvm/java-21-openjdk-amd64",
        },
      })

      -- 2. Set up jdtls after nvim-java
      local ok, err = pcall(function()
        require("lspconfig").jdtls.setup({
          root_dir = require("lspconfig.util").root_pattern("build.gradle", ".git"),
          settings = {
            java = {
              configuration = {
                runtimes = {
                  {
                    name = "JavaSE-21",
                    path = "/usr/lib/jvm/java-21-openjdk-amd64",
                  },
                },
              },
            },
          },
        })
      end)
      if not ok then
        vim.notify("nvim-java setup failed: " .. err, vim.log.levels.ERROR)
      end

      -- 3. Configure DAP and DAP UI
      local dap = require("dap")
      dap.defaults.fallback.terminal_win_cmd = "belowright new"
      dap.defaults.fallback.focus_terminal = true

      local dapui = require("dapui")
      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}