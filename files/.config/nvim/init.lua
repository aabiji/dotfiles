-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" if not (vim.uv or vim.loop).fs_stat(lazypath) then
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
    "tpope/vim-fugitive",
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "nvim-telescope/telescope.nvim",
    "saghen/blink.cmp",
    "f-person/auto-dark-mode.nvim",
    "projekt0n/github-nvim-theme",
    "nvim-lualine/lualine.nvim"
})

vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "no"
vim.opt.swapfile = false
vim.opt.cmdheight = 0
vim.opt.number = true
vim.opt.splitbelow = true
vim.opt.splitright = true

require("mason").setup()
vim.lsp.enable('clangd')

require("blink.cmp").setup({
    completion = { documentation = { auto_show = true } },
    fuzzy = { implementation = "lua" },
    keymap = {
        preset = 'enter',
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
    }
})

require("lualine").setup({
  options = {
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    globalstatus = true,
  },
  sections = {
    lualine_a = {}, lualine_b = {},
    lualine_c = {'mode', 'branch', 'diff', 'diagnostics','filename'},
    lualine_x = {'location'}, lualine_y = {}, lualine_z = {},
  },
})

require("auto-dark-mode").setup({
   set_dark_mode = function()
        vim.cmd.colorscheme("github_dark_default")
    end,
    set_light_mode = function()
        vim.cmd.colorscheme("github_light_default")
    end
})


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Space>ff', builtin.find_files)
vim.keymap.set('n', '<Space>fg', builtin.live_grep)
vim.keymap.set('n', '<Space>fb', builtin.buffers)
vim.keymap.set("n", "<Space>fd", vim.diagnostic.setloclist)

vim.keymap.set("i", '<C-Backspace>', '<C-W>')
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

vim.keymap.set("n", "<Space>gd", function() -- Git diff
    vim.cmd("G add .")
    vim.cmd("G diff HEAD")
end)

vim.keymap.set("n", "<Space>gg", function() -- Git commit
    vim.cmd("G add .")
    vim.cmd("G commit")
end)
