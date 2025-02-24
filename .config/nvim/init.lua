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
vim.cmd[[set signcolumn=yes]] -- Always show the gutter
vim.cmd[[set shortmess+=I]] -- Don't show welcome message

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-m>", ":vsplit<CR>")
vim.keymap.set("n", "<C-n>", ":split<CR>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "0", "_")
vim.keymap.set("n", "_", "0")
vim.keymap.set("i", "<C-BS>", "<C-w>")
vim.api.nvim_set_keymap("n", "ga", "<C-^>", { noremap = true, silent = true })

-- Diagnostic icons
vim.diagnostic.config {
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = " ",
        },
    },
}
vim.diagnostic.config({virtual_text=false}) -- Don't show warnings at the side

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
        "olimorris/onedarkpro.nvim",
        config = function()
            require("onedarkpro").setup({colors = {dark = {bg = "#14161a"}}})
        end,
    },
    {
        "f-person/auto-dark-mode.nvim",
        opts = {
            set_dark_mode = function()
                vim.cmd("colorscheme onedark")
            end,
            set_light_mode = function()
                vim.cmd("colorscheme onelight")
            end,
            fallback = "light"
        }
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
        config = function()
            require'nvim-treesitter.configs'.setup({
                auto_install = true,
                highlight = { enable = true }
            })
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require('lualine').setup({
                options = {
                  icons_enabled = false,
                  globalstatus = true,
                  component_separators = { left = '', right = ''},
                  section_separators = { left = '', right = ''},
                },
                sections = {
                  lualine_a = {},
                  lualine_b = { 'branch', 'diff', 'diagnostics' },
                  lualine_c = { 'filename', 'navic' },
                  lualine_x = {}, lualine_y = {'location'},
                  lualine_z = {}
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
            vim.g.coq_settings = { auto_start = "shut-up", keymap =  { jump_to_mark = "<c-\\" }, }
        end,
        config = function()
            local on_attach = function(client, buffer)
                -- Autoformat
                require("lsp-format").on_attach(client, buffer)

                -- Disable semantic highlight
                if client.server_capabilities.semanticTokensProvider then
                    client.server_capabilities.semanticTokensProvider = nil
                end

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
