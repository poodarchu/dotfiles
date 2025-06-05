-- init.lua - 简化的 Neovim 配置
-- ====================================

-- 基础设置
vim.g.mapleader = '\\'
vim.g.maplocalleader = ','
vim.g.have_nerd_font = true

-- 禁用内置插件
local disabled_plugins = {
    "gzip", "tar", "tarPlugin", "zip", "zipPlugin", "getscript", "getscriptPlugin",
    "vimball", "vimballPlugin", "2html_plugin", "logiPat", "rrhelper",
    "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
    "matchit", "matchparen", "spec"
}

for _, plugin in pairs(disabled_plugins) do
    vim.g["loaded_" .. plugin] = 1
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 插件配置
local plugins = {
    -- 基础增强
    'tpope/vim-sensible',

    -- 文件管理器
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = "v3.x",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
        cmd = "Neotree",
        keys = {
            { "<F3>",      "<cmd>Neotree toggle<cr>" },
            { "<leader>e", "<cmd>Neotree toggle<cr>" },
            { "-",         "<cmd>Neotree reveal<cr>" },
        },
        opts = {
            close_if_last_window = true,
            enable_git_status = true,
            window = { position = "left", width = 35 },
            filesystem = {
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
                bind_to_cwd = false,
                filtered_items = {
                    visible = false,
                    hide_dotfiles = false,
                    hide_gitignored = true,
                    hide_by_name = { "node_modules", "__pycache__", ".git", ".DS_Store", "thumbs.db" },
                },
            },
            buffers = { follow_current_file = { enabled = true } },
            git_status = {
                window = {
                    position = "float",
                    mappings = {
                        ["A"] = "git_add_all",
                        ["gu"] = "git_unstage_file",
                        ["ga"] = "git_add_file",
                        ["gr"] = "git_revert_file",
                        ["gc"] = "git_commit",
                        ["gp"] = "git_push",
                        ["gg"] = "git_commit_and_push",
                    }
                }
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
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- 导航
                map('n', ']h', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, { expr = true })

                map('n', '[h', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, { expr = true })

                -- 操作
                local hunk_maps = {
                    ['<leader>hs'] = { gs.stage_hunk, "Stage hunk" },
                    ['<leader>hr'] = { gs.reset_hunk, "Reset hunk" },
                    ['<leader>hS'] = { gs.stage_buffer, "Stage buffer" },
                    ['<leader>hu'] = { gs.undo_stage_hunk, "Undo stage hunk" },
                    ['<leader>hR'] = { gs.reset_buffer, "Reset buffer" },
                    ['<leader>hp'] = { gs.preview_hunk, "Preview hunk" },
                    ['<leader>hb'] = { function() gs.blame_line { full = true } end, "Blame line" },
                    ['<leader>tb'] = { gs.toggle_current_line_blame, "Toggle line blame" },
                    ['<leader>hd'] = { gs.diffthis, "Diff this" },
                    ['<leader>hD'] = { function() gs.diffthis('~') end, "Diff this ~" },
                    ['<leader>td'] = { gs.toggle_deleted, "Toggle deleted" },
                }

                for key, value in pairs(hunk_maps) do
                    map('n', key, value[1], { desc = value[2] })
                end

                -- 视觉模式
                map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
                map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
            end
        },
    },

    'tpope/vim-fugitive',

    -- 状态栏和UI
    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        dependencies = { 'nvim-tree/nvim-web-devicons', 'morhetz/gruvbox' },
        opts = {
            options = { theme = 'gruvbox', globalstatus = true },
            extensions = { 'neo-tree', 'fugitive', 'trouble' },
        },
    },

    {
        'morhetz/gruvbox',
        priority = 1000,
        init = function()
            vim.g.gruvbox_contrast_dark = 'medium'
            vim.g.gruvbox_improved_strings = 1
            vim.g.gruvbox_improved_warnings = 1
        end,
        config = function() vim.cmd.colorscheme('gruvbox') end,
    },

    -- 编辑增强
    {
        'lukas-reineke/indent-blankline.nvim',
        event = { "BufReadPost", "BufNewFile" },
        main = "ibl",
        opts = {
            indent = { char = "│" },
            scope = { enabled = true },
            exclude = { filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" } },
        },
    },

    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        opts = {
            check_ts = true,
            ts_config = { lua = { 'string' }, javascript = { 'template_string' }, java = false }
        },
    },

    -- 搜索工具
    {
        'nvim-telescope/telescope.nvim',
        version = false,
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
            'nvim-telescope/telescope-ui-select.nvim',
            'nvim-telescope/telescope-file-browser.nvim',
            'nvim-telescope/telescope-project.nvim',
        },
        cmd = "Telescope",
        keys = function()
            local keys = {
                -- 文件搜索
                { "<leader>ff", "find_files",                "Find Files" },
                { "<leader>fg", "live_grep",                 "Live Grep" },
                { "<leader>fw", "grep_string",               "Grep Word" },
                { "<leader>fb", "buffers",                   "Buffers" },
                { "<leader>fh", "help_tags",                 "Help Tags" },
                { "<leader>fr", "oldfiles",                  "Recent Files" },
                { "<leader>fc", "commands",                  "Commands" },
                { "<leader>fk", "keymaps",                   "Keymaps" },
                { "<leader>fm", "marks",                     "Marks" },
                { "<leader>fj", "jumplist",                  "Jumplist" },
                -- Git 相关
                { "<leader>gf", "git_files",                 "Git Files" },
                { "<leader>gb", "git_branches",              "Git Branches" },
                { "<leader>gc", "git_commits",               "Git Commits" },
                { "<leader>gt", "git_status",                "Git Status" },
                -- LSP 相关
                { "<leader>ls", "lsp_document_symbols",      "Document Symbols" },
                { "<leader>lS", "lsp_workspace_symbols",     "Workspace Symbols" },
                { "<leader>ld", "diagnostics",               "Diagnostics" },
                { "<leader>lr", "lsp_references",            "References" },
                -- 其他
                { "<leader>fp", "project",                   "Projects" },
                { "<leader>fe", "file_browser",              "File Browser" },
                { "<leader>f/", "current_buffer_fuzzy_find", "Buffer Fuzzy Find" },
            }

            local result = {}
            for _, key in ipairs(keys) do
                table.insert(result, { key[1], "<cmd>Telescope " .. key[2] .. "<cr>", desc = key[3] })
            end
            return result
        end,
        config = function()
            local telescope = require('telescope')
            local actions = require('telescope.actions')

            telescope.setup({
                defaults = {
                    prompt_prefix = "   ",
                    selection_caret = "  ",
                    sorting_strategy = "ascending",
                    layout_config = { horizontal = { prompt_position = "top" }, preview_width = 0.55 },
                    file_ignore_patterns = { "node_modules", "__pycache__", ".git/", "*.pyc", "*.pyo" },
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
                        find_command = vim.fn.executable('rg') == 1 and
                            { "rg", "--files", "--hidden", "--glob", "!**/.git/*" } or nil,
                    },
                    live_grep = { additional_args = function() return { "--hidden", "--glob", "!**/.git/*" } end },
                },
                extensions = {
                    fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
                    file_browser = { theme = "ivy", hijack_netrw = false },
                    project = { base_dirs = { '~/projects', '~/work', '~/.config' }, hidden_files = true },
                },
            })

            -- 加载扩展
            for _, ext in ipairs({ 'fzf', 'ui-select', 'file_browser', 'project' }) do
                telescope.load_extension(ext)
            end
        end,
    },

    -- 会话管理
    {
        'folke/persistence.nvim',
        event = "BufReadPre",
        opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" } },
        keys = {
            { "<leader>qs", function() require("persistence").load() end,                desc = "Restore Session" },
            { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
        },
    },

    -- 注释插件
    {
        'numToStr/Comment.nvim',
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require('Comment').setup()

            local comment = require('Comment.api')
            local maps = {
                ['<leader>cc'] = { function() comment.toggle.linewise.current() end, "Toggle comment line" },
                ['<leader>cb'] = { function() comment.toggle.blockwise.current() end, "Toggle comment block" },
                ['\\cc'] = { function() comment.toggle.linewise.current() end, "Toggle comment line" },
            }

            for key, value in pairs(maps) do
                vim.keymap.set('n', key, value[1], { desc = value[2] })
            end

            vim.keymap.set('v', '<leader>cc', function() comment.toggle.linewise(vim.fn.visualmode()) end)
            vim.keymap.set('v', '<leader>cb', function() comment.toggle.blockwise(vim.fn.visualmode()) end)
            vim.keymap.set('v', '\\cc', function() comment.toggle.linewise(vim.fn.visualmode()) end)
        end,
    },

    -- 启动界面
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
                        { desc = '󰊳 Update Plugins', group = 'Function', action = 'Lazy update', key = 'u' },
                        { desc = ' Find Files', group = 'Identifier', action = 'Telescope find_files', key = 'f' },
                        { desc = ' Live Grep', group = 'String', action = 'Telescope live_grep', key = 'g' },
                        { desc = ' Projects', group = 'Type', action = 'Telescope project', key = 'p' },
                        { desc = ' Recent Files', group = 'Constant', action = 'Telescope oldfiles', key = 'r' },
                        { desc = ' Config', group = 'Keyword', action = 'edit ~/.config/nvim/init.lua', key = 'c' },
                    },
                    packages = { enable = true },
                    project = {
                        enable = true,
                        limit = 8,
                        icon = '󰏓',
                        label = ' Recent Projects',
                        action = 'Telescope find_files cwd='
                    },
                    mru = {
                        limit = 10,
                        icon = '󰋚',
                        label = ' Recent Files',
                        cwd_only = false
                    },
                },
            })
        end,
    },


    -- LSP 支持
    { 'neovim/nvim-lspconfig',   event = { "BufReadPre", "BufNewFile" } },
    { 'williamboman/mason.nvim', cmd = "Mason",                         opts = { ui = { border = "rounded" } } },
    'williamboman/mason-lspconfig.nvim',
    'folke/neodev.nvim',
    { 'j-hui/fidget.nvim',      opts = {} },

    -- 补全系统
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
            appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = 'mono' },
            sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
            completion = {
                accept = { auto_brackets = { enabled = true } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                ghost_text = { enabled = true },
                menu = { border = 'rounded', scrolloff = 2, scrollbar = true },
            },
            signature = { enabled = true, window = { border = 'rounded' } },
        },
    },

    -- 格式化
    {
        'stevearc/conform.nvim',
        event = "BufWritePre",
        keys = {
            { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format buffer" },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                c = { "clang_format" },
                cpp = { "clang_format" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
                python = { "black", "isort" },
            },
            format_on_save = { timeout_ms = 500, lsp_fallback = true },
        },
    },

    -- 语法高亮
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = { "bash", "c", "html", "javascript", "json", "lua", "markdown",
                    "python", "query", "regex", "tsx", "typescript", "vim", "yaml", "cpp" },
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
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner"
                        },
                    },
                },
            })
        end,
    },

    -- 快捷键提示
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            spec = {
                { "<leader>c", group = "comment/code" }, { "<leader>f", group = "file/find" },
                { "<leader>g", group = "git" }, { "<leader>h", group = "git hunks" },
                { "<leader>l", group = "lsp" }, { "<leader>q", group = "quit/session" },
                { "<leader>w", group = "windows" }, { "<leader>b", group = "buffer/breakpoint" },
                { "<leader>t", group = "toggle/terminal" }, { "<leader>x", group = "diagnostics" },
                { "<leader>d", group = "diagnostics/definition" },
            },
        },
    },

    -- 诊断工具
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Document Diagnostics" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
            { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location List" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List" },
        },
        config = function()
            require("trouble").setup({
                modes = { diagnostics = { auto_open = false, auto_close = false, auto_preview = true } },
            })
        end,
    },

    -- 终端
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        keys = {
            { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
            { "<C-\\>",     "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
        },
        opts = { direction = 'float', float_opts = { border = 'curved' } },
    },

    -- UI 增强
    { 'stevearc/dressing.nvim', lazy = true },
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

    -- 缓冲区标签
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
                offsets = { { filetype = "neo-tree", text = "Neo-tree" } },
                show_buffer_close_icons = false,
                show_close_icon = false,
            },
        },
    },

    -- 自动清理空白
    { 'mcauley-penney/tidy.nvim', event = "BufWritePre", opts = { filetype_exclude = { "markdown", "diff" } } },
}

-- 加载插件
require("lazy").setup(plugins, {
    ui = { border = "rounded" },
    performance = {
        rtp = { disabled_plugins = { "gzip", "matchit", "matchparen", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
        cache = { enabled = true },
        reset_packpath = true,
    },
    checker = { enabled = true, notify = false, frequency = 3600 },
    change_detection = { enabled = true, notify = false },
    install = { missing = true, colorscheme = { "gruvbox" } },
})

-- ===========================
-- 基础设置
-- ===========================

local function setup_options()
    local opt = vim.opt

    -- 文件处理
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
end

setup_options()

-- ===========================
-- 自动命令
-- ===========================

local function setup_autocmds()
    local augroup = vim.api.nvim_create_augroup
    local autocmd = vim.api.nvim_create_autocmd

    -- 高亮复制内容
    autocmd("TextYankPost", {
        group = augroup("HighlightYank", { clear = true }),
        callback = function() vim.highlight.on_yank() end,
    })

    -- 记住光标位置
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

    -- 用 q 关闭特定窗口
    autocmd("FileType", {
        group = augroup("CloseWithQ", { clear = true }),
        pattern = { "help", "lspinfo", "man", "notify", "qf", "query" },
        callback = function(event)
            vim.bo[event.buf].buflisted = false
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
        end,
    })

    -- Python 自动去除尾随空格
    autocmd("BufWritePre", {
        group = augroup("AutoRemoveTrailingSpacesPy", { clear = true }),
        pattern = "*.py",
        command = ":%s/\\s\\+$//e",
    })
end

setup_autocmds()

-- ===========================
-- 诊断配置
-- ===========================

local function setup_diagnostics()
    vim.diagnostic.config({
        virtual_text = {
            source = true,
            prefix = "●",
            format = function(diagnostic)
                local message = diagnostic.message
                return #message > 60 and message:sub(1, 57) .. "..." or message
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
            max_width = 120,
            max_height = 30,
            wrap = true,
        },
    })

    -- 自动显示诊断信息
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true }),
        callback = function()
            vim.diagnostic.open_float(nil, {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = 'rounded',
                source = 'always',
                prefix = ' ',
                scope = 'cursor',
                max_width = 120,
                max_height = 30,
                wrap = true,
            })
        end
    })
end

setup_diagnostics()

-- ===========================
-- LSP 配置
-- ===========================

local function setup_lsp()
    require('neodev').setup()

    local function get_capabilities()
        local capabilities = require('blink.cmp').get_lsp_capabilities()
        -- 增强导航功能
        local nav_capabilities = {
            textDocument = {
                definition = { dynamicRegistration = true, linkSupport = true },
                declaration = { dynamicRegistration = true, linkSupport = true },
                implementation = { dynamicRegistration = true, linkSupport = true },
                typeDefinition = { dynamicRegistration = true, linkSupport = true },
                references = { dynamicRegistration = true },
            }
        }
        return vim.tbl_deep_extend("force", capabilities, nav_capabilities)
    end

    local function on_attach(client, bufnr)
        local function map(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        -- LSP 核心功能
        local lsp_maps = {
            ['gD'] = { vim.lsp.buf.declaration, "Go to declaration" },
            ['gd'] = { vim.lsp.buf.definition, "Go to definition" },
            ['\\d'] = { vim.lsp.buf.definition, "Go to definition" },
            ['K'] = { vim.lsp.buf.hover, "Hover" },
            ['gi'] = { vim.lsp.buf.implementation, "Go to implementation" },
            ['<leader>cr'] = { vim.lsp.buf.rename, "Rename" },
            ['gr'] = { vim.lsp.buf.references, "References" },
            ['<leader>D'] = { vim.lsp.buf.type_definition, "Type definition" },
            ['<C-k>'] = { vim.lsp.buf.signature_help, "Signature help" },
            ['<leader>dd'] = { vim.diagnostic.open_float, "Line diagnostics" },
            ['[d'] = { vim.diagnostic.goto_prev, "Previous diagnostic" },
            [']d'] = { vim.diagnostic.goto_next, "Next diagnostic" },
        }

        for key, value in pairs(lsp_maps) do
            map(key, value[1], value[2])
        end

        -- 代码操作
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })

        -- LSP 信息
        map('<leader>dl', function()
            local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
            for _, c in pairs(clients) do
                print("LSP Client:", c.name, "Root:", c.config.root_dir)
            end
        end, "Show LSP info")
    end

    -- Mason LSP 配置
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
                                pycodestyle = { enabled = true, maxLineLength = 120, ignore = { "E501" } },
                                pyflakes = { enabled = true },
                                autopep8 = { enabled = true },
                                yapf = { enabled = false },
                                isort = { enabled = true },
                                jedi_completion = { enabled = true, include_params = true, fuzzy = true },
                                jedi_definition = { enabled = true, follow_imports = true },
                                jedi_hover = { enabled = true },
                                jedi_references = { enabled = true },
                                jedi_signature_help = { enabled = true },
                                jedi_symbols = { enabled = true },
                                rope_completion = { enabled = true },
                                rope_autoimport = { enabled = true, completions = { enabled = true } },
                            },
                        },
                    },
                    root_dir = function(fname)
                        local util = require('lspconfig.util')
                        return util.root_pattern('pyproject.toml', 'setup.py', 'requirements.txt', '.git')(fname)
                            or util.path.dirname(fname)
                    end,
                })
            end,

            ["lua_ls"] = function()
                require('lspconfig').lua_ls.setup({
                    capabilities = get_capabilities(),
                    on_attach = on_attach,
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            diagnostics = { globals = { 'vim' } },
                            workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
                            telemetry = { enable = false },
                        },
                    },
                })
            end,
        },
    })
end

setup_lsp()

-- ===========================
-- 键位映射
-- ===========================

local function setup_keymaps()
    local keymap = vim.keymap.set

    -- 基础编辑
    keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
    keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

    -- 窗口导航
    local window_maps = {
        ["<C-h>"] = "<C-w>h",
        ["<C-j>"] = "<C-w>j",
        ["<C-k>"] = "<C-w>k",
        ["<C-l>"] = "<C-w>l"
    }
    for key, value in pairs(window_maps) do
        keymap("n", key, value)
    end

    -- 清除搜索高亮
    keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>")

    -- 保存文件
    keymap({ "i", "x", "n", "s" }, "<C-s>", function()
        if vim.bo.modified then vim.cmd("write") end
    end)

    -- 缩进调整
    keymap("v", "<", "<gv")
    keymap("v", ">", ">gv")

    -- Lazy 插件管理
    local lazy_maps = {
        ["<leader>l"] = { "<cmd>Lazy<cr>", "Lazy Plugin Manager" },
        ["<leader>li"] = { "<cmd>Lazy install<cr>", "Lazy Install" },
        ["<leader>lu"] = { "<cmd>Lazy update<cr>", "Lazy Update" },
        ["<leader>lx"] = { "<cmd>Lazy clean<cr>", "Lazy Clean" },
    }
    for key, value in pairs(lazy_maps) do
        keymap("n", key, value[1], { desc = value[2] })
    end

    -- 窗口分割
    keymap("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
    keymap("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

    -- Git 快捷键
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

    -- Python 调试断点
    local function toggle_breakpoint()
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        local current_indent = vim.api.nvim_get_current_line():match('^%s*')
        local breakpoint_line = current_indent .. "breakpoint()  # Debug breakpoint"

        if current_line == 1 then
            local line_content = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
            if vim.trim(line_content) == vim.trim(breakpoint_line) then
                vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
            else
                vim.api.nvim_buf_set_lines(0, 0, 0, false, { breakpoint_line })
            end
        else
            local line_above = vim.api.nvim_buf_get_lines(0, current_line - 2, current_line - 1, false)[1] or ""
            if vim.trim(line_above) == vim.trim(breakpoint_line) then
                vim.api.nvim_buf_set_lines(0, current_line - 2, current_line - 1, false, {})
            else
                vim.api.nvim_buf_set_lines(0, current_line - 1, current_line - 1, false, { breakpoint_line })
            end
        end
    end

    keymap('n', '<leader>b', toggle_breakpoint, { desc = "Toggle breakpoint" })
    keymap('n', '<F9>', toggle_breakpoint, { desc = "Toggle breakpoint" })

    -- 终端模式
    keymap("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })

    -- 退出程序
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
            local choice = vim.fn.confirm("Some buffers have unsaved changes. Save all and quit?", "&Yes\n&No\n&Cancel",
                3)
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

    -- 搜索导航
    keymap("n", "n", "nzzzv", { desc = "Next search result" })
    keymap("n", "N", "Nzzzv", { desc = "Previous search result" })

    -- Tab 标签页
    keymap("n", "<Tab>", "gt", { desc = "Next tab" })
    keymap("n", "<S-Tab>", "gT", { desc = "Previous tab" })
    keymap("n", "<S-t>", "<cmd>tabnew<CR>", { desc = "New tab" })

    -- 诊断导航
    keymap("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
    keymap("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
end

setup_keymaps()
