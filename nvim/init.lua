-- init.lua - 优化的 Neovim 配置
-- ====================================

-- 性能优化 - 禁用不需要的内置插件
local disabled_built_ins = {
  "gzip", "tar", "tarPlugin", "zip", "zipPlugin", "getscript", "getscriptPlugin",
  "vimball", "vimballPlugin", "2html_plugin", "logiPat", "rrhelper",
  "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
  "matchit", "matchparen", "spec"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Leader 键设置
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

-- 插件配置
local plugins = {
  -- 核心功能
  'tpope/vim-sensible',

  -- 文件浏览器 (使用 Oil 作为主要的，Neo-tree 作为备用)
  {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer" },
    },
    opts = {
      default_file_explorer = true,
      columns = { "icon", "permissions", "size", "mtime" },
      view_options = {
        show_hidden = false,
        is_hidden_file = function(name) return vim.startswith(name, ".") end,
      },
      float = {
        padding = 2,
        border = "rounded",
        win_options = { winblend = 0 },
      },
    },
  },

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
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      window = { position = "left", width = 35 },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        bind_to_cwd = false,
      },
    },
  },

  -- Git 集成
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

  -- 状态栏
  {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'gruvbox-material',
        globalstatus = true,
      },
    },
  },

  -- 主题
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = 'medium'
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_foreground = 'material'
      vim.cmd.colorscheme('gruvbox-material')
    end,
  },

  -- 缩进指南
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
      exclude = {
        filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
      },
    },
  },

  -- 自动配对
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = { check_ts = true },
  },

  -- 模糊查找
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
          layout_config = { horizontal = { prompt_position = "top" } },
          file_ignore_patterns = { "node_modules", "__pycache__", ".git/", "*.pyc" },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = vim.fn.executable('rg') == 1 and
              { "rg", "--files", "--hidden", "--glob", "!**/.git/*" } or nil,
          },
        },
      })
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
    end,
  },

  -- 会话管理
  {
    'folke/persistence.nvim',
    event = "BufReadPre",
    opts = {
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
    },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    },
  },

  -- 注释
  {
    'numToStr/Comment.nvim',
    keys = {
      { "<leader>c", mode = { "n", "v" }, desc = "Toggle comment" },
    },
    opts = {
      toggler = { line = '<leader>cc' },
      opleader = { line = '<leader>c' },
    },
  },

  -- 启动界面
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
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
        },
        shortcut = {
          { desc = '󰊳 Update', action = 'Lazy update', key = 'u' },
          { desc = ' Files', action = 'Telescope find_files', key = 'f' },
        },
      },
    },
  },

  -- LSP 配置
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

  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    opts = { ui = { border = "rounded" } },
  },

  { 'j-hui/fidget.nvim', opts = {} },

  -- 补全引擎
  {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = 'rafamadriz/friendly-snippets',
    version = 'v0.*',
    opts = {
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = true },
      }
    },
  },

  -- 代码检查
  {
    'mfussenegger/nvim-lint',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = { python = { } }

      -- 防抖动检查
      local lint_debounce = {}
      local function debounced_lint()
        local bufnr = vim.api.nvim_get_current_buf()
        if lint_debounce[bufnr] then
          vim.loop.timer_stop(lint_debounce[bufnr])
        end
        lint_debounce[bufnr] = vim.loop.new_timer()
        lint_debounce[bufnr]:start(500, 0, vim.schedule_wrap(function()
          if vim.api.nvim_buf_is_valid(bufnr) then lint.try_lint() end
        end))
      end

      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = debounced_lint,
      })
    end,
  },

  -- 格式化
  {
    'stevearc/conform.nvim',
    event = "BufWritePre",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        c = { "clang_format" },
        cpp = { "clang_format" },
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
          "python", "query", "regex", "tsx", "typescript", "vim", "yaml", "cpp",
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
        { "<leader>x", group = "diagnostics" },
      },
    },
  },

  -- 诊断信息
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Document Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
    },
    config = function()
      require("trouble").setup({
        modes = {
          diagnostics = { auto_open = false, auto_close = false, auto_preview = true },
        },
      })
    end,
  },

  -- 终端
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

  -- UI 增强
  { 'stevearc/dressing.nvim', lazy = true },

  -- 通知
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      background_colour = "#000000",
      timeout = 3000,
      render = "default",
      stages = "fade_in_slide_out",
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  -- 缓冲区管理
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
          { filetype = "neo-tree", text = "Neo-tree" },
          { filetype = "oil", text = "Oil" },
        },
      },
    },
  },

  -- 自动清理尾随空格
  {
    'mcauley-penney/tidy.nvim',
    event = "BufWritePre",
    opts = { filetype_exclude = { "markdown", "diff" } },
  },
}

-- 加载插件
require("lazy").setup(plugins, {
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
    cache = { enabled = true },
    reset_packpath = true,
  },
  checker = { enabled = true, notify = false, frequency = 3600 },
  change_detection = { enabled = true, notify = false },
  install = { missing = true, colorscheme = { "gruvbox-material" } },
})

-- ===========================
-- 基本设置
-- ===========================

local opt = vim.opt

-- 基本选项
opt.encoding = 'utf-8'
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.confirm = true

-- 缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- 搜索
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

-- 补全
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.textwidth = 120

-- ===========================
-- 自动命令
-- ===========================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- 高亮复制内容
autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- 返回到上次位置
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

-- 自动创建目录
autocmd("BufWritePre", {
  group = augroup("AutoCreateDir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- 使用 q 关闭某些文件类型
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = { "help", "lspinfo", "man", "notify", "qf", "query" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- ===========================
-- LSP 设置
-- ===========================

require('neodev').setup()

local function get_capabilities()
  return require('blink.cmp').get_lsp_capabilities()
end

local on_attach = function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, bufopts)
  vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
end

require('mason-lspconfig').setup({
  ensure_installed = { 'clangd', 'lua_ls', 'pylsp' },
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({
        capabilities = get_capabilities(),
        on_attach = on_attach,
      })
    end,

    ["pylsp"] = function()
      require('lspconfig').pylsp.setup({
        capabilities = get_capabilities(),
        on_attach = on_attach,
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = { enabled = true },
              pyflakes = { enabled = true },
              autopep8 = { enabled = false },
              isort = { enabled = true },
              jedi_completion = { enabled = true },
              jedi_definition = { enabled = true },
              jedi_hover = { enabled = true },
              jedi_references = { enabled = true },
              jedi_signature_help = { enabled = true },
            },
          },
        },
      })
    end,

    ["lua_ls"] = function()
      require('lspconfig').lua_ls.setup({
        capabilities = get_capabilities(),
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
  },
})

-- ===========================
-- 诊断配置
-- ===========================

vim.diagnostic.config({
  virtual_text = {
    source = true,
    prefix = "●",
    format = function(diagnostic)
      local message = diagnostic.message
      if #message > 60 then
        message = message:sub(1, 57) .. "..."
      end
      return message
    end,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    focusable = true,
    max_width = 100,
  },
})

-- 自动显示诊断悬浮窗口
autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = 'rounded',
      source = 'always',
      scope = 'cursor',
    })
  end,
})

-- ===========================
-- 键盘映射
-- ===========================

local keymap = vim.keymap.set

-- 更好的上下移动
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- 窗口导航
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- 清除搜索高亮
keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- 保存文件
keymap({ "i", "x", "n", "s" }, "<C-s>", function()
  if vim.bo.modified then vim.cmd("write") end
end, { desc = "Save file" })

-- 更好的缩进
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Lazy
keymap("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- 分割窗口
keymap("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
keymap("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Git 映射
keymap("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
keymap("n", "<leader>gc", "<cmd>Git commit --verbose<CR>", { desc = "Git commit" })

-- 缓冲区管理
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

-- 断点切换
local function toggle_breakpoint()
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

keymap('n', '<leader>b', toggle_breakpoint, { desc = "Toggle breakpoint" })
keymap('n', '<F9>', toggle_breakpoint, { desc = "Toggle breakpoint" })

-- 终端模式键映射
keymap("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })

-- 快速退出
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
