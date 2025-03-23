return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "elmcgill/springboot-nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-jdtls",
    },
    config = function()
      local springboot_nvim = require("springboot-nvim")
      -- Keybindings
      vim.keymap.set('n', '<leader>Jr', springboot_nvim.boot_run, { desc = "Spring Boot Run Project" })
      vim.keymap.set('n', '<leader>Jc', springboot_nvim.generate_class, { desc = "Java Create Class" })
      vim.keymap.set('n', '<leader>Ji', springboot_nvim.generate_interface, { desc = "Java Create Interface" })
      vim.keymap.set('n', '<leader>Je', springboot_nvim.generate_enum, { desc = "Java Create Enum" })
      -- Setup
      springboot_nvim.setup({})
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('telescope').setup {
        defaults = {
          layout_strategy = 'flex',
          layout_config = {
            width = 0.9,
            height = 0.9,
          },
        },
      }
    end,
  }

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}