-- General options and keybindings
vim.loader.enable() -- Cache compiled lua modules

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = false
vim.o.smartcase = false
vim.o.signcolumn = "yes"

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.fillchars = {eob = " ", vert = " "}

vim.o.inccommand = "split"
vim.o.cursorline = false
vim.o.confirm = false

vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-m>", ":vsplit<CR>")
vim.keymap.set("n", "<C-n>", ":split<CR>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<Space>z", function()
  vim.cmd("NoNeckPain")
  local enabled = vim.opt.number:get()
  vim.opt.number = not enabled
  vim.opt.relativenumber = not enabled
end)

-- Hodpodge of plugins
vim.pack.add({ "https://github.com/lunacookies/vim-colors-xcode" })
vim.cmd[[colo xcodedarkhc]]

vim.api.nvim_create_autocmd("BufReadPost", {
  once = true,
  callback = function()
    vim.pack.add({ "https://github.com/NMAC427/guess-indent.nvim" })
    require("guess-indent").setup({})
  end,
})

vim.pack.add({ "https://github.com/shortcuts/no-neck-pain.nvim" })

vim.api.nvim_create_autocmd("BufReadPre", {
  once = true,
  callback = function()
    vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })
    require("gitsigns").setup({})
  end,
})

-- Telescope fuzzy finder
local telescope_plugins = {
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
}
vim.pack.add(telescope_plugins)

local function telescope()
  vim.pack.add(telescope_plugins)
  return require("telescope.builtin")
end

vim.keymap.set("n", "<leader>ff", telescope().find_files)
vim.keymap.set("n", "<leader>fg", telescope().live_grep)
vim.keymap.set("n", "<leader>/",  telescope().current_buffer_fuzzy_find)

-- LSP support
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
  callback = function(event)
    vim.keymap.set("n", "gr", telescope().lsp_references, { buffer = event.buf })
    vim.keymap.set("n", "gd", telescope().lsp_definitions, { buffer = event.buf })
    vim.keymap.set("n", "gr", vim.lsp.buf.rename, { buffer = event.buf })
    vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { buffer = event.buf })
    vim.keymap.set("n", "ge", function()
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
    end)
  end,
})

vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
})

vim.diagnostic.config({ underline = false })

local servers = { basedpyright = {} } --, clangd = {}, }
require("mason").setup({})
require("mason-tool-installer").setup({ ensure_installed = vim.tbl_keys(servers) })

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

-- Autoformatting
vim.api.nvim_create_autocmd("BufWritePre", {
  once = true,
  callback = function()
    vim.pack.add({
      "https://github.com/stevearc/conform.nvim"
    })

    require("conform").setup({
      notify_on_error = false,
      format_on_save = { timeout_ms = 500 },
    })
  end,
})

-- Autocomplete
vim.pack.add({
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp" 
})
require("blink.cmp").setup({
  keymap = { preset = "enter" },
  completion = { documentation = { auto_show = true } },
  signature = { enabled = true },
})

-- Latex
vim.pack.add({ "https://github.com/lervag/vimtex" })
vim.g.vimtex_view_method = "okular"
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_quickfix_mode = 2
vim.g.vimtex_quickfix_ignore_filters = { 'Underfull', 'Overfull', 'Package hyperref Warning' }
vim.g.vimtex_compiler_latexmk = {
  options = { "-pdf", "-outdir=pdf", "-synctex=1", "-interaction=nonstopmode" }
}

local group = vim.api.nvim_create_augroup("LatexAutoCompile", { clear = true })
vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VimtexEventInitPost",
    callback = function()
        vim.cmd("VimtexCompile")
    end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    if vim.b.vimtex then
      pcall(vim.cmd, "VimtexStopAll")
    end
  end,
})

-- Treesitter syntax highlighting
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

local function treesitter_try_attach(buf, language)
  if not vim.treesitter.language.add(language) then
    return
  end

  vim.treesitter.start(buf, language)

  local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil
  if has_indent_query then
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

local available_parsers = require("nvim-treesitter").get_available()
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local buf, filetype = args.buf, args.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then
      return
    end

    local installed_parsers = require("nvim-treesitter").get_installed("parsers")

    if vim.tbl_contains(installed_parsers, language) then
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      require("nvim-treesitter").install(language):await(function()
        treesitter_try_attach(buf, language)
      end)
    else
      treesitter_try_attach(buf, language)
    end
  end,
})
