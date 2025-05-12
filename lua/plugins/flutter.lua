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
      "dart-lang/dart-vim-plugin", 
      {
        "akinsho/flutter-tools.nvim", 
        dependencies = {
          "nvim-lua/plenary.nvim",
        },
      },
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "dartls" }, 
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Dart LSP setup (dartls) - Managed by flutter-tools
      lspconfig.dartls.setup({
        capabilities = capabilities,
        filetypes = { "dart" },
        root_dir = lspconfig.util.root_pattern("pubspec.yaml", ".git"),
      })

      -- Flutter Tools setup
      require("flutter-tools").setup({
        lsp = {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            local opts = { buffer = bufnr, noremap = true, silent = true }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            -- Auto-format on save
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ async = false })
              end,
            })
          end,
          settings = {
            dart = {
              completeFunctionCalls = true,
              analysisExcludedFolders = { ".dart_tool", "build" },
              enableSdkFormatter = true,
            },
          },
        },
        flutter_path = vim.fn.exepath("flutter"), -- Automatically detect flutter binary
        fvm = false, -- Set to true if using FVM (Flutter Version Management)
        widget_guides = {
          enabled = true, -- Show widget guides (lines connecting widget hierarchy)
        },
        closing_tags = {
          enabled = true, -- Auto-insert closing tags
        },
        dev_log = {
          enabled = true, -- Show Flutter dev log in a split
          open_cmd = "split", -- Options: "split", "vsplit", "tabnew"
        },
        outline = {
          enabled = true, -- Show outline of Dart file
          auto_open = false, -- Open outline manually with keymap
        },
        dev_tools = {
          autostart = false, 
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
          { name = "nvim_lsp" }, -- LSP (dartls via flutter-tools)
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- Custom keymaps for flutter-tools
      vim.keymap.set("n", "<leader>fr", "<Cmd>FlutterRun<CR>", { desc = "Run Flutter app" })
      vim.keymap.set("n", "<leader>fq", "<Cmd>FlutterQuit<CR>", { desc = "Quit Flutter app" })
      vim.keymap.set("n", "<leader>fR", "<Cmd>FlutterReload<CR>", { desc = "Hot Reload" })
      vim.keymap.set("n", "<leader>fS", "<Cmd>FlutterRestart<CR>", { desc = "Hot Restart" })
      vim.keymap.set("n", "<leader>fd", "<Cmd>FlutterDevices<CR>", { desc = "List Devices" })
      vim.keymap.set("n", "<leader>fo", "<Cmd>FlutterOutlineToggle<CR>", { desc = "Toggle Outline" })
      vim.keymap.set("n", "<leader>fl", "<Cmd>FlutterDevLog<CR>", { desc = "Open Dev Log" })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "dart" },
        highlight = { enable = true },
        filters = {
          dotfiles = false,
          },
      })
    end,
  },
}