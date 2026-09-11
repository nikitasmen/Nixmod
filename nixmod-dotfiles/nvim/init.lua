-- NixMod Neovim Configuration
-- Plugin specs live one-per-file under lua/plugins/ (each file returns a lazy.nvim
-- spec table); require("lazy").setup("plugins") below imports the whole directory.

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load options and keymaps
require("options")
require("keymaps")

-- Load plugins
require("lazy").setup("plugins")
