vim.opt.mouse = "a"
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
vim.opt.fillchars = { eob = " " }
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.cursorline = false
vim.opt.relativenumber = false
vim.cmd[[set shortmess+=I]]

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-t>", ":tabnew<CR>")
vim.keymap.set("n", "<C-k>", ":tabnext<CR>")
vim.keymap.set("n", "<C-j>", ":tabprev<CR>")
vim.keymap.set("n", "<M-m>", ":vsplit<CR>")
vim.keymap.set("n", "<M-n>", ":split<CR>")
vim.keymap.set("n", "<M-h>", "<C-w><C-h>")
vim.keymap.set("n", "<M-l>", "<C-w><C-l>")
vim.keymap.set("n", "<M-j>", "<C-w><C-j>")
vim.keymap.set("n", "<M-k>", "<C-w><C-k>")
vim.keymap.set("n", "0", "_")
vim.keymap.set("n", "_", "0")
vim.keymap.set("i", "<C-BS>", "<C-w>")

-- Disale auto commenting
vim.cmd [[autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]]

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
    {
        "tpope/vim-sleuth",
        config = function()
            -- Javascript and typescript should use 2 spaces for indentation
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
                callback = function()
                    vim.opt_local.tabstop = 2
                    vim.opt_local.shiftwidth = 2
                    vim.opt_local.expandtab = true
                end,
            })
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({})
        end
    },
    {
        "sindrets/diffview.nvim",
        config = function()
            require("diffview").setup({})
            toggle = 1
            function toggleDiffView()
                if toggle == 1 then
                    vim.cmd[[DiffviewOpen]]
                    toggle = 2
                else
                    vim.cmd[[DiffviewClose]]
                    toggle = 1
                end
            end
            vim.keymap.set("n", "<C-g>", ":lua toggleDiffView()<CR>")
        end
    },
    {
	"catppuccin/nvim",
        priority = 1000,
        config = function()
	   require("catppuccin").setup({})
           vim.cmd.colorscheme("catppuccin-macchiato")
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
    },
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            local custom_catppuccin = require("lualine.themes.catppuccin-macchiato")
            custom_catppuccin.normal.a.bg = "#24273a"
            custom_catppuccin.normal.a.fg = "#cad3f5"
            custom_catppuccin.normal.c.bg = "#24273a"
            require('lualine').setup({
                options = {
                  icons_enabled = false,
                  globalstatus = true,
                  component_separators = { left = '', right = ''},
                  section_separators = { left = '', right = ''},
                  theme = custom_catppuccin
                },
                sections = {
                  lualine_a = {},
                  lualine_b = { 'branch', 'diff', 'diagnostics' },
                  lualine_c = { 'filename', 'navic' },
                  lualine_x = {}, lualine_y = {},
                  lualine_z = { 'location' }
                },
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = {
            "ms-jpq/coq_nvim", "ms-jpq/coq.artifacts",
            "williamboman/mason-lspconfig.nvim", "williamboman/mason.nvim",
            "SmiteshP/nvim-navic",
            "lukas-reineke/lsp-format.nvim"
        },
        init = function()
            -- No message from our auto comple plugin!
            vim.g.coq_settings = { auto_start = "shut-up" }
        end,
        config = function()
            local on_attach = function(client, buffer)
                -- Autoformat
                require("lsp-format").on_attach(client, buffer)

                -- LSP Breadcrumbs
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, buffer)
                end
            end

            local handlers = {
                function(server_name) -- Handler for all lsp servers
                    local coq = require("coq")
                    local server = require("lspconfig")[server_name]
                    server.setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))
                end
            }

            require("mason").setup({})
            require("mason-lspconfig").setup({
                handlers = handlers,
                ensure_installed = { "clangd", "rust_analyzer", "pyright", "gopls", "ts_ls" }
            })

            vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions)
            vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references)
            vim.keymap.set('n', 'gI', require('telescope.builtin').lsp_implementations)
            vim.keymap.set('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>')
        end
    }
})
