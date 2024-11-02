vim.opt.number = false
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = false
vim.opt.cmdheight = 0
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.fillchars = {eob = " "}

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<M-m>", ":vsplit<CR>")
vim.keymap.set("n", "<M-n>", ":split<CR>")
vim.keymap.set("n", "<M-h>", "<C-w><C-h>")
vim.keymap.set("n", "<M-l>", "<C-w><C-l>")
vim.keymap.set("n", "<M-j>", "<C-w><C-j>")
vim.keymap.set("n", "<M-k>", "<C-w><C-k>")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "tpope/vim-sleuth",
  { "lewis6991/gitsigns.nvim", opts = {} },
  {
    "kaicataldo/material.vim",
    config = function()
      vim.cmd.colorscheme("material")
      vim.cmd.hi("Comment gui=none")
      vim.cmd [[
        highlight Normal guibg=none
        highlight NonText guibg=none
        highlight Normal ctermbg=none
        highlight NonText ctermbg=none
        highlight WinSeparator guifg=#546e7a ctermfg=145
        highlight SignColumn guibg=none
      ]]
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<Space>ff", builtin.find_files)
      vim.keymap.set("n", "<Space>fg", builtin.live_grep)
      vim.keymap.set("n", "<Space>fb", builtin.buffers)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = { "comment" },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = {},
      },
      indent = { enable = true, disable = {} },
    }
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require('lualine').setup({
        options = {
          icons_enabled = false,
          component_separators = { left = ' ', right = ' '},
          section_separators = { left = ' ', right = ' '},
          globalstatus = true,
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {}, lualine_y = {},
          lualine_z = {'location'}
        },
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "ms-jpq/coq_nvim", "ms-jpq/coq.artifacts",
      "williamboman/mason-lspconfig.nvim", "williamboman/mason.nvim"
    },
    init = function()
      vim.g.coq_settings = { auto_start = "shut-up" }
    end,
    config = function()
      require("mason").setup({})
      require("mason-lspconfig").setup({
        ensure_installed = {"clangd", "rust_analyzer", "pyright", "gopls", "ts_ls"},
      })

      local lsp = require("lspconfig")
      local coq = require("coq")
      lsp.clangd.setup(coq.lsp_ensure_capabilities())
      lsp.pyright.setup(coq.lsp_ensure_capabilities())
      lsp.rust_analyzer.setup(coq.lsp_ensure_capabilities())
      lsp.gopls.setup(coq.lsp_ensure_capabilities())
      lsp.ts_ls.setup(coq.lsp_ensure_capabilities())

      vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions)
      vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references)
      vim.keymap.set('n', 'gI', require('telescope.builtin').lsp_implementations)
    end
  }
})
