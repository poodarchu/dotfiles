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

  -- File explorer (enhanced for directory navigation)
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
      default_component_configs = {
        file_size = {
          enabled = true,
          required_width = 64,
        },
        type = {
          enabled = true,
          required_width = 122,
        },
        last_modified = {
          enabled = true,
          required_width = 88,
        },
      },
      window = { 
        position = "left", 
        width = 35,
        mappings = {
          ["<space>"] = false, -- disable space until we figure out which-key
          ["[g"] = "prev_git_modified",
          ["]g"] = "next_git_modified",
        }
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_current",
        bind_to_cwd = false,
      },
    },
  },

  -- Oil.nvim for directory navigation like file editing
  {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        view_options = {
          show_hidden = false,
          is_hidden_file = function(name, bufnr)
            return vim.startswith(name, ".")
          end,
          is_always_hidden = function(name, bufnr)
            return false
          end,
        },
        float = {
          padding = 2,
          max_width = 0,
          max_height = 0,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
        },
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-s>"] = "actions.select_vsplit",
          ["<C-h>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
        },
      })
      
      -- Auto command to replace netrw with oil
      vim.api.nvim_create_autocmd("BufWinEnter", {
        desc = "Open oil when opening a directory",
        pattern = "*",
        callback = function()
          if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
            vim.cmd("bd")
            vim.cmd("Oil " .. vim.fn.expand("%"))
          end
        end,
      })
    end,
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
        theme = 'gruvbox',
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

  -- Colorscheme (replaced with gruvbox.nvim)
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        contrast = "medium", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
      vim.cmd.colorscheme("gruvbox")
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

  -- Fuzzy finder (with find command fallback)
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
      
      -- Function to determine the best find command available
      local function get_find_command()
        if vim.fn.executable('rg') == 1 then
          return { "rg", "--files", "--hidden", "--glob", "!**/.git/*" }
        elseif vim.fn.executable('find') == 1 then
          return { "find", ".", "-type", "f" }
        else
          return nil
        end
      end
      
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
            find_command = get_find_command(),
          },
        },
      })
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
    end,
  },

  -- Session management (with auto-save disabled to prevent E37 errors)
  {
    'folke/persistence.nvim',
    event = "BufReadPre",
    opts = {
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
      pre_save = nil,
      save_empty = false,
    },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    },
  },

  -- Commenting (enhanced configuration)
  {
    'numToStr/Comment.nvim',
    keys = {
      { "<leader>c", mode = { "n", "v" }, desc = "Toggle comment" },
    },
    config = function()
      require('Comment').setup({
        toggler = {
          line = '<leader>cc',
          block = '<leader>bc',
        },
        opleader = {
          line = '<leader>c',
          block = '<leader>b',
        },
        extra = {
          above = '<leader>cO',
          below = '<leader>co',
          eol = '<leader>cA',
        },
        mappings = {
          basic = true,
          extra = true,
        },
      })
    end,
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

  -- Simple Python environment detection (without fd dependency)
  {
    'nvim-lua/plenary.nvim',
    config = function()
      -- Simple virtual environment detection function
      local function detect_python_venv()
        local venv_paths = {
          os.getenv("VIRTUAL_ENV"),
          ".venv",
          "venv",
          ".env",
          "env"
        }
        
        for _, path in ipairs(venv_paths) do
          if path and vim.fn.isdirectory(path) == 1 then
            local python_path = path .. "/bin/python"
            if vim.fn.has("win32") == 1 then
              python_path = path .. "\\Scripts\\python.exe"
            end
            
            if vim.fn.executable(python_path) == 1 then
              vim.g.python3_host_prog = python_path
              vim.notify("Python virtual environment detected: " .. path, vim.log.levels.INFO)
              return python_path
            end
          end
        end
        
        -- Fallback to system python
        local system_python = vim.fn.exepath("python3") or vim.fn.exepath("python")
        if system_python then
          vim.g.python3_host_prog = system_python
          return system_python
        end
        
        return nil
      end
      
      -- Auto-detect Python environment on startup
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          detect_python_venv()
        end,
      })
      
      -- Command to manually detect Python environment
      vim.api.nvim_create_user_command("DetectPythonVenv", function()
        local python = detect_python_venv()
        if python then
          vim.notify("Using Python: " .. python, vim.log.levels.INFO)
        else
          vim.notify("No Python interpreter found", vim.log.levels.WARN)
        end
      end, { desc = "Detect Python virtual environment" })
    end,
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
      formatters = {
        black = {
          prepend_args = { "--line-length", "120" },
        },
        isort = {
          prepend_args = { "--profile", "black", "--line-length", "120" },
        },
        stylua = {
          prepend_args = { "--column-width", "120" },
        },
        prettier = {
          prepend_args = { "--print-width", "120" },
        },
        clang_format = {
          prepend_args = { "--style={ColumnLimit: 120}" },
        },
      },
    },
  },

  -- Removed nvim-lint completely to avoid duplication with LSP

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
        { "<leader>c", group = "comment" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>q", group = "quit/session" },
        { "<leader>w", group = "windows" },
        { "<leader>b", group = "buffer/breakpoint" },
        { "<leader>t", group = "toggle/terminal" },
        { "<leader>d", group = "debug/detect" },
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
          { filetype = "neo-tree", text = "Neo-tree", highlight = "Directory" },
          { filetype = "oil", text = "Oil", highlight = "Directory" }
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
opt.confirm = true  -- Confirm to save changes before exiting modified buffer

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
opt.colorcolumn = '120'  -- Set global line width to 120
opt.termguicolors = true
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.splitbelow = true
opt.splitright = true
opt.laststatus = 3

-- Completion
opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- Line width settings
opt.textwidth = 120
opt.formatoptions:append('t')

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

-- Set textwidth for Python files to 120
autocmd("FileType", {
  group = augroup("PythonTextWidth", { clear = true }),
  pattern = "python",
  callback = function()
    vim.bo.textwidth = 120
  end,
})

-- Prevent session save on VimLeave to avoid E37 errors
autocmd("VimLeavePre", {
  group = augroup("PreventSessionSave", { clear = true }),
  callback = function()
    vim.o.sessionoptions = "blank,curdir,folds,help,tabpages,winsize,terminal"
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

  -- Enhanced hover with custom styling
  vim.keymap.set('n', '<leader>K', function()
    vim.lsp.buf.hover()
  end, vim.tbl_extend('force', bufopts, { desc = "Show documentation" }))

  -- Diagnostic mappings
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
end

-- Setup mason-lspconfig with only one primary Python LSP
require('mason-lspconfig').setup({
  ensure_installed = { 
    'pyright', 'clangd', 'lua_ls', 'rust_analyzer', 'ts_ls'
    -- Removed pylsp to avoid conflicts - using only pyright for Python
  },
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
            format = {
              enable = true,
              defaultConfig = {
                column_width = "120",
                line_separator = "unix",
                quote_style = "double",
              }
            },
          },
        },
      })
    end,

    -- Use only Pyright for Python to avoid duplications
    ["pyright"] = function()
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              stubPath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs",
            },
          },
          pyright = {
            -- Disable organize imports since we have separate formatters
            disableOrganizeImports = true,
          },
        },
        -- Don't attach to files that are too large
        root_dir = function(fname)
          local util = require('lspconfig.util')
          return util.root_pattern(
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            'Pipfile',
            'pyrightconfig.json',
            '.git'
          )(fname) or util.path.dirname(fname)
        end,
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
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'luasnip', priority = 750 },
  }, {
    { name = 'buffer', priority = 500 },
    { name = 'path', priority = 250 },
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

-- Enhanced diagnostic configuration to reduce duplicates
vim.diagnostic.config({
  virtual_text = {
    source = false, -- Don't show source in virtual text to reduce clutter
    prefix = "●",
    severity = { min = vim.diagnostic.severity.WARN }, -- Only show warnings and errors
    format = function(diagnostic)
      -- Limit message length
      local message = diagnostic.message
      if #message > 80 then
        message = message:sub(1, 77) .. "..."
      end
      return message
    end,
  },
  signs = {
    severity = { min = vim.diagnostic.severity.WARN }, -- Only show signs for warnings and errors
  },
  underline = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  update_in_insert = false,
  severity_sort = true,
  float = { 
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    focusable = false,
    style = "minimal",
    max_width = 80,
    max_height = 20,
  },
})

-- Custom hover window configuration
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  max_width = 80,
  max_height = 20,
  focusable = false,
  style = "minimal",
  title = "Documentation",
})

-- Advanced duplicate filtering based on message content similarity
local function filter_diagnostics_advanced(diagnostics)
  local filtered = {}
  local seen = {}
  
  for _, diagnostic in ipairs(diagnostics) do
    -- Create a normalized key for deduplication
    local line = diagnostic.lnum
    local col = diagnostic.col
    local message = diagnostic.message:lower()
    
    -- Normalize common variations
    message = message:gsub("'[^']*'", "'*'") -- Replace quoted strings with placeholder
    message = message:gsub('"[^"]*"', '"*"') -- Replace quoted strings with placeholder
    message = message:gsub("%s+", " ") -- Normalize whitespace
    message = message:gsub("^%s*", ""):gsub("%s*$", "") -- Trim
    
    local key = string.format("%d:%d:%s", line, col, message)
    
    if not seen[key] then
      seen[key] = true
      table.insert(filtered, diagnostic)
    end
  end
  
  return filtered
end

-- Override diagnostic set function with advanced filtering
local original_set = vim.diagnostic.set
vim.diagnostic.set = function(namespace, bufnr, diagnostics, opts)
  -- Apply advanced filtering
  diagnostics = filter_diagnostics_advanced(diagnostics)
  
  -- Sort by severity and line number
  table.sort(diagnostics, function(a, b)
    if a.severity ~= b.severity then
      return a.severity < b.severity
    end
    return a.lnum < b.lnum
  end)
  
  original_set(namespace, bufnr, diagnostics, opts)
end

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

-- Save file with confirmation
keymap({ "i", "x", "n", "s" }, "<C-s>", function()
  if vim.bo.modified then
    vim.cmd("write")
  end
end, { desc = "Save file" })

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
keymap("n", "<leader>bd", function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified then
    local choice = vim.fn.confirm("Buffer has unsaved changes. Save before closing?", "&Yes\n&No\n&Cancel", 3)
    if choice == 1 then
      vim.cmd("write")
      vim.cmd("bdelete")
    elseif choice == 2 then
      vim.cmd("bdelete!")
    end
  else
    vim.cmd("bdelete")
  end
end, { desc = "Delete buffer" })

keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Oil navigation
keymap("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

-- Enhanced commenting with <leader>c
keymap("n", "<leader>c", function()
  require('Comment.api').toggle.linewise.current()
end, { desc = "Toggle comment line" })

keymap("x", "<leader>c", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'nx', false)
  require('Comment.api').toggle.linewise(vim.fn.visualmode())
end, { desc = "Toggle comment selection" })

-- Enhanced breakpoint function for <leader>b
local function toggle_breakpoint_above()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_indent = vim.api.nvim_get_current_line():match('^%s*')
  local breakpoint_line = current_indent .. "breakpoint()  # Debug breakpoint"

  if current_line == 1 then
    local line_content = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if vim.trim(line_content) == vim.trim(breakpoint_line) then
      vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
    else
      vim.api.nvim_buf_set_lines(0, 0, 0, false, {breakpoint_line})
    end
  else
    local line_above = vim.api.nvim_buf_get_lines(0, current_line - 2, current_line - 1, false)[1] or ""
    if vim.trim(line_above) == vim.trim(breakpoint_line) then
      vim.api.nvim_buf_set_lines(0, current_line - 2, current_line - 1, false, {})
    else
      vim.api.nvim_buf_set_lines(0, current_line - 1, current_line - 1, false, {breakpoint_line})
    end
  end
end

keymap('n', '<leader>b', toggle_breakpoint_above, { desc = "Toggle breakpoint" })
keymap('n', '<F9>', toggle_breakpoint_above, { desc = "Toggle breakpoint" })

-- Python environment detection shortcut
keymap("n", "<leader>dp", "<cmd>DetectPythonVenv<cr>", { desc = "Detect Python Environment" })

-- Terminal mappings
keymap("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })

-- Quick quit with save prompt
keymap("n", "<leader>qq", function()
  local buffers = vim.api.nvim_list_bufs()
  local modified = false
  
  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
      modified = true
      break
    end
  end
  
  if modified then
    local choice = vim.fn.confirm("Some buffers have unsaved changes. Save all and quit?", "&Yes\n&No\n&Cancel", 3)
    if choice == 1 then
      vim.cmd("wall")
      vim.cmd("qa")
    elseif choice == 2 then
      vim.cmd("qa!")
    end
  else
    vim.cmd("qa")
  end
end, { desc = "Quit all" })

-- Final notification
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.notify(" Neovim configuration loaded successfully!")
  end,
})
