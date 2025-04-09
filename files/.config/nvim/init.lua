-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.opt.number = true
vim.opt.cmdheight = 0
vim.opt.clipboard = 'unnamedplus'
vim.opt.signcolumn = 'no'
vim.cmd[[
  " Reset the horizontal scroll when moving up/down lines
  set nowrap
  nnoremap <silent> j zHj
  nnoremap <silent> k zHk
  set shortmess+=I
]]
 
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-m>', ':vsplit<CR>')
vim.keymap.set('n', '<C-n>', ':split<CR>')
vim.keymap.set('i', '<C-Backspace>', '<C-W>')
vim.keymap.set('n', '0', '_')
vim.keymap.set('n', '_', '0')

  --[[{ -- Syntax highlighting
    "f-person/auto-dark-mode.nvim",
    opts = {
      set_dark_mode = function()
        vim.opt.background = "dark"
        vim.cmd("colorscheme adwaita")
      end,
      set_light_mode = function()
        vim.opt.background = "light"
        vim.cmd("colorscheme adwaita")
      end,
    }
  },
  ]]--
 
require('lazy').setup({
  { -- Indentation
    'tpope/vim-sleuth',
    config = function()
      vim.opt.expandtab = true
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.smarttab = true
      vim.opt.softtabstop = -1
    end
  },
  { -- Searching
    'nvim-telescope/telescope.nvim',
    config = function()
      require('telescope').setup({})
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<Space>ff', builtin.find_files)
      vim.keymap.set('n', '<Space>fg', builtin.live_grep)
      vim.keymap.set('n', '<Space>fb', builtin.buffers)
    end
  },
  { -- Theme
    'nvim-treesitter/nvim-treesitter',
    dependencies = { "ellisonleao/gruvbox.nvim" },
    config = function()
      vim.cmd.colorscheme("gruvbox")
      require'nvim-treesitter.configs'.setup({
        auto_install = true,
        highlight = { enable = true }
      })
    end
  },
  { -- LSP
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      -- Lsp servers
      require('mason').setup({})
      local lspconfig = require('lspconfig')
      lspconfig.clangd.setup({})

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          -- Disable semantic highlighting
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          client.server_capabilities.semanticTokensProvider = nil

          -- Goto definition and friends
          vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions)
          vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references)
          vim.keymap.set('n', 'gI', require('telescope.builtin').lsp_implementations)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
        end
      })
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      -- Remove colors from the statusline
      local auto = require("lualine.themes.auto")
      local modes = {"insert", "normal", "visual", "command", "replace", "inactive", "terminal"}
      for _, mode in ipairs(modes) do
        if auto[mode] then
            auto[mode].a.bg = "NONE"
	    auto[mode].a.fg = "gray"
            auto[mode].c.bg = "NONE"
	    auto[mode].c.fg = "gray"
	    auto[mode].b.bg = "NONE"
	    auto[mode].b.fg = "gray"
        end
      end
      require('lualine').setup {
        options = {
          theme = auto,
          icons_enabled = true,
          component_separators = { left = ' ', right = ' '},
          section_separators = { left = ' ', right = ' '},
          globalstatus = true,
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {''}, lualine_y = {''},
          lualine_z = {'location'}
        },
      }
    end
  }
})
