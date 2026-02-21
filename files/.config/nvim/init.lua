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

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("RemoveTrailingWhitespace", { clear = true }),
  callback = function()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
  end,
})

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
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- Only open a new tab if I'm not in a split
      local function smart_select(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if vim.fn.winnr('$') == 1 then
          vim.cmd("tab drop " .. entry.path)
        else
          vim.cmd("edit " .. entry.path)
        end
      end

      require('telescope').setup({
        defaults = {
          border = false,
          layout_strategy = 'bottom_pane',
          layout_config = { height = 25 },
          mappings = {
            i = { ["<CR>"] = smart_select, },
            n = { ["<CR>"] = smart_select, },
          },
        },
      })
    end,
  },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'williamboman/mason.nvim', config = true }, 'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason-lspconfig').setup({ automatic_installation = true })

      local servers = { 'clangd', 'pyright', 'ts_ls', 'rust_analyzer', 'gopls' }
      for _, lsp in ipairs(servers) do
        vim.lsp.enable(lsp)
      end

      local function tab_jump(location)
        local uri = location.uri or location.targetUri
        local range = location.range or location.targetSelectionRange
        local file = vim.uri_to_fname(uri)
        vim.opt.lazyredraw = true
        vim.cmd("silent tab drop " .. vim.fn.fnameescape(file))
        vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
        vim.opt.lazyredraw = false
      end

      local function goto_definition()
        local params = vim.lsp.util.make_position_params()

        vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
          if not result or vim.tbl_isempty(result) then
            return
          end

          if vim.tbl_islist(result) and #result > 1 then
            require("telescope.builtin").lsp_definitions({
              jump_type = "tab",
            })
            return
          end

          tab_jump(vim.tbl_islist(result) and result[1] or result)
        end)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          client.server_capabilities.semanticTokensProvider = nil

          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })

          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", goto_definition, opts)
          vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'ge', vim.diagnostic.goto_next, opts)
          vim.keymap.set('n', 'ga', vim.lsp.buf.rename, opts)
        end,
      })
    end,
  },

  {
    'saghen/blink.cmp',
    version = '*',
    opts = {
      keymap = {
        preset = 'none',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    }
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = "master",
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = { "comment", "lua" },
      })
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    config = function()
      require('lualine').setup({
        sections = {
          lualine_a = {'mode'}, lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'}, lualine_x = {}, lualine_y = {}, lualine_z = {'location'}
        },
      })
    end
  },

  {
    "rebelot/kanagawa.nvim",
    config = function()
      require('kanagawa').setup({
          compile = true,
          undercurl = true,
          commentStyle = { italic = true },
          functionStyle = {},
          keywordStyle = { italic = false },
          statementStyle = { bold = false },
          typeStyle = {},
          transparent = false,
          dimInactive = false,
          terminalColors = true,
          theme = "wave",
          })
    vim.cmd("colorscheme kanagawa")
    end,
  },

  { 'wakatime/vim-wakatime', lazy = false },
  { 'lewis6991/gitsigns.nvim', event = { 'BufReadPre', 'BufNewFile' }, config = true },
  { 'nmac427/guess-indent.nvim', event = { 'BufReadPre', 'BufNewFile' }, config = true },
},{
  performance = { rtp = { reset = false } },
})
