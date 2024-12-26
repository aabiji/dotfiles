vim.opt.number = false
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
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.number = true
vim.opt.relativenumber = true

-- TODO: define keybinding for go to definition in vertical split
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
    "tpope/vim-sleuth",
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({})
        end
    },
    {
        "shaunsingh/nord.nvim",
        config = function()
            vim.g.nord_bold = false
            vim.g.nord_italic = false
            vim.g.nord_borders = true
            vim.g.nord_contrast = true
            vim.cmd.colorscheme "nord"
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
                options = { icons_enabled = false, globalstatus = true },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = { 'filename', 'navic' },
                    lualine_x = {},
                    lualine_y = {},
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

                -- Disable semantic highlighting
                client.server_capabilities.semanticTokensProvider = nil

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
        end
    }
})
