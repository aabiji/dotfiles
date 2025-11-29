vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.fillchars = { eob = " " }
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

-- remove trailing space on exit
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("RemoveTrailingWhitespace", { clear = true }),
  callback = function()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
  end,
})

-- markdown wrapping
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')
      local actions = require('telescope.actions')

      -- If we're in a split, open the selected file in the split
      -- If we're in an empty buffer, replace the buffer with the selected file
      -- Else, open the file in a new tab
      local function smart_open(prompt_bufnr)
        local entry = require('telescope.actions.state').get_selected_entry()
        actions.close(prompt_bufnr)

        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        local buf_name = vim.api.nvim_buf_get_name(buf)
        local is_empty = buf_name == "" and vim.api.nvim_buf_get_changedtick(buf) == 2
        local win_count = #vim.api.nvim_tabpage_list_wins(0)

        if is_empty then
          vim.cmd('edit ' .. entry.path)
        elseif win_count > 1 then
          vim.cmd('edit ' .. entry.path)
        else
          vim.cmd('tabedit ' .. entry.path)
        end
      end

      telescope.setup({
        defaults = {
          border = false,
          layout_strategy = 'bottom_pane',
          layout_config = { height = 25 },
        },
        pickers = {
          find_files = {
            find_command={'rg','--files','--sortr','path'},
            mappings = {
              n = { ["<CR>"] = smart_open },
              i = { ["<CR>"] = smart_open },
            },
          },
        }
      })

      vim.keymap.set('n', '<leader>ff', builtin.find_files)
      vim.keymap.set('n', '<leader>fg', builtin.live_grep)
      vim.keymap.set('n', '<leader>fb', builtin.buffers)
    end,
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({ automatic_installation = true })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local servers = { 'clangd', 'pyright', 'ts_ls', 'rust_analyzer', 'gopls', 'zls' }
      for _, lsp in ipairs(servers) do
        vim.lsp.config[lsp] = { capabilities = capabilities }
      end

      for _, lsp in ipairs(servers) do
        vim.lsp.enable(lsp)
      end

      -- Auto-format on save
      --vim.api.nvim_create_autocmd('LspAttach', {
      --  callback = function(args)
      --    vim.api.nvim_create_autocmd('BufWritePre', {
      --      buffer = args.buf,
      --      callback = function()
      --        vim.lsp.buf.format({ async = false })
      --      end,
      --    })
      --  end,
      --})

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }

          -- Smart go to definition that reuses existing tabs
          vim.keymap.set("n", "gd", function()
            -- Get the definition location
            local params = vim.lsp.util.make_position_params()
            vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, config)
              if err or not result or vim.tbl_isempty(result) then
                return
              end

              -- Handle single or multiple results
              local location = result[1] or result
              local target_uri = location.uri or location.targetUri
              local target_path = vim.uri_to_fname(target_uri)

              -- Check if file is already open in a tab
              for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
                local win = vim.api.nvim_tabpage_get_win(tabpage)
                local buf = vim.api.nvim_win_get_buf(win)
                local buf_name = vim.api.nvim_buf_get_name(buf)

                if buf_name == target_path then
                  -- Switch to the existing tab
                  vim.api.nvim_set_current_tabpage(tabpage)
                  -- Jump to the position
                  vim.lsp.util.jump_to_location(location, 'utf-8')
                  return
                end
              end

              -- File not open in any tab, open in new tab
              vim.cmd('tab split')
              vim.lsp.util.jump_to_location(location, 'utf-8')
            end)
          end, opts)

          vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'ge', vim.diagnostic.goto_next, opts)
          vim.keymap.set('n', 'ga', vim.lsp.buf.rename, opts)
        end,
      })
    end,
  },

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<PageUp>'] = cmp.mapping.scroll_docs(-4),
          ['<PageDown>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        auth_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = { "comment" },
      })
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup()
    end
  },

  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({})
    end,
  },

  {
    'nmac427/guess-indent.nvim',
    config = function()
      require('guess-indent').setup({})
    end,
  },

  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      local bufferline = require("bufferline")
      bufferline.setup({
        options = {
          style_preset = bufferline.style_preset.no_italic,
          mode = "tabs",
          show_buffer_close_icons = false,
          show_tab_indicators = false,
          show_buffer_icons = false,
        }
      })
    end,
  },

  {
    'morhetz/gruvbox',
    config = function()
      vim.cmd[[
        let g:gruvbox_contrast_dark='hard'
        let g:gruvbox_contrast_light='hard'
        colorscheme gruvbox
        ]]
      vim.opt.cursorline = true
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE" })
    end,
  }
})
