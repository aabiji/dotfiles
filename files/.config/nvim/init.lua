local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "pappasam/papercolor-theme-slim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("PaperColorSlimLight")
      vim.cmd[[autocmd ColorScheme PaperColorSlim,PaperColorSlimLight highlight Normal guibg=NONE]]
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "comment" },
        auto_install = true,
        highlight = { enable = true },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      local lspconfig = require("lspconfig")

      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end
        vim.keymap.set("n", "gd", vim.lsp.buf.definition)
        vim.keymap.set("n", "K",  vim.lsp.buf.hover)
        vim.keymap.set("n", "gr", vim.lsp.buf.references)
        vim.keymap.set("n", "ga", vim.lsp.buf.rename)
        vim.keymap.set("n", "ge", vim.diagnostic.goto_next)
      end

      local servers = { "clangd", "ts_ls", "gopls", "rust_analyzer", "zls", "pylsp" }
      for _, server in ipairs(servers) do
        lspconfig[server].setup({ on_attach = on_attach })
      end
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      explorer = { enabled = true },
      picker = {
        enabled = true,
        sources = {
          explorer = {layout = {auto_hide = { "input" }}},
        },
        layout = { preset = function() return "ivy" end, },
      },
      quickfile = { enabled = true },
    },
    keys = {
      { "<space>ff", function() Snacks.explorer() end },
      { "<space>fg", function() Snacks.picker.grep() end },
      { "<space>fb", function() Snacks.picker.buffers() end },
      { "<space>gd", function() Snacks.picker.git_diff() end, },
    }
  },
  {
    "saghen/blink.cmp",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local cmp = require('blink.cmp')
      cmp.setup({
        completion = { documentation = { auto_show = true } },
        fuzzy = { implementation = "lua" },
        keymap = {
          preset = 'enter',
          ['<Tab>'] = { 'select_next', 'fallback' },
          ['<S-Tab>'] = { 'select_prev', 'fallback' },
          ['<PageUp>'] = { function() for i = 1, 5 do cmp.select_prev() end end, },
          ['<PageDown>'] = { function() for i = 1, 5 do cmp.select_next() end end, },
        }
      })
    end,
  },
  { "lewis6991/gitsigns.nvim", config = true },
  { "tpope/vim-sleuth" },
})

vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 4
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.wo.fillchars = 'eob: '
vim.cmd[[highlight Normal guibg=NONE]]
vim.keymap.set("i", "<C-h>", "<C-W>")
vim.keymap.set("n", "0", "_")
vim.keymap.set("n", "_", "0")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-n>", ":split<CR>")
vim.keymap.set("n", "<C-m>", ":vsplit<CR>")
