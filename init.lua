vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

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

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end
vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"


require("lazy").setup({
  { import = "plugins" },        
  { import = "plugins.java" }, 
  {import = "plugins.web"},
  {import = "plugins.rn"},
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "javascript", "typescript", "tsx", "html", "python" },
        highlight = { enable = true },
        autotag = { enable = true },
        filters = { dotfliles = false },
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
require("telescope").setup {
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      },
    },
    file_ignore_patterns = { "node_modules", "%.class", "%.git/" },
  },
  pickers = {
    find_files = {
      hidden = true, 
      
    },
    live_grep = {
      additional_args = function()
        return { "--hidden", "--glob", "!**/.git/*" } 
      end,
    },
  },
}

vim.api.nvim_set_keymap(
  "n",
  "<leader>fw",
  [[<cmd>lua require('telescope.builtin').live_grep({ default_text = vim.fn.expand('<cword>') })<CR>]],
  { noremap = true, silent = true, desc = "Search word under cursor" }
)

vim.api.nvim_set_keymap(
  "n",
  "<leader>fs",
  [[<cmd>lua require('telescope.builtin').live_grep()<CR>]],
  { noremap = true, silent = true, desc = "Search with input" }
)

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      require("telescope.builtin").find_files()
    end, 50)
  end,
})

dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)
