-- ~/.config/nvim/init.lua
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

<<<<<<< HEAD
vim.cmd([[command! Runjava term /usr/lib/jvm/java-21-openjdk-amd64/bin/java -cp /home/farazabir/personal/leetcode/app/bin/main org.example.App]])

-- Bootstrap lazy.nvim
=======
vim.api.nvim_create_user_command("Runjava", function()
  local project_root = vim.fn.findfile("build.gradle.kts", ".;")
  if project_root == "" then
    vim.notify("No build.gradle found", vim.log.levels.ERROR)
    return
  end
  project_root = vim.fn.fnamemodify(project_root, ":h")
  local class_file = project_root .. "/build/classes/java/main/org/example/App.class"
  local source_file = project_root .. "/src/main/java/org/example/App.java"
  local cmd
  if vim.fn.filereadable(class_file) == 1 and
     vim.fn.filereadable(source_file) == 1 and
     vim.fn.getftime(class_file) >= vim.fn.getftime(source_file) then
    cmd = "term cd " .. project_root .. " && /usr/bin/java -cp build/classes/java/main org.example.App"
  else
    cmd = "term cd " .. project_root .. " && gradle build -x test  && /usr/bin/java -cp build/classes/java/main org.example.App"
  end
  vim.cmd(cmd)
end, { desc = "Build if needed and run Java application" })

>>>>>>> origin/master
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end
vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

<<<<<<< HEAD
-- Load plugins
require("lazy").setup({
=======

require("lazy").setup({
  { import = "plugins" },        
  { import = "plugins.java" }, 
  {import = "plugins.web"},
  {import = "plugins.rn"},
>>>>>>> origin/master
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
<<<<<<< HEAD
  { import = "plugins" },
}, lazy_config)


-- Ensure Telescope is loaded
require('telescope').setup {}

-- Create an autocommand to trigger Telescope on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Delay slightly to ensure Neovim is fully loaded
    vim.defer_fn(function()
      require('telescope.builtin').find_files()
=======
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "javascript", "typescript", "tsx", "html", "python" },
        highlight = { enable = true },
        autotag = { enable = true },
      })
    end,
  },

  { import = "plugins.python" }, 
  -- GitHub Copilot
  {
    "github/copilot.vim",
    lazy = true,
     cmd = { "Copilot", "Copilot enable", "Copilot disable" },
    config = function()
      vim.g.copilot_no_tab_map = false
      vim.api.nvim_set_keymap("i", "<Tab>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
      vim.g.copilot_filetypes = {
        ["*"] = true,
      }
      vim.api.nvim_set_keymap("n", "<leader>ce", ":Copilot enable<CR>", { noremap = true, silent = true, desc = "Enable Copilot" })
      vim.api.nvim_set_keymap("n", "<leader>cd", ":Copilot disable<CR>", { noremap = true, silent = true, desc = "Disable Copilot" })
      vim.api.nvim_create_user_command("CopilotEnable", "Copilot enable", { desc = "Enable Copilot" })
      vim.api.nvim_create_user_command("CopilotDisable", "Copilot disable", { desc = "Disable Copilot" })
    end,
  },
}, lazy_config)

-- Telescope setup
require("telescope").setup {}
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      require("telescope.builtin").find_files()
>>>>>>> origin/master
    end, 50)
  end,
})

-- Load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

<<<<<<< HEAD


=======
>>>>>>> origin/master
vim.schedule(function()
  require "mappings"
end)