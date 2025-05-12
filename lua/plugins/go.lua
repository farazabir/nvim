return {
    {
      "ray-x/go.nvim",
      dependencies = {
        "ray-x/guihua.lua",           
        "neovim/nvim-lspconfig",     
        "mfussenegger/nvim-dap",     
        "rcarriga/nvim-dap-ui",      
        "nvim-neotest/nvim-nio",      
        "nvim-treesitter/nvim-treesitter",
      },
      lazy = false,
      config = function()
        local project_name = vim.fn.input("Enter Go project name (e.g., myapp): ")
        if project_name == "" then
          project_name = "default-go-project"
          vim.notify("No project name provided, using fallback: " .. project_name, vim.log.levels.WARN)
        end
  
        -- 2. Setup go.nvim
        require("go").setup({
          goimport = "gopls", 
          gofmt = "gopls",       
          max_line_len = 120,       
          tag_transform = "snakecase",
          test_dir = "",            
          comment_placeholder = "  ",
          lsp_cfg = false,           
          lsp_gofumpt = true,        
          dap_debug = true,         
          dap_debug_gui = true,     
        })
  
        -- 3. Configure gopls with LSP
        local lspconfig = require("lspconfig")
        lspconfig.gopls.setup({
          cmd = { "gopls" },
          root_dir = lspconfig.util.root_pattern("go.mod", ".git"),
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              gofumpt = true,
            },
          },
          on_attach = function(client, bufnr)
            vim.notify("gopls attached successfully", vim.log.levels.INFO)
            require("go.dap").setup()
            vim.notify("Go DAP setup complete", vim.log.levels.INFO)
          end,
        })
        local dap = require("dap")
        dap.adapters.go = {
          type = "executable",
          command = "dlv",
          args = { "dap", "-l", "127.0.0.1:38697" },
        }
        dap.configurations.go = {
          {
            type = "go",
            name = "Debug",
            request = "launch",
            program = "${file}",
            env = {},            
            args = {},        
          },
          {
            type = "go",
            name = "Debug Package",
            request = "launch",
            program = "${workspaceFolder}",
          },
          {
            type = "go",
            name = "Debug Test",
            request = "launch",
            mode = "test",
            program = "${file}",
          },
        }
  
        local dapui = require("dapui")
        dapui.setup({
          layouts = {
            {
              elements = {
                { id = "scopes", size = 0.25 },
                { id = "breakpoints", size = 0.25 },
                { id = "stacks", size = 0.25 },
                { id = "watches", size = 0.25 },
              },
              size = 40,
              position = "left",
            },
            {
              elements = { "repl" },
              size = 10,
              position = "bottom",
            },
          },
        })
  
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
          vim.notify("DAP session initialized", vim.log.levels.INFO)
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
  
        vim.keymap.set("n", "<F5>", function()
          dap.continue()
          vim.notify("Starting DAP with config: " .. vim.inspect(dap.configurations.go), vim.log.levels.INFO)
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
  
        vim.keymap.set("n", "<Leader>gr", ":GoRun<CR>", { noremap = true, silent = true, desc = "Go: Run" })
        vim.keymap.set("n", "<Leader>gt", ":GoTest<CR>", { noremap = true, silent = true, desc = "Go: Test" })
        vim.keymap.set("n", "<Leader>gf", ":GoFmt<CR>", { noremap = true, silent = true, desc = "Go: Format" })
        vim.keymap.set("n", "<Leader>gi", ":GoImport<CR>", { noremap = true, silent = true, desc = "Go: Import" })
  
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "go", "gomod" },
          highlight = { enable = true },
          filters = {
            dotfiles = false,
            },
        })
      end,
      event = { "CmdlineEnter" },
      ft = { "go", "gomod" },
      build = ':lua require("go.install").update_all_sync()', 
    },
  }