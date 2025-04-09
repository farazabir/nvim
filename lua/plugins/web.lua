return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neoconf.nvim",
    },
    config = function()
      -- Ensure Mason is set up
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "eslint",       
          "ts_ls",         
          "tailwindcss",  
          "prettierd",    
        },
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")

      lspconfig.ts_ls.setup({
        root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
        single_file_support = true,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      lspconfig.eslint.setup({
        root_dir = lspconfig.util.root_pattern("package.json", ".eslintrc", ".git"),
        settings = {
          format = false,
          lintTask = {
            enable = true,
          },
        },
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })

      -- Tailwind CSS LSP
      lspconfig.tailwindcss.setup({
        root_dir = lspconfig.util.root_pattern("tailwind.config.js", "tailwind.config.ts", "package.json", ".git"),
        settings = {
          tailwindCSS = {
            classAttributes = { "class", "className", "ngClass" },
            experimental = {
              classRegex = {
                "tw\\(['\"]([^'\"]*)['\"]\\)", -- Matches tw('...') for template literals
              },
            },
          },
        },
      })
    end,
  },

  -- Null-ls for formatting
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettierd.with({
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "css", "html" },
          }),
          null_ls.builtins.diagnostics.eslint_d.with({
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
          }),
        },
        -- Format on save
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
      })
    end,
  },

  -- nvim-ts-autotag for auto-tagging
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter" }, -- Load on insert mode for better performance
    config = function()
      require("nvim-ts-autotag").setup({
        filetypes = {
          "html",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "jsx",
          "tsx",
          'ts',
          "xml",
        },
      })
    end,
  },
}

-- -- DAP for React Native debugging
-- {
--   "mfussenegger/nvim-dap",
--   dependencies = {
--     "rcarriga/nvim-dap-ui",
--     "nvim-neotest/nvim-nio",
--   },
--   config = function()
--     local dap = require("dap")
--     dap.adapters.node2 = {
--       type = "executable",
--       command = "node",
--       args = { "/path/to/vscode-node-debug2/out/src/nodeDebug.js" }, 
--     }
--     dap.configurations.typescriptreact = {
--       {
--         type = "node2",
--         request = "launch",
--         name = "Launch React Native",
--         program = "${workspaceFolder}/node_modules/.bin/react-native",
--         args = { "run-android" },
--         cwd = "${workspaceFolder}",
--         sourceMaps = true,
--         protocol = "inspector",
--       },
--     }

--     local dapui = require("dapui")
--     dapui.setup()
--     dap.listeners.after.event_initialized["dapui_config"] = function()
--       dapui.open()
--     end
--     dap.listeners.before.event_terminated["dapui_config"] = function()
--       dapui.close()
--     end
--     dap.listeners.before.event_exited["dapui_config"] = function()
--       dapui.close()
--     end
--   end,
-- }, 