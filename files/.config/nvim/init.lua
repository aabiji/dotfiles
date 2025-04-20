-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },      
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    "tpope/vim-sleuth",
    "nvim-telescope/telescope.nvim",
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "f-person/auto-dark-mode.nvim",
    "maxmx03/solarized.nvim"
})

require("auto-dark-mode").setup({
    set_dark_mode = function()
        vim.cmd[[set background=dark]]
    end,
    set_light_mode = function()
        vim.cmd[[set background=light]]
    end,
})

require("mason").setup()
vim.lsp.enable('clangd')

vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "no"
vim.opt.swapfile = false
vim.opt.cmdheight = 0
vim.opt.number = true
vim.cmd.colorscheme("solarized")

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Space>ff', builtin.find_files)
vim.keymap.set('n', '<Space>fg', builtin.live_grep)
vim.keymap.set('n', '<Space>fb', builtin.buffers)
vim.keymap.set("n", "<Space>fd", vim.diagnostic.setloclist)

vim.keymap.set("i", '\b', '<C-W>')
vim.keymap.set("n", "0", "_")
vim.keymap.set("n", "_", "0")

vim.keymap.set("n", '<C-l>', '<C-w>l')
vim.keymap.set("n", '<C-j>', '<C-w>j')
vim.keymap.set("n", '<C-k>', '<C-w>k')
vim.keymap.set("n", '<C-h>', '<C-w>h')
vim.keymap.set("n", '<C-n>', ':split<CR>')
vim.keymap.set("n", '<C-m>', ':vsplit<CR>')

vim.keymap.set("n", 'gd', require('telescope.builtin').lsp_definitions)
vim.keymap.set("n", 'gr', require('telescope.builtin').lsp_references)
vim.keymap.set("n", 'gi', require('telescope.builtin').lsp_implementations)
