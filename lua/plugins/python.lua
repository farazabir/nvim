
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
        ensure_installed = { "pylsp" },
        automatic_installation = true,
      })

      -- Virtual environment detection
      local function get_python_path()
        local venv = vim.fn.finddir(".venv", vim.fn.getcwd() .. ";") or vim.fn.finddir("venv", vim.fn.getcwd() .. ";")
        if venv ~= "" then
          return vim.fn.resolve(venv .. "/bin/python")
        end
        return vim.fn.exepath("python3") or vim.fn.exepath("python")
      end

      -- Pylsp LSP setup
      local lspconfig = require("lspconfig")
      lspconfig.pylsp.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = { enabled = true }, -- Linting
              mypy = { enabled = true },        -- Type checking (optional)
              black = { enabled = true },       -- Formatting (optional)
              jedi_completion = { enabled = true, fuzzy = true }, -- Better completions
            },
          },
        },
        on_attach = function(client, bufnr)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
        before_init = function(_, config)
          config.settings.pylsp.executable = get_python_path()
        end,
      })

      -- Autocompletion with nvim-cmp (automatic triggering)
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        completion = {
          autocomplete = { "InsertEnter", "TextChanged" }, -- Trigger suggestions automatically
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(), -- Manual trigger still available
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
          { name = "nvim_lsp" }, -- Priority to LSP (pylsp)
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Optional: Python-specific commands
  {
    "nvim-lua/plenary.nvim",
    config = function()
      vim.api.nvim_create_user_command("RunPython", function()
        local file = vim.fn.expand("%:p")
        local python = vim.fn.exepath("python3") or vim.fn.exepath("python")
        vim.cmd("term " .. python .. " " .. file)
      end, { desc = "Run current Python file" })
      vim.keymap.set("n", "<leader>rp", ":RunPython<CR>", { desc = "Run Python file" })
    end,
  },
}