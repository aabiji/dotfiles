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
  { "folke/tokyonight.nvim", config = function() vim.cmd.colorscheme("tokyonight-storm") end },
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
  { "RRethy/vim-illuminate", config = function() require('illuminate').configure() end },
  { "mason-org/mason.nvim", opts = {} },
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
        vim.keymap.set("n", "K",  vim.lsp.buf.hover)
        vim.keymap.set("n", "gr", vim.lsp.buf.references)
        vim.keymap.set("n", "ga", vim.lsp.buf.rename)
        vim.keymap.set("n", "ge", vim.diagnostic.goto_next)

        vim.keymap.set("n", "gd", function()
          local params = vim.lsp.util.make_position_params()
          local res = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 500)
          for _, r in pairs(res or {}) do
            if r.result and not vim.tbl_isempty(r.result) then
              return vim.lsp.util.jump_to_location(r.result[1], "utf-8")
            end
          end
          vim.cmd("normal! /\\<" .. vim.fn.expand("<cword>") .. "\\><CR>")
        end, { buffer = bufnr })

      end

      local servers = { "clangd", "ts_ls", "gopls", "rust_analyzer", "zls", "ruff" }
      for _, server in ipairs(servers) do
        lspconfig[server].setup({ on_attach = on_attach })
      end
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      local builtin = require("telescope.builtin")
      local themes = require("telescope.themes")
      local ivy_no_right_border = themes.get_ivy({
        borderchars = {
          prompt  = {" ", " ", " ", " ", " ", "─", " ", " "},
          results = {" ", " ", " ", " ", " ", "─", " ", " "},
          preview = {" ", " ", " ", " ", " ", "─", " ", " "},
        },
      })
      vim.keymap.set("n", "<Space>ff", function()
        builtin.find_files(ivy_no_right_border)
      end)
      vim.keymap.set("n", "<Space>fg", function()
        builtin.live_grep(ivy_no_right_border)
      end)
      vim.keymap.set("n", "<Space>fb", function()
        builtin.buffers(ivy_no_right_border)
      end)
      vim.keymap.set("n", "<Space>fh", function()
        builtin.help_tags(ivy_no_right_border)
      end)
    end,
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
vim.opt.cmdheight = 0
vim.wo.fillchars = 'eob: '
vim.opt.shortmess:append("I")
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("i", "<C-h>", "<C-W>")
vim.keymap.set("n", "0", "_")
vim.keymap.set("n", "_", "0")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-n>", ":split<CR>")
vim.keymap.set("n", "<C-m>", ":vsplit<CR>")
vim.keymap.set("i", "<C-Backspace>", "<C-W>")
