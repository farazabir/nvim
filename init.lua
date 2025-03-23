-- ~/.config/nvim/init.lua
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

vim.cmd([[command! Runjava term /usr/lib/jvm/java-21-openjdk-amd64/bin/java -cp /home/farazabir/personal/leetcode/app/bin/main org.example.App]])

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end
vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- Load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
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
    end, 50)
  end,
})

-- Load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"



vim.schedule(function()
  require "mappings"
end)