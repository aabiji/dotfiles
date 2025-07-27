vim.opt.undofile = true
vim.opt.swapfile = false

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

vim.opt.tabstop = 4
vim.opt.colorcolumn = "80"
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0

vim.keymap.set("i", '<C-h>', '<C-W>')
vim.keymap.set("n", "0", "_")
vim.keymap.set("n", "_", "0")

vim.keymap.set("n", '<C-l>', '<C-w>l')
vim.keymap.set("n", '<C-j>', '<C-w>j')
vim.keymap.set("n", '<C-k>', '<C-w>k')
vim.keymap.set("n", '<C-h>', '<C-w>h')
vim.keymap.set("n", '<C-n>', ':split<CR>')
vim.keymap.set("n", '<C-m>', ':vsplit<CR>')

vim.pack.add({
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/catppuccin/nvim",
})

require("catppuccin").setup({
  flavour = "macchiato",
  transparent_background = true,
  no_bold = true
})
vim.cmd.colorscheme("catppuccin")
vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })

require("lualine").setup()
require('gitsigns').setup()
require("mason").setup()

require('nvim-treesitter.configs').setup({
  ensure_installed = {"comment"},
  auto_install = true, highlight = { enable = true },
})

require("blink.cmp").setup({
  completion = { documentation = { auto_show = true } },
  fuzzy = { implementation = "lua" },
  keymap = {
    preset = 'enter',
    ['<Tab>'] = { 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'fallback' },
  }
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', 'ff', builtin.find_files)
vim.keymap.set('n', 'fg', builtin.live_grep)
vim.keymap.set('n', 'fb', builtin.buffers)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K",  vim.lsp.buf.hover)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "ga", vim.lsp.buf.rename)
vim.keymap.set("n", "ge", vim.diagnostic.goto_next)

local servers = { "clangd", "ts_ls", "gopls", "rust_analyzer", "zls", "pylsp" }
for _, server in ipairs(servers) do
  vim.lsp.enable(server)
end
