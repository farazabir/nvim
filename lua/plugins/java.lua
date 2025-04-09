<<<<<<< HEAD
-- ~/.config/nvim/lua/plugins/java.lua
=======
>>>>>>> origin/master
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
<<<<<<< HEAD
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
=======
      -- 1. Prompt for projectName
      local project_name = vim.fn.input("Enter project name (e.g., leetcode): ")
      if project_name == "" then
        project_name = "default-project" -- Fallback if no input provided
        vim.notify("No project name provided, using fallback: " .. project_name, vim.log.levels.WARN)
      end

      -- 2. Initialize nvim-java with the provided projectName
      require("java").setup({
        root_markers = { "build.gradle", ".git", "pom.xml", "settings.gradle.kts" },
        jdk = {
          path = "/usr/lib/jvm/java-21-openjdk",
        },
        projectName = project_name, -- Use the user-provided name
      })
      vim.notify("Project name set to: " .. project_name, vim.log.levels.INFO)

      -- 3. Set up JDTLS with DAP integration
      local ok, err = pcall(function()
        require("lspconfig").jdtls.setup({
          root_dir = require("lspconfig.util").root_pattern("build.gradle", ".git", "pom.xml", "settings.gradle.kts"),
          cmd = {
            "env", "JAVA_HOME=/usr/lib/jvm/java-21-openjdk", "/usr/bin/jdtls",
            "--jvm-arg=-Xmx2G",
          },
          on_attach = function(client, bufnr)
            vim.notify("JDTLS attached successfully", vim.log.levels.INFO)
            require("jdtls").setup_dap({ hotcodereplace = "auto" })
            vim.notify("JDTLS DAP setup complete", vim.log.levels.INFO)

            -- Set DAP configuration with the provided projectName
            local dap = require("dap")
            if not dap.configurations.java then
              dap.configurations.java = {
                {
                  type = "java",
                  request = "launch",
                  name = "Launch Java",
                  mainClass = "", -- Prompt for this later
                  projectName = project_name, -- Use the user-provided name
                },
              }
            end
          end,
>>>>>>> origin/master
          settings = {
            java = {
              configuration = {
                runtimes = {
<<<<<<< HEAD
                  {
                    name = "JavaSE-21",
                    path = "/usr/lib/jvm/java-21-openjdk-amd64",
                  },
=======
                  { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk" },
>>>>>>> origin/master
                },
              },
            },
          },
        })
      end)
      if not ok then
<<<<<<< HEAD
        vim.notify("nvim-java setup failed: " .. err, vim.log.levels.ERROR)
      end

      -- 3. Configure DAP and DAP UI
=======
        vim.notify("JDTLS setup failed: " .. err, vim.log.levels.ERROR)
      end

      -- 4. Configure DAP and DAP UI
>>>>>>> origin/master
      local dap = require("dap")
      dap.defaults.fallback.terminal_win_cmd = "belowright new"
      dap.defaults.fallback.focus_terminal = true

      local dapui = require("dapui")
      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
<<<<<<< HEAD
=======
        vim.notify("DAP session initialized", vim.log.levels.INFO)
>>>>>>> origin/master
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
<<<<<<< HEAD
=======

      -- 5. Keymaps with mainClass prompt for LeetCode flexibility
      vim.keymap.set("n", "<F5>", function()
        local main_class = vim.fn.input("Enter main class (e.g., Solution): ")
        if main_class ~= "" then
          dap.configurations.java[1].mainClass = main_class
        else
          vim.notify("No main class provided, DAP may fail if not set", vim.log.levels.WARN)
        end
        vim.notify("Starting DAP with config: " .. vim.inspect(dap.configurations.java), vim.log.levels.INFO)
        dap.continue()
      end, { noremap = true, silent = true, desc = "DAP: Start/Continue" })
      vim.keymap.set("n", "<F10>", function() dap.step_over() end, { noremap = true, silent = true, desc = "DAP: Step Over" })
      vim.keymap.set("n", "<F11>", function() dap.step_into() end, { noremap = true, silent = true, desc = "DAP: Step Into" })
      vim.keymap.set("n", "<F12>", function() dap.step_out() end, { noremap = true, silent = true, desc = "DAP: Step Out" })
      vim.keymap.set("n", "<Leader>br", function()
        dap.toggle_breakpoint()
        vim.notify("Breakpoint toggled at line " .. vim.fn.line("."), vim.log.levels.INFO)
      end, { noremap = true, silent = false, desc = "DAP: Toggle Breakpoint" })
      vim.keymap.set("n", "<Leader>dt", function() dap.terminate() end, { noremap = true, silent = true, desc = "DAP: Terminate" })
      vim.keymap.set("n", "<Leader>du", function() dapui.toggle() end, { noremap = true, silent = true, desc = "DAP UI: Toggle" })
>>>>>>> origin/master
    end,
  },
}