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
  "nvim-lualine/lualine.nvim",
  "nvim-treesitter/nvim-treesitter",
  "wakatime/vim-wakatime",
  "Mofiqul/dracula.nvim",
})

vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "no"
vim.opt.swapfile = false
vim.opt.undofile = false
vim.opt.cmdheight = 0
vim.opt.number = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 4
vim.opt.scrolloff = 20
vim.opt.cursorlineopt = "number"
vim.opt.cursorline = true

require('nvim-treesitter.configs').setup({
  ensure_installed = {"comment"},
  auto_install = true, highlight = { enable = true },
})
vim.cmd.colorscheme("dracula")
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})

require("mason").setup()
vim.lsp.enable('clangd')
vim.lsp.enable('ts_ls')
vim.lsp.enable('gopls')

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

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Space>ff', builtin.find_files)
vim.keymap.set('n', '<Space>fg', builtin.live_grep)
vim.keymap.set('n', '<Space>fb', builtin.buffers)
vim.keymap.set("n", "<Space>fd", vim.diagnostic.setloclist)

vim.keymap.set("i", '<C-h>', '<C-W>')
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
    vim.cmd("vertical G diff HEAD")
end)

vim.keymap.set("n", "<Space>gg", function() -- Git commit
    vim.cmd("G add .")
    vim.cmd("vertical G commit")
end)

-- Git push after commit
vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "COMMIT_EDITMSG",
  callback = function()
    vim.defer_fn(function()
      vim.cmd("G push")
    end, 1000)
  end,
})

-- Disable mouse when typing
vim.api.nvim_create_autocmd("InsertEnter", { callback = function() vim.opt.mouse = "" end })

-- Re-enable mouse when leaving Insert mode
vim.api.nvim_create_autocmd("InsertLeave", { callback = function() vim.opt.mouse = "a" end })
