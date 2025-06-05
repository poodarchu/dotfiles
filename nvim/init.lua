-- init.lua - Modern Neovim Configuration for Warp Terminal
-- ========================================================

-- Performance optimizations - disable unused built-in plugins
local disabled_built_ins = {
  "gzip", "tar", "tarPlugin", "zip", "zipPlugin", "getscript", "getscriptPlugin",
  "vimball", "vimballPlugin", "2html_plugin", "logiPat", "rrhelper",
  "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
  "matchit", "matchparen", "spec"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Leader keys (set early)
vim.g.mapleader = '\\'
vim.g.maplocalleader = ','
vim.g.have_nerd_font = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
local plugins = {
  -- Core functionality
  'tpope/vim-sensible',

  -- File explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<F3>", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,
      window = { position = "left", width = 35 },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
    },
  },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = '│' },
        change = { text = '│' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
    },
  },

  'tpope/vim-fugitive',

  -- Enhanced statusline
  {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'gruvbox-material',
        globalstatus = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
    },
  },

  -- Colorscheme
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = 'medium'
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.cmd.colorscheme('gruvbox-material')
    end,
  },

  -- Indentation guides
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
      exclude = {
        filetypes = {
          "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason",
        },
      },
    },
  },

  -- Auto pairs
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {
      check_ts = true,
      disable_filetype = { "TelescopePrompt" },
    },
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-ui-select.nvim',
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top" },
          },
          file_ignore_patterns = {
            "node_modules", "__pycache__", ".git/", "*.pyc",
            "target/", "dist/", "build/", ".DS_Store",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
          },
        },
      })
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
    end,
  },

  -- Session management
  {
    'folke/persistence.nvim',
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    },
  },

  -- Commenting
  {
    'numToStr/Comment.nvim',
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gb", mode = { "n", "v" } },
      { "<leader>/", mode = { "n", "v" } },
    },
    opts = {},
  },

  -- Dashboard
  {
    'goolord/alpha-nvim',
    event = "VimEnter",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require('alpha')
      local startify = require('alpha.themes.startify')
      
      startify.section.header.val = {
        "██████╗ ███████╗███╗   ██╗     ██╗██╗███╗   ██╗    ███████╗██╗  ██╗██╗   ██╗",
        "██╔══██╗██╔════╝████╗  ██║     ██║██║████╗  ██║    ╚══███╔╝██║  ██║██║   ██║",
        "██████╔╝█████╗  ██╔██╗ ██║     ██║██║██╔██╗ ██║      ███╔╝ ███████║██║   ██║",
        "██╔══██╗██╔══╝  ██║╚██╗██║██   ██║██║██║╚██╗██║     ███╔╝  ██╔══██║██║   ██║",
        "██████╔╝███████╗██║ ╚████║╚█████╔╝██║██║ ╚████║    ███████╗██║  ██║╚██████╔╝",
        "╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚════╝ ╚═╝╚═╝  ╚═══╝    ╚══════╝╚═╝  ╚═╝ ╚═════╝ ",
        "",
        "                         💻 Welcome to Neovim 💻                           ",
      }
      
      alpha.setup(startify.config)
    end,
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'folke/neodev.nvim',
      'j-hui/fidget.nvim',
    },
  },

  -- LSP installer
  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    opts = {},
  },

  -- LSP progress notifications
  {
    'j-hui/fidget.nvim',
    opts = {},
  },

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim',
    },
  },

  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = { "BufWritePre" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },
    },
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          "bash", "c", "html", "javascript", "json", "lua", "markdown",
          "python", "query", "regex", "tsx", "typescript", "vim", "yaml", 
          "cpp", "rust", "go", "dockerfile",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      })
    end,
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>c", group = "code" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>q", group = "quit/session" },
        { "<leader>w", group = "windows" },
        { "<leader>b", group = "buffer" },
        { "<leader>t", group = "toggle/terminal" },
      },
    },
  },

  -- Better diagnostics
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
    },
    opts = {},
  },

  -- Terminal
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    },
    opts = {
      direction = 'float',
      float_opts = { border = 'curved' },
    },
  },

  -- Better UI
  { 'stevearc/dressing.nvim', lazy = true },

  -- Enhanced notifications
  { "rcarriga/nvim-notify", opts = {} },

  -- Buffer management
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "neo-tree", text = "Neo-tree", highlight = "Directory" }
        },
      },
    },
  },
}

-- Load plugins with lazy.nvim
require("lazy").setup(plugins, {
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
  checker = { enabled = true, notify = false },
})

-- ===========================
-- BASIC SETTINGS
-- ===========================

local opt = vim.opt

-- Basic options
opt.encoding = 'utf-8'
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- UI
opt.number = true
opt.cursorline = true
opt.signcolumn = 'yes'
opt.wrap = false
opt.scrolloff = 8
opt.colorcolumn = '120'
opt.termguicolors = true
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.splitbelow = true
opt.splitright = true
opt.laststatus = 3

-- Completion
opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- ===========================
-- AUTOCOMMANDS
-- ===========================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Go to last loc when opening a buffer
autocmd("BufReadPost", {
  group = augroup("LastLoc", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto create dir when saving a file
autocmd("BufWritePre", {
  group = augroup("AutoCreateDir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("Checktime", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = { "help", "lspinfo", "man", "notify", "qf", "query" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- ===========================
-- LSP SETUP
-- ===========================

-- Setup neodev first
require('neodev').setup()

-- Setup Mason
require('mason').setup()

-- Setup lspconfig
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Enhanced on_attach function
local on_attach = function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  -- LSP mappings
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, bufopts)
  vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

  -- Diagnostic mappings
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
end

-- Setup mason-lspconfig
require('mason-lspconfig').setup({
  ensure_installed = { 'pylsp', 'clangd', 'lua_ls', 'rust_analyzer', 'ts_ls' },
  handlers = {
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end,

    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = {'vim'} },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })
    end,

    ["pylsp"] = function()
      lspconfig.pylsp.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = { maxLineLength = 120 },
              black = { enabled = false },
            },
          },
        },
      })
    end,
  },
})

-- ===========================
-- COMPLETION SETUP
-- ===========================

local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
    }),
  },
})

-- Integration with autopairs
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- ===========================
-- DIAGNOSTICS
-- ===========================

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded" },
})

-- ===========================
-- KEY MAPPINGS
-- ===========================

local keymap = vim.keymap.set

-- Better up/down
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Clear search with <esc>
keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Save file
keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Better indenting
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Lazy
keymap("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Splits
keymap("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
keymap("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Git mappings
keymap("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
keymap("n", "<leader>gc", "<cmd>Git commit --verbose<CR>", { desc = "Git commit" })

-- Buffer management
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Python debugging
local function toggle_pdb_above()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_indent = vim.api.nvim_get_current_line():match('^%s*')
  local pdb_line = current_indent .. "import pdb; pdb.set_trace()  # Breakpoint"

  if current_line == 1 then
    local line_content = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if vim.trim(line_content) == vim.trim(pdb_line) then
      vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
    else
      vim.api.nvim_buf_set_lines(0, 0, 0, false, {pdb_line})
    end
  else
    local line_above = vim.api.nvim_buf_get_lines(0, current_line - 2, current_line - 1, false)[1] or ""
    if vim.trim(line_above) == vim.trim(pdb_line) then
      vim.api.nvim_buf_set_lines(0, current_line - 2, current_line - 1, false, {})
    else
      vim.api.nvim_buf_set_lines(0, current_line - 1, current_line - 1, false, {pdb_line})
    end
  end
end

keymap('n', '<leader>db', toggle_pdb_above, { desc = "Toggle PDB breakpoint" })
keymap('n', '<F9>', toggle_pdb_above, { desc = "Toggle breakpoint" })

-- Terminal mappings
keymap("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })

-- Quick quit
keymap("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Final notification
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.notify(" Neovim configuration loaded successfully!")
  end,
})
