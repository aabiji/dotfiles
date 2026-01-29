vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.shortmess:append("I")
vim.keymap.set('n', '0', '_')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-m>', ':vsplit<CR>')
vim.keymap.set('n', '<C-n>', ':split<CR>')
vim.keymap.set('i', '<C-Backspace>', '<C-w>')
vim.keymap.set('n', '<PageUp>', ':tabprev<CR>')
vim.keymap.set('n', '<PageDown>', ':tabnext<CR>')
