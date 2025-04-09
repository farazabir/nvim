return {
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
      config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = { "tsserver", "eslint", "tailwindcss" }, 
          automatic_installation = true,
        })
  
        local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
  
        -- TypeScript/JavaScript LSP setup (tsserver)
        lspconfig.tsserver.setup({
          capabilities = capabilities,
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
          root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
          on_attach = function(client, bufnr)
            local opts = { buffer = bufnr, noremap = true, silent = true }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            -- Disable tsserver formatting if using prettier/eslint
            client.server_capabilities.documentFormattingProvider = false
          end,
        })
  
        -- ESLint for linting and fixing
        lspconfig.eslint.setup({
          capabilities = capabilities,
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
          root_dir = lspconfig.util.root_pattern("package.json", ".eslintrc", ".git"),
          settings = {
            workingDirectory = { mode = "auto" },
          },
          on_attach = function(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "EslintFixAll",
            })
          end,
        })
  
        -- Tailwind CSS LSP setup
        lspconfig.tailwindcss.setup({
          capabilities = capabilities,
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
          root_dir = lspconfig.util.root_pattern("tailwind.config.js", "tailwind.config.ts", "package.json", ".git"),
          settings = {
            tailwindCSS = {
              classAttributes = { "class", "className", "style" }, 
              experimental = {
                classRegex = { "tw`([^`]*)`", "className=\"([^\"]*)\"" }, 
              },
            },
          },
        })
  
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        cmp.setup({
          completion = {
            autocomplete = { "InsertEnter", "TextChanged" }, 
          },
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
          }),
        })
      end,
    },
  
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "javascript", "typescript", "tsx", "json" },
          highlight = { enable = true },
          autotag = { enable = true },
        })
      end,
    },
  
    {
      "nvim-lua/plenary.nvim",
      config = function()
        -- Command to run React Native app (assumes metro bundler)
        vim.api.nvim_create_user_command("RunReactNative", function()
          local root = vim.fn.findfile("package.json", ".;")
          if root == "" then
            vim.notify("No package.json found", vim.log.levels.ERROR)
            return
          end
          local project_root = vim.fn.fnamemodify(root, ":h")
          vim.cmd("term cd " .. project_root .. " && npx react-native run-android") -- or run-ios
        end, { desc = "Run React Native app" })
  
        -- Keymap for running the app
        vim.keymap.set("n", "<leader>rr", ":RunReactNative<CR>", { desc = "Run React Native app" })
  
        -- Command to start Metro bundler
        vim.api.nvim_create_user_command("StartMetro", function()
          local root = vim.fn.findfile("package.json", ".;")
          if root == "" then
            vim.notify("No package.json found", vim.log.levels.ERROR)
            return
          end
          local project_root = vim.fn.fnamemodify(root, ":h")
          vim.cmd("term cd " .. project_root .. " && npx react-native start")
        end, { desc = "Start Metro bundler" })
  
        -- Keymap for starting Metro
        vim.keymap.set("n", "<leader>rm", ":StartMetro<CR>", { desc = "Start Metro bundler" })
      end,
    },
  }