-- ~/.config/nvim/init.lua
-- A revised config focused on Python, with fixes & cleaner lazy-loading.
-- Leader keys
vim.g.mapleader = "\\"
vim.g.maplocalleader = ","
vim.g.have_nerd_font = true

-- Disable some built-in plugins (keep matchparen enabled for better editing)
local disabled_plugins = {
  "gzip",
  "tar",
  "tarPlugin",
  "zip",
  "zipPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logiPat",
  "rrhelper",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "spec",
}

for _, plugin in pairs(disabled_plugins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Plugins
-- ============================================================================
local plugins = {
  -- Colorscheme (UNCHANGED)
  {
    "morhetz/gruvbox",
    priority = 1000,
    lazy = false,
    init = function()
      vim.g.gruvbox_contrast_dark = "medium"
      vim.g.gruvbox_improved_strings = 1
      vim.g.gruvbox_improved_warnings = 1
    end,
    config = function()
      vim.cmd.colorscheme("gruvbox")

      -- Small treesitter tweaks to match gruvbox, and BlinkCmp highlight groups
      local colors = {
        fg1 = "#ebdbb2",
        green = "#b8bb26",
      }

      vim.api.nvim_set_hl(0, "@variable", { fg = colors.fg1 })
      vim.api.nvim_set_hl(0, "@variable.member", { fg = colors.fg1 })
      vim.api.nvim_set_hl(0, "@property", { fg = colors.fg1 })

      for _, group in ipairs({
        "@string",
        "@string.documentation",
        "@string.escape",
        "@string.special",
        "@string.special.symbol",
        "@string.special.url",
        "@string.special.path",
        "@string.regexp",
      }) do
        vim.api.nvim_set_hl(0, group, { fg = colors.green })
      end

      vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "#282828", fg = "#ebdbb2" })
      vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = "#282828", fg = "#504945" })
      vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#3c3836", fg = "#fbf1c7" })
      vim.api.nvim_set_hl(0, "BlinkCmpLabel", { fg = "#ebdbb2" })
      vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = "#fe8019", bold = true })
      vim.api.nvim_set_hl(0, "BlinkCmpKind", { fg = "#83a598" })
      vim.api.nvim_set_hl(0, "BlinkCmpKindText", { fg = "#b8bb26" })
      vim.api.nvim_set_hl(0, "BlinkCmpKindMethod", { fg = "#fabd2f" })
      vim.api.nvim_set_hl(0, "BlinkCmpKindFunction", { fg = "#fabd2f" })
      vim.api.nvim_set_hl(0, "BlinkCmpKindVariable", { fg = "#8ec07c" })
      vim.api.nvim_set_hl(0, "BlinkCmpKindKeyword", { fg = "#fb4934" })
      vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = "#665c54", italic = true })
    end,
  },

  -- Icons (used by multiple plugins)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- File explorer (UNCHANGED)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    cmd = "Neotree",
    keys = {
      { "<F3>", "<cmd>Neotree toggle<cr>", desc = "Toggle NeoTree" },
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle NeoTree" },
      { "-", "<cmd>Neotree reveal<cr>", desc = "Reveal current file in NeoTree" },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      window = { position = "left", width = 35 },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        bind_to_cwd = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { "node_modules", "__pycache__", ".git", ".DS_Store", "thumbs.db", "venv", ".venv" },
        },
      },
      buffers = { follow_current_file = { enabled = true } },
    },
  },

  -- Git signs (UNCHANGED)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts_param)
          local opts = opts_param or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "]h", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Next Hunk" })

        map("n", "[h", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Previous Hunk" })

        map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { desc = "Blame line" })

        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage selected lines" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset selected lines" })
      end,
    },
  },

  -- Statusline (UNCHANGED)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", "morhetz/gruvbox" },
    opts = {
      options = { theme = "gruvbox", globalstatus = true },
      extensions = { "neo-tree", "mason" },
    },
  },

  -- Indent guides (UNCHANGED)
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
      exclude = { filetypes = { "help", "alpha", "dashboard", "neo-tree", "lazy", "mason" } },
    },
  },

  -- Autopairs (UNCHANGED)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = { lua = { "string" }, javascript = { "template_string" }, java = false },
    },
  },

  -- Telescope (UNCHANGED)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find Files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live Grep" },
      { "<leader>fw", function() require("telescope.builtin").grep_string() end, desc = "Grep Word" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help Tags" },
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Recent Files" },

      { "<leader>\\f", function() require("telescope.builtin").git_files() end, desc = "Git Files" },
      { "<leader>\\b", function() require("telescope.builtin").git_branches() end, desc = "Git Branches" },
      { "<leader>\\c", function() require("telescope.builtin").git_commits() end, desc = "Git Commits" },
      { "<leader>\\s", function() require("telescope.builtin").git_status() end, desc = "Git Status" },

      { "<leader>ls", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Document Symbols" },
      { "<leader>lS", function() require("telescope.builtin").lsp_workspace_symbols() end, desc = "Workspace Symbols" },
      { "<leader>ld", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics (List)" },
      { "<leader>f/", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Buffer Fuzzy Find" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "  ",
          selection_caret = " ",
          sorting_strategy = "ascending",
          layout_config = { horizontal = { prompt_position = "top" }, preview_width = 0.55 },
          file_ignore_patterns = { "node_modules", "__pycache__", ".git/", "*.pyc", "*.pyo", "venv", ".venv" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = vim.fn.executable("rg") == 1 and {
              "rg",
              "--files",
              "--hidden",
              "--glob",
              "!**/.git/*",
              "--glob",
              "!**/venv/*",
              "--glob",
              "!**/.venv/*",
            } or nil,
          },
          live_grep = {
            additional_args = function()
              return {
                "--hidden",
                "--glob",
                "!**/.git/*",
                "--glob",
                "!**/venv/*",
                "--glob",
                "!**/.venv/*",
              }
            end,
          },
        },
        extensions = {
          fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
          ["ui-select"] = { theme = "ivy" },
        },
      })

      for _, ext in ipairs({ "fzf", "ui-select" }) do
        pcall(telescope.load_extension, ext)
      end
    end,
  },

  -- Comment toggling (UNCHANGED)
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>cc", function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle comment", mode = "n" },
      { "<leader>cc", function() require("Comment.api").toggle.linewise(vim.fn.visualmode()) end, desc = "Toggle comment", mode = "v" },
      { "<leader>c<space>", function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle comment", mode = "n" },
      { "<leader>c<space>", function() require("Comment.api").toggle.linewise(vim.fn.visualmode()) end, desc = "Toggle comment", mode = "v" },
    },
    config = function()
      require("Comment").setup()
    end,
  },

  -- Dashboard (UNCHANGED - YOUR CUSTOM HEADER)
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("dashboard").setup({
        theme = "hyper",
        config = {
          header = {
            "██████╗ ███████╗███╗   ██╗     ██╗██╗███╗   ██╗   ███████╗██╗  ██╗██╗   ██╗",
            "██╔══██╗██╔════╝████╗  ██║     ██║██║████╗  ██║   ╚══███╔╝██║  ██║██║   ██║",
            "██████╔╝█████╗  ██╔██╗ ██║     ██║██║██╔██╗ ██║     ███╔╝ ███████║██║   ██║",
            "██╔══██╗██╔══╝  ██║╚██╗██║██   ██║██║██║╚██╗██║    ███╔╝  ██╔══██║██║   ██║",
            "██████╔╝███████╗██║ ╚████║╚█████╔╝██║██║ ╚████║   ███████╗██║  ██║╚██████╔╝",
            "╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚════╝ ╚═╝╚═╝  ╚═══╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝ ",
            "",
            "               Welcome to Neovim               ",
            "",
          },
          shortcut = {
            { desc = "󰊳 Update Plugins", group = "Function", action = "Lazy update", key = "u" },
            { desc = " Find Files", group = "Identifier", action = "Telescope find_files", key = "f" },
            { desc = " Live Grep", group = "String", action = "Telescope live_grep", key = "g" },
            { desc = " Recent Files", group = "Constant", action = "Telescope oldfiles", key = "r" },
            { desc = " Config", group = "Keyword", action = "edit $MYVIMRC", key = "c" },
          },
          packages = { enable = true },
          mru = { limit = 10, icon = "󰋚", label = " Recent Files", cwd_only = false },
        },
      })
    end,
  },

  -- LSP
  { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },

  -- Mason (UNCHANGED)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = { ensure_installed = { "clangd", "pyright", "ruff" } },
  },

  -- Completion (MODIFIED: disable ghost_text and signature to avoid conflicts)
  {
    "saghen/blink.cmp",
    lazy = false,
    version = "v0.*",
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Right>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono" },
      sources = { default = { "lsp", "path", "buffer" } },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = false },  -- DISABLED: Copilot handles ghost text
        menu = { border = "rounded", scrolloff = 2, scrollbar = true },
      },
      signature = { enabled = false },  -- DISABLED: lsp_signature.nvim handles this
    },
  },

  -- ===========================================================================
  -- NEW: Function Signature Help (replaces blink.cmp signature)
  -- ===========================================================================
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = true,
      handler_opts = { border = "rounded" },
      floating_window = true,
      floating_window_above_cur_line = true,
      hint_enable = false,  -- Disable inline hints to avoid clutter
      hi_parameter = "LspSignatureActiveParameter",
      max_height = 12,
      max_width = 80,
      wrap = true,
      doc_lines = 10,
      padding = " ",
      toggle_key = "<M-k>",  -- Alt+k to toggle signature manually
      select_signature_key = "<M-n>",  -- Alt+n to cycle through overloaded signatures
    },
  },

  -- ===========================================================================
  -- NEW: Docstring Generation
  -- ===========================================================================
  {
    "danymat/neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<leader>ng", function() require("neogen").generate() end, desc = "Generate docstring" },
      { "<leader>nf", function() require("neogen").generate({ type = "func" }) end, desc = "Docstring: function" },
      { "<leader>nc", function() require("neogen").generate({ type = "class" }) end, desc = "Docstring: class" },
      { "<leader>nt", function() require("neogen").generate({ type = "type" }) end, desc = "Docstring: type" },
    },
    opts = {
      snippet_engine = "nvim",
      enabled = true,
      languages = {
        python = {
          template = { annotation_convention = "google_docstrings" },
        },
        c = {
          template = { annotation_convention = "doxygen" },
        },
        cpp = {
          template = { annotation_convention = "doxygen" },
        },
        lua = {
          template = { annotation_convention = "emmylua" },
        },
      },
    },
  },

  -- ===========================================================================
  -- NEW: GitHub Copilot (ghost text only, no cmp integration)
  -- ===========================================================================
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    keys = {
      { "<leader>cp", "<cmd>Copilot panel<cr>", desc = "Copilot panel" },
      { "<leader>ct", "<cmd>Copilot toggle<cr>", desc = "Copilot toggle" },
    },
    opts = {
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          refresh = "gr",
          open = "<M-CR>",
        },
        layout = {
          position = "right",
          ratio = 0.4,
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<M-l>",           -- Alt+l to accept
          accept_word = "<M-w>",      -- Alt+w to accept word
          accept_line = "<M-j>",      -- Alt+j to accept line
          next = "<M-]>",             -- Alt+] next suggestion
          prev = "<M-[>",             -- Alt+[ prev suggestion
          dismiss = "<M-e>",          -- Alt+e dismiss
        },
      },
      filetypes = {
        yaml = false,
        markdown = true,
        help = false,
        gitcommit = true,
        gitrebase = false,
        ["."] = false,
      },
    },
  },

  -- ===========================================================================
  -- NEW: Linter (feeds into vim.diagnostic, no conflict with LSP)
  -- ===========================================================================
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        python = { "ruff" },
        c = { "cppcheck" },
        cpp = { "cppcheck" },
      }

      -- Auto-lint on events
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          if vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })

      -- Manual lint command
      vim.api.nvim_create_user_command("Lint", function()
        lint.try_lint()
      end, { desc = "Trigger linting" })
    end,
  },

  -- Formatting (UNCHANGED)
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        tsx = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        bash = { "shfmt" },
        sh = { "shfmt" },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    config = function(_, opts)
      require("conform").setup(opts)
      vim.api.nvim_create_user_command("Fm", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format code (Conform)" })
    end,
  },

  -- Treesitter (UNCHANGED)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "python",
          "query",
          "regex",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        auto_install = true,
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },

  -- Which-key (MODIFIED: added new groups)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "Find/File (Telescope)" },
        { "<leader>\\", group = "Git (Telescope)" },
        { "<leader>h", group = "Git Hunks (Gitsigns)" },
        { "<leader>l", group = "LSP/Lazy" },
        { "<leader>q", group = "Quit/Session" },
        { "<leader>w", group = "Windows" },
        { "<leader>b", group = "Buffer/Breakpoint" },
        { "<leader>t", group = "Toggle/Terminal" },
        { "<leader>d", group = "Diagnostics/Definition (LSP)" },
        { "<leader>c", group = "Code/Comment/Copilot" },
        { "<leader>n", group = "Neogen (Docstring)" },
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)
    end,
  },

  -- Terminal (UNCHANGED)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal (Float)" },
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal (Float)" },
    },
    opts = {
      direction = "float",
      float_opts = { border = "curved" },
      open_mapping = nil,
    },
  },

  -- Notifications (UNCHANGED)
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = { background_colour = "#000000", timeout = 3000, render = "default", stages = "fade_in_slide_out" },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },
}

require("lazy").setup(plugins, {
  ui = { border = "rounded" },
  performance = {
    rtp = { disabled_plugins = disabled_plugins },
    cache = { enabled = true },
    reset_packpath = true,
  },
  checker = { enabled = true, notify = false, frequency = 3600 },
  change_detection = { enabled = true, notify = false },
  install = { missing = true, colorscheme = { "gruvbox" } },
})

-- ============================================================================
-- Options (UNCHANGED)
-- ============================================================================
local function setup_options()
  local opt = vim.opt

  opt.encoding = "utf-8"
  opt.fileencoding = "utf-8"

  opt.backup = false
  opt.swapfile = false
  opt.undofile = true
  local undodir_path = vim.fn.stdpath("data") .. "/undodir"
  opt.undodir = undodir_path
  if vim.fn.isdirectory(undodir_path) == 0 then
    pcall(vim.fn.mkdir, undodir_path, "p")
  end

  opt.updatetime = 250
  opt.timeoutlen = 300
  opt.confirm = true

  opt.tabstop = 4
  opt.shiftwidth = 4
  opt.softtabstop = 4
  opt.expandtab = true
  opt.autoindent = true
  opt.smartindent = true

  opt.hlsearch = true
  opt.incsearch = true
  opt.ignorecase = true
  opt.smartcase = true

  opt.number = true
  opt.relativenumber = false
  opt.cursorline = true
  opt.signcolumn = "yes"
  opt.wrap = false
  opt.scrolloff = 8
  opt.sidescrolloff = 8
  opt.colorcolumn = "120"
  opt.termguicolors = true
  opt.mouse = "a"
  opt.clipboard = "unnamedplus"
  opt.splitbelow = true
  opt.splitright = true
  opt.laststatus = 3
  opt.showmode = false

  opt.completeopt = { "menu", "menuone", "noselect" }
  opt.shortmess:append("c")

  if vim.fn.has("nvim-0.9") == 1 then
    opt.pumblend = 10
    opt.winblend = 10
  end

  vim.env.MYVIMRC = vim.fn.stdpath("config") .. "/init.lua"
end

-- ============================================================================
-- Autocmds (UNCHANGED)
-- ============================================================================
local function setup_autocmds()
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd

  autocmd("TextYankPost", {
    group = augroup("HighlightYank", { clear = true }),
    callback = function()
      vim.highlight.on_yank({ timeout = 200 })
    end,
  })

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

  autocmd("BufWritePre", {
    group = augroup("AutoCreateDir", { clear = true }),
    pattern = "*",
    nested = true,
    callback = function(event)
      if event.match:match("^%w%w+://") then
        return
      end
      local file = (vim.uv or vim.loop).fs_realpath(event.match) or event.match
      local dir = vim.fn.fnamemodify(file, ":p:h")
      if dir ~= "" and dir ~= "." and dir ~= vim.fn.fnamemodify(file, ":h") and vim.fn.isdirectory(dir) == 0 then
        pcall(vim.fn.mkdir, dir, "p")
      end
    end,
  })

  autocmd("FileType", {
    group = augroup("CloseWithQ", { clear = true }),
    pattern = { "help", "lspinfo", "man", "notify", "qf", "query", "checkhealth", "mason", "lazy", "neo-tree" },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
  })

  autocmd("BufWritePre", {
    group = augroup("AutoRemoveTrailingSpaces", { clear = true }),
    pattern = "*",
    callback = function()
      if vim.tbl_contains({ "markdown", "diff", "gitcommit" }, vim.bo.filetype) then
        return
      end
      local save_cursor = vim.fn.getpos(".")
      local save_winsize = vim.fn.winsaveview()
      pcall(function()
        vim.cmd([[%s/\s\+$//e]])
      end)
      vim.fn.winrestview(save_winsize)
      vim.fn.setpos(".", save_cursor)
    end,
  })

  -- Startup behavior: open Neo-tree when starting without file, and when starting with a directory
  autocmd("VimEnter", {
    group = augroup("CustomStartup", { clear = true }),
    callback = function()
      local first_arg = vim.fn.argv(0)

      if first_arg == nil then
        vim.defer_fn(function()
          if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == "dashboard" then
            vim.cmd.Neotree()
            vim.cmd.wincmd("p")
          end
        end, 10)
      elseif vim.fn.isdirectory(first_arg) == 1 then
        vim.cmd.cd(first_arg)
        vim.cmd.Neotree()
        vim.cmd.wincmd("p")
        pcall(vim.cmd.close)
      end
    end,
    desc = "Custom startup with dashboard and neo-tree",
  })
end

-- ============================================================================
-- Diagnostics (UNCHANGED)
-- ============================================================================
local function setup_diagnostics()
  vim.diagnostic.config({
    virtual_text = {
      source = true,
      prefix = "●",
      format = function(diagnostic)
        local message = diagnostic.message
        return #message > 80 and message:sub(1, 77) .. "..." or message
      end,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "",
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "always",
      max_width = 120,
      max_height = 30,
      wrap = true,
    },
  })
end

-- ============================================================================
-- LSP (UNCHANGED)
-- ============================================================================
local function setup_lsp()
  local function get_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return capabilities
  end

  local function on_attach(_, bufnr)
    local function map(keys, rhs, desc, mode)
      vim.keymap.set(mode or "n", keys, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
    end

    -- LSP navigation
    map("<C-]>", vim.lsp.buf.definition, "LSP: Go to Definition")
    map("<C-w>]", function()
      vim.cmd("split")
      vim.lsp.buf.definition()
    end, "LSP: Go to Definition (Split)")
    map("<C-w><C-]>", function()
      vim.cmd("vsplit")
      vim.lsp.buf.definition()
    end, "LSP: Go to Definition (Vsplit)")

    -- Jump back (fixed): use jumplist <C-o>
    map("<C-t>", function()
      vim.cmd("normal! \\<C-o>")
    end, "LSP: Jump back")

    map("<leader>dt", vim.lsp.buf.type_definition, "LSP: Type Definition")
    map("<leader>di", vim.lsp.buf.implementation, "LSP: Go to Implementation")
    map("<leader>dr", vim.lsp.buf.references, "LSP: Find References")
    map("<leader>dd", vim.lsp.buf.declaration, "LSP: Go to Declaration")

    map("K", vim.lsp.buf.hover, "LSP: Hover Documentation")
    map("<leader>cr", vim.lsp.buf.rename, "LSP: Rename Symbol")
    map("<C-k>", vim.lsp.buf.signature_help, "LSP: Signature Help")

    map("<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action", { "n", "v" })

    -- Formatting: always use Conform keybind instead of LSP formatter
    map("<leader>cf", function()
      require("conform").format({ async = true, lsp_fallback = true })
    end, "Format: Conform")
  end

  require("mason").setup({ ui = { border = "rounded" } })

  -- Ensure tools installed via Mason (including Python tooling)
  local ensure_installed = {
    "clangd",
    "pyright",
    "ruff",
    "stylua",
    "black",
    "isort",
    "clang-format",
    "prettier",
    "shfmt",
    "cppcheck",  -- NEW: for nvim-lint
  }

  local ok_mr, mr = pcall(require, "mason-registry")
  if ok_mr then
    for _, tool in ipairs(ensure_installed) do
      local ok_pkg, pkg = pcall(mr.get_package, tool)
      if ok_pkg and pkg and not pkg:is_installed() then
        pkg:install()
      end
    end
  end

  require("mason-lspconfig").setup({
    ensure_installed = { "clangd", "pyright", "ruff" },
    handlers = {
      function(server_name)
        require("lspconfig")[server_name].setup({
          capabilities = get_capabilities(),
          on_attach = on_attach,
        })
      end,

      ["clangd"] = function()
        require("lspconfig").clangd.setup({
          capabilities = get_capabilities(),
          on_attach = on_attach,
          cmd = {
            "clangd",
            "--background-index",
            "--cross-file-rename",
            "--completion-style=detailed",
            "--header-insertion=iwyu",
            "--function-arg-placeholders",
          },
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
            semanticHighlighting = true,
          },
        })
      end,

      ["pyright"] = function()
        require("lspconfig").pyright.setup({
          capabilities = get_capabilities(),
          on_attach = on_attach,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                useLibraryCodeForTypes = true,
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                autoImportCompletions = true,
              },
            },
          },
        })
      end,

      -- Ruff provides diagnostics, code actions, and fixes (formatting still via Conform black+isort here)
      ["ruff"] = function()
        require("lspconfig").ruff.setup({
          capabilities = get_capabilities(),
          on_attach = on_attach,
          init_options = {
            settings = {
              -- You can add Ruff settings here if desired
              -- e.g. lineLength = 120,
            },
          },
        })
      end,
    },
  })
end

-- ============================================================================
-- Breakpoints helpers (UNCHANGED)
-- ============================================================================
local function setup_breakpoint()
  local function insert_breakpoint()
    local filetype = vim.bo.filetype
    local line = vim.fn.line(".")
    local indent = vim.fn.indent(line)
    local indent_str = string.rep(" ", indent)

    local breakpoint_map = {
      python = "breakpoint()  # DEBUG",
      c = "raise(SIGTRAP);  // DEBUG",
      cpp = "raise(SIGTRAP);  // DEBUG",
    }

    local breakpoint_line = breakpoint_map[filetype]
    if breakpoint_line then
      vim.fn.append(line - 1, indent_str .. breakpoint_line)
      vim.cmd("normal! j")
      vim.notify("断点已插入: " .. breakpoint_line, vim.log.levels.INFO)
    else
      vim.notify("不支持的文件类型: " .. filetype, vim.log.levels.WARN)
    end
  end

  local function toggle_breakpoint()
    local line = vim.api.nvim_get_current_line()
    local filetype = vim.bo.filetype

    local has_breakpoint = false
    if filetype == "python" and line:match("breakpoint%(%s*%)") then
      has_breakpoint = true
    elseif (filetype == "c" or filetype == "cpp") and line:match("raise%(SIGTRAP%)") then
      has_breakpoint = true
    end

    if has_breakpoint then
      vim.cmd("delete")
      vim.notify("断点已移除", vim.log.levels.INFO)
    else
      insert_breakpoint()
    end
  end

  local function remove_all_breakpoints()
    local filetype = vim.bo.filetype
    local patterns = {
      python = "breakpoint().*DEBUG",
      c = "raise%(SIGTRAP%).*DEBUG",
      cpp = "raise%(SIGTRAP%).*DEBUG",
    }

    local pattern = patterns[filetype]
    if pattern then
      vim.cmd("g/" .. pattern .. "/d")
      vim.notify("所有调试断点已移除", vim.log.levels.INFO)
    else
      vim.notify("不支持的文件类型: " .. filetype, vim.log.levels.WARN)
    end
  end

  vim.keymap.set("n", "<leader>bb", toggle_breakpoint, { desc = "Toggle breakpoint" })
  vim.keymap.set("n", "<leader>bx", remove_all_breakpoints, { desc = "Remove all breakpoints" })
end

-- ============================================================================
-- Keymaps (UNCHANGED)
-- ============================================================================
local function setup_keymaps()
  local keymap = vim.keymap.set

  -- Better movement on wrapped lines
  keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Move down (visual lines)" })
  keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Move up (visual lines)" })

  -- Clipboard
  keymap("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
  keymap("v", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
  keymap("n", "<leader>p", '"+p', { desc = "Paste from system clipboard (after cursor)" })
  keymap("n", "<leader>P", '"+P', { desc = "Paste from system clipboard (before cursor)" })

  -- Window navigation
  keymap("n", "<C-h>", "<C-w>h", { desc = "Navigate window left" })
  keymap("n", "<C-j>", "<C-w>j", { desc = "Navigate window down" })
  keymap("n", "<C-k>", "<C-w>k", { desc = "Navigate window up (will be overridden by LSP buffers)" })
  keymap("n", "<C-l>", "<C-w>l", { desc = "Navigate window right" })
  keymap("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
  keymap("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
  keymap("n", "<leader>wc", "<cmd>close<CR>", { desc = "Close current window" })
  keymap("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })

  -- Editing
  keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear search highlight" })
  keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>write<CR><esc>", { desc = "Save file" })
  keymap("v", "<", "<gv", { desc = "Decrease indent" })
  keymap("v", ">", ">gv", { desc = "Increase indent" })

  -- Lazy
  keymap("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })
  keymap("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "Lazy Update Plugins" })

  -- Format (global shortcut, matches LSP mapping too)
  keymap("n", "<leader>cf", "<cmd>Fm<cr>", { desc = "Format code (Conform)" })

  -- Buffers
  keymap("n", "<leader>bd", function()
    local current_buf = vim.api.nvim_get_current_buf()
    if vim.bo[current_buf].modified then
      local choice = vim.fn.confirm("Buffer has unsaved changes. Save before closing?", "&Yes\n&No\n&Cancel", 1, "Warning")
      if choice == 1 then
        vim.cmd("write")
        vim.cmd("bdelete")
      elseif choice == 2 then
        vim.cmd("bdelete!")
      end
    else
      vim.cmd("bdelete")
    end
  end, { desc = "Delete current buffer (confirm if modified)" })

  keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
  keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

  -- Diagnostics
  keymap("n", "<leader>de", function()
    vim.diagnostic.open_float(nil, { scope = "cursor", border = "rounded", focusable = true })
  end, { desc = "Show diagnostics at cursor" })
  keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
  keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
  keymap("n", "<leader>dq", function()
    vim.diagnostic.setqflist()
  end, { desc = "Diagnostics to Quickfix list" })

  -- Terminal
  keymap("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Terminal: Enter Normal Mode" })

  -- Quit
  keymap("n", "<leader>qq", function()
    local buffers = vim.api.nvim_list_bufs()
    local modified_buffers_info = {}
    for _, buf in ipairs(buffers) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
        table.insert(modified_buffers_info, ("  - %s"):format(vim.api.nvim_buf_get_name(buf) or "[No Name]"))
      end
    end
    if #modified_buffers_info > 0 then
      local msg = "Unsaved changes in:\n" .. table.concat(modified_buffers_info, "\n") .. "\n\nSave all and quit?"
      local choice = vim.fn.confirm(msg, "&Yes\n&No (Quit without saving)\n&Cancel", 1, "Warning")
      if choice == 1 then
        vim.cmd("wall")
        vim.cmd("qa")
      elseif choice == 2 then
        vim.cmd("qa!")
      end
    else
      vim.cmd("qa")
    end
  end, { desc = "Quit all (confirm if modified)" })
  keymap("n", "<leader>q!", "<cmd>qa!<CR>", { desc = "Quit all without saving" })

  -- Center search results
  keymap("n", "n", "nzzzv", { desc = "Next search result (centered)" })
  keymap("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
end

-- ============================================================================
-- Init
-- ============================================================================
setup_options()
setup_autocmds()
setup_diagnostics()
setup_lsp()
setup_breakpoint()
setup_keymaps()
