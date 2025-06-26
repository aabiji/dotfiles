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
  "stevearc/conform.nvim",
  { "Fildo7525/pretty_hover", event = "LspAttach", opts = {border=false} },
  "saghen/blink.cmp",
  "nvim-telescope/telescope.nvim",
  "lewis6991/gitsigns.nvim",
  "nvim-lualine/lualine.nvim",
  "catppuccin/nvim",
  "nvim-treesitter/nvim-treesitter",
})

vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.undofile = false
vim.opt.cmdheight = 0
vim.opt.number = true
vim.opt.splitbelow = true
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.tabstop = 4

require("catppuccin").setup({ flavour = "macchiato", no_italic = true })
vim.cmd.colorscheme("catppuccin")

require('nvim-treesitter.configs').setup({
  ensure_installed = {"comment"},
  auto_install = true, highlight = { enable = true },
})
require("lualine").setup()

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
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('zls')

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

vim.keymap.set("n", "ge", vim.diagnostic.goto_next, { desc = "Go to next error" })
vim.keymap.set("n", "gE", vim.diagnostic.goto_prev, { desc = "Go to previous error" })

vim.keymap.set("n", "K", function() require("pretty_hover").hover() end)

vim.keymap.set("n", 'gd', require('telescope.builtin').lsp_definitions)
vim.keymap.set("n", 'gr', require('telescope.builtin').lsp_references)
vim.keymap.set("n", 'gi', require('telescope.builtin').lsp_implementations)

require('gitsigns').setup()
vim.cmd("hi SignColumn guibg=NONE")

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

-- Autoformat
require("conform").setup({
  formatters_by_ft = {
    go = { "goimports", "gofmt" },
    rust = { lsp_format = "fallback" },
    javascript = { "prettierd", "prettier", stop_after_first = true }
  }
})

-- Autoformat
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
