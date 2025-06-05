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

  -- Colorscheme (gruvbox-material)
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
    config = function()
      -- Configure gruvbox-material
      vim.g.gruvbox_material_background = 'medium'
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_disable_italic_comment = 0
      vim.g.gruvbox_material_transparent_background = 0
      vim.g.gruvbox_material_foreground = 'material'
      vim.g.gruvbox_material_statusline_style = 'material'
      vim.g.gruvbox_material_lightline_disable_bold = 0

      vim.cmd.colorscheme('gruvbox-material')

      -- Custom highlight groups for better differentiation
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "gruvbox-material",
        callback = function()
          local colors = {
            -- Gruvbox-material color palette
            bg0 = '#282828',
            bg1 = '#32302f',
            bg2 = '#3c3836',
            fg0 = '#fbf1c7',
            fg1 = '#ebdbb2',
            red = '#fb4934',
            green = '#b8bb26',
            yellow = '#fabd2f',
            blue = '#83a598',
            purple = '#d3869b',
            aqua = '#8ec07c',
            orange = '#fe8019',
            gray = '#928374',
          }

          -- Define custom highlight groups
          local highlights = {
            -- Import-related highlights (more subdued)
            ['@module'] = { fg = colors.aqua, italic = true },
            ['@variable.builtin'] = { fg = colors.purple, italic = true },
            ['@constant.builtin'] = { fg = colors.purple, italic = true },

            -- Class and type highlights (distinct from imports)
            ['@type'] = { fg = colors.yellow, bold = true },
            ['@type.builtin'] = { fg = colors.yellow },
            ['@constructor'] = { fg = colors.yellow, bold = true },

            -- Function highlights
            ['@function'] = { fg = colors.green, bold = true },
            ['@function.builtin'] = { fg = colors.green },
            ['@method'] = { fg = colors.green, bold = true },

            -- Variable highlights
            ['@variable'] = { fg = colors.fg1 },
            ['@parameter'] = { fg = colors.blue, italic = true },

            -- String and comment highlights
            ['@string'] = { fg = colors.green, italic = true },
            ['@comment'] = { fg = colors.gray, italic = true },

            -- Enhanced diagnostic virtual text colors
            DiagnosticVirtualTextError = { fg = colors.red, bg = colors.bg1, italic = true },
            DiagnosticVirtualTextWarn = { fg = colors.orange, bg = colors.bg1, italic = true },
            DiagnosticVirtualTextInfo = { fg = colors.blue, bg = colors.bg1, italic = true },
            DiagnosticVirtualTextHint = { fg = colors.aqua, bg = colors.bg1, italic = true },
          }

          -- Apply highlights
          for group, opts in pairs(highlights) do
            vim.api.nvim_set_hl(0, group, opts)
          end
        end,
      })

      -- Trigger the autocmd
      vim.cmd('doautocmd ColorScheme gruvbox-material')
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

  -- Dashboard (replaced alpha-nvim)
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('dashboard').setup({
        theme = 'hyper',
        config = {
          header = {
            "██████╗ ███████╗███╗   ██╗     ██╗██╗███╗   ██╗    ███████╗██╗  ██╗██╗   ██╗",
            "██╔══██╗██╔════╝████╗  ██║     ██║██║████╗  ██║    ╚══███╔╝██║  ██║██║   ██║",
            "██████╔╝█████╗  ██╔██╗ ██║     ██║██║██╔██╗ ██║      ███╔╝ ███████║██║   ██║",
            "██╔══██╗██╔══╝  ██║╚██╗██║██   ██║██║██║╚██╗██║     ███╔╝  ██╔══██║██║   ██║",
            "██████╔╝███████╗██║ ╚████║╚█████╔╝██║██║ ╚████║    ███████╗██║  ██║╚██████╔╝",
            "╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚════╝ ╚═╝╚═╝  ╚═══╝    ╚══════╝╚═╝  ╚═╝ ╚═════╝ ",
            "",
            "                         💻 Welcome to Neovim 💻                           ",
            "",
          },
          shortcut = {
            { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
            {
              icon = ' ',
              icon_hl = '@variable',
              desc = 'Files',
              group = 'Label',
              action = 'Telescope find_files',
              key = 'f',
            },
            {
              desc = ' Apps',
              group = 'DiagnosticHint',
              action = 'Telescope app',
              key = 'a',
            },
            {
              desc = ' dotfiles',
              group = 'Number',
              action = 'Telescope dotfiles',
              key = 'd',
            },
          },
          packages = { enable = true }, -- show how many plugins neovim loaded
          project = { enable = true, limit = 8, icon = '󰏓', label = '', action = 'Telescope find_files cwd=' },
          mru = { limit = 19, icon = '󰋚', label = '', cwd_only = false },
        },
      })
    end,
  },

  -- LSP Configuration (exclude Python LSPs entirely)
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

  -- Python environment detection
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

  -- Blink.cmp - Modern completion engine (CORRECTED CONFIG)
  {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = 'rafamadriz/friendly-snippets',
    version = 'v0.*',
    opts = {
      keymap = { preset = 'default' },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        }
      }
    },
    opts_extend = { "sources.default" }
  },

  -- Enhanced linting for Python import detection
  {
    'mfussenegger/nvim-lint',
    event = { "BufReadPre", "BufNewFile" },

    config = function()
      local lint = require('lint')

      -- Configure linters with line length settings (120 chars) - check if they exist first
      if lint.linters.pyflakes then
        lint.linters.pyflakes.args = {}
      end

      if lint.linters.pycodestyle then
        lint.linters.pycodestyle.args = { '--max-line-length=120' }
      end

      -- Or create custom linter configs if they don't exist
      lint.linters.pyflakes = lint.linters.pyflakes or {
        cmd = 'pyflakes',
        stdin = true,
        args = {},
        ignore_exitcode = true,
        parser = require('lint.parser').from_pattern(
          [[:(%d+):(%d*):? (.*)]],
          {"lnum", "col", "message"},
          nil,
          {["source"] = "pyflakes"}
        ),
      }

      lint.linters.pycodestyle = lint.linters.pycodestyle or {
        cmd = 'pycodestyle',
        stdin = true,
        args = { '--max-line-length=120', '-' },
        parser = require('lint.parser').from_pattern(
          [[:(%d+):(%d+): (%w+) (.*)]],
          {"lnum", "col", "code", "message"},
          nil,
          {["source"] = "pycodestyle"}
        ),
      }

      -- Debounced linting function
      local lint_debounce_table = {}
      local function debounced_lint()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Clear existing timer
        if lint_debounce_table[bufnr] then
          vim.loop.timer_stop(lint_debounce_table[bufnr])
        end

        -- Set new timer
        lint_debounce_table[bufnr] = vim.loop.new_timer()
        lint_debounce_table[bufnr]:start(500, 0, vim.schedule_wrap(function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            lint.try_lint()
          end
        end))
      end

      -- Create autocommand for linting
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = debounced_lint,
      })
    end,
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
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      background_colour = "#000000",
      fps = 30,
      icons = {
        DEBUG = "",
        ERROR = "",
        INFO = "",
        TRACE = "✎",
        WARN = ""
      },
      level = 2,
      minimum_width = 50,
      render = "default",
      stages = "fade_in_slide_out",
      timeout = 5000,
      top_down = true
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)

      -- Set nvim-notify as the default notify function
      vim.notify = notify

      -- Custom notification for lazy.nvim updates
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazySync",
        callback = function()
          notify("Plugins synced!", "info", { title = "Lazy.nvim" })
        end,
      })
    end,
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
  },

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

  -- Auto-trim trailing spaces
  {
    'mcauley-penney/tidy.nvim',
    event = { "BufWritePre" },
    opts = {
      filetype_exclude = { "markdown", "diff" }
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
-- LSP SETUP (NO PYTHON LSPs)
-- ===========================

-- Setup neodev first
require('neodev').setup()

-- Setup Mason
require('mason').setup()

-- Setup lspconfig
local lspconfig = require('lspconfig')

-- Function to get capabilities for blink.cmp
local function get_capabilities()
  return require('blink.cmp').get_lsp_capabilities()
end

-- Enhanced on_attach function
local on_attach = function(client, bufnr)
  -- Explicitly disable any Python LSPs that might attach
  if client.name == "pyright" or client.name == "pylsp" or client.name == "python-lsp-server" or client.name == "jedi_language_server" then
    vim.notify("Stopping Python LSP: " .. client.name, vim.log.levels.WARN)
    client.stop()
    return
  end

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

-- Setup mason-lspconfig (no Python LSP servers)
require('mason-lspconfig').setup({
  ensure_installed = {
    'clangd', 'lua_ls', 'rust_analyzer', 'ts_ls'
  },
  handlers = {
    function(server_name)
      -- Explicitly skip all Python LSP servers
      if server_name == "pyright" or server_name == "pylsp" or server_name == "python-lsp-server" or server_name == "jedi_language_server" then
        vim.notify("Skipping Python LSP: " .. server_name, vim.log.levels.INFO)
        return
      end

      lspconfig[server_name].setup({
        capabilities = get_capabilities(),
        on_attach = on_attach,
      })
    end,

    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        capabilities = get_capabilities(),
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
  },
})

-- ===========================
-- DIAGNOSTICS (SHOW BOTH VIRTUAL TEXT AND LOCLIST)
-- ===========================

-- Map client names to readable sources
local source_mapping = {
  ["null-ls"] = "null-ls",
  pycodestyle = "pycodestyle",
  pyflakes = "pyflakes",
  clangd = "clangd",
  lua_ls = "Lua LSP",
  rust_analyzer = "Rust Analyzer",
  ts_ls = "TypeScript LSP",
}

-- Enhanced diagnostic configuration (show both virtual text and loclist)
vim.diagnostic.config({
  virtual_text = {
    source = false, -- We'll handle source display manually
    prefix = "●",
    severity = { min = vim.diagnostic.severity.INFO }, -- Show info, warn, error
    format = function(diagnostic)
      -- Get the source name
      local source = diagnostic.source or ""
      -- Map internal names to readable names
      source = source_mapping[source] or source

      -- Limit message length
      local message = diagnostic.message
      if #message > 50 then
        message = message:sub(1, 47) .. "..."
      end

      -- Format: [source]: message
      if source ~= "" then
        return string.format("  [%s]: %s", source, message)
      else
        return "  " .. message
      end
    end,
    spacing = 2,
  },
  signs = {
    severity = { min = vim.diagnostic.severity.INFO },
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
    prefix = function(diagnostic, i, total)
      local source = diagnostic.source or ""
      source = source_mapping[source] or source
      if source ~= "" then
        return string.format("[%s]: ", source), "DiagnosticFloatingPrefix"
      else
        return "", ""
      end
    end,
    focusable = false,
    style = "minimal",
    max_width = 100,
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

-- Filter out unwanted diagnostics and avoid duplicates
local function filter_diagnostics_enhanced(diagnostics)
  local filtered = {}
  local seen = {}

  for _, diagnostic in ipairs(diagnostics) do
    -- Skip any Python LSP diagnostics that might slip through
    if diagnostic.source == "Pyright" or diagnostic.source == "pyright" then
      goto continue
    end

    local key = string.format("%d:%d:%s", diagnostic.lnum, diagnostic.col, diagnostic.message)
    if not seen[key] then
      seen[key] = true
      table.insert(filtered, diagnostic)
    end

    ::continue::
  end

  return filtered
end

-- Override diagnostic set function
local original_set = vim.diagnostic.set
vim.diagnostic.set = function(namespace, bufnr, diagnostics, opts)
  diagnostics = filter_diagnostics_enhanced(diagnostics)

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

-- Diagnostic navigation and display
keymap("n", "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", { desc = "Show diagnostics in location list" })
keymap("n", "<leader>do", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Show diagnostic float" })

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

-- Commands to manage Python LSPs manually
vim.api.nvim_create_user_command("RemovePyrightFromMason", function()
  vim.notify("Please open Mason (:Mason) and manually uninstall pyright, pylsp, and python-lsp-server", vim.log.levels.INFO)
  vim.cmd("Mason")
end, { desc = "Open Mason to remove Python LSPs" })

-- Final notification
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.notify(" Neovim configuration loaded successfully!")
  end,
})
