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
            { "-",         "<cmd>Oil<cr>", desc = "Open parent directory" },
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
        dependencies = { 'nvim-tree/nvim-web-devicons', 'morhetz/gruvbox' },
        opts = {
            options = {
                theme = 'gruvbox',
                globalstatus = true,
            },
        },
    },

    -- 主题 (采用 B 配置的 gruvbox)
    {
        'morhetz/gruvbox',
        priority = 1000,
        init = function()
            vim.g.gruvbox_contrast_dark = 'medium'
            vim.g.gruvbox_improved_strings = 1
            vim.g.gruvbox_improved_warnings = 1
        end,
        config = function()
            vim.cmd.colorscheme('gruvbox')
        end,
    },

    -- 缩进指南
    {
        'lukas-reineke/indent-blankline.nvim',
        event = { "BufReadPost", "BufNewFile" },
        main = "ibl",
        opts = {
            indent = { char = "┆" },
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

    -- 模糊查找 (增强 Telescope 功能)
    {
        'nvim-telescope/telescope.nvim',
        version = false,
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
            'nvim-telescope/telescope-ui-select.nvim',
            'nvim-telescope/telescope-file-browser.nvim',
            'nvim-telescope/telescope-project.nvim',
            'nvim-telescope/telescope-frecency.nvim',
        },
        cmd = "Telescope",
        keys = {
            -- 基础搜索
            { "<leader>ff", "<cmd>Telescope find_files<cr>",                desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",                 desc = "Live Grep" },
            { "<leader>fw", "<cmd>Telescope grep_string<cr>",               desc = "Grep Word" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",                   desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",                 desc = "Help Tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                  desc = "Recent Files" },
            { "<leader>fc", "<cmd>Telescope commands<cr>",                  desc = "Commands" },
            { "<leader>fk", "<cmd>Telescope keymaps<cr>",                   desc = "Keymaps" },
            { "<leader>fm", "<cmd>Telescope marks<cr>",                     desc = "Marks" },
            { "<leader>fj", "<cmd>Telescope jumplist<cr>",                  desc = "Jumplist" },

            -- Git 相关
            { "<leader>gf", "<cmd>Telescope git_files<cr>",                 desc = "Git Files" },
            { "<leader>gb", "<cmd>Telescope git_branches<cr>",              desc = "Git Branches" },
            { "<leader>gc", "<cmd>Telescope git_commits<cr>",               desc = "Git Commits" },
            { "<leader>gt", "<cmd>Telescope git_status<cr>",                desc = "Git Status" },

            -- LSP 相关
            { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>",      desc = "Document Symbols" },
            { "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<cr>",     desc = "Workspace Symbols" },
            { "<leader>ld", "<cmd>Telescope diagnostics<cr>",               desc = "Diagnostics" },
            { "<leader>lr", "<cmd>Telescope lsp_references<cr>",            desc = "References" },

            -- 项目管理
            { "<leader>fp", "<cmd>Telescope project<cr>",                   desc = "Projects" },
            { "<leader>fe", "<cmd>Telescope file_browser<cr>",              desc = "File Browser" },
            { "<leader>fF", "<cmd>Telescope frecency<cr>",                  desc = "Frecency Files" },

            -- 高级搜索
            { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer Fuzzy Find" },
            { "<leader>f?", "<cmd>Telescope search_history<cr>",            desc = "Search History" },
            { "<leader>f:", "<cmd>Telescope command_history<cr>",           desc = "Command History" },
        },
        config = function()
            local telescope = require('telescope')
            local actions = require('telescope.actions')

            telescope.setup({
                defaults = {
                    prompt_prefix = "   ",
                    selection_caret = "  ",
                    sorting_strategy = "ascending",
                    layout_config = {
                        horizontal = { prompt_position = "top" },
                        preview_width = 0.55,
                    },
                    file_ignore_patterns = { "node_modules", "__pycache__", ".git/", "*.pyc", "*.pyo" },
                    mappings = {
                        i = {
                            ["<C-u>"] = false,
                            ["<C-d>"] = false,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        },
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true,
                        find_command = vim.fn.executable('rg') == 1 and
                            { "rg", "--files", "--hidden", "--glob", "!**/.git/*" } or nil,
                    },
                    live_grep = {
                        additional_args = function()
                            return { "--hidden", "--glob", "!**/.git/*" }
                        end,
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                    file_browser = {
                        theme = "ivy",
                        hijack_netrw = false,
                    },
                    project = {
                        base_dirs = {
                            '~/projects',
                            '~/work',
                            '~/.config',
                        },
                        hidden_files = true,
                    },
                    frecency = {
                        show_scores = false,
                        show_unindexed = true,
                        ignore_patterns = { "*.git/*", "*/tmp/*" },
                    },
                },
            })

            -- 加载扩展
            telescope.load_extension('fzf')
            telescope.load_extension('ui-select')
            telescope.load_extension('file_browser')
            telescope.load_extension('project')
            telescope.load_extension('frecency')
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
            { "<leader>qs", function() require("persistence").load() end,                desc = "Restore Session" },
            { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
        },
    },

    -- 注释 (增强注释功能)
    {
        'numToStr/Comment.nvim',
        event = { "BufReadPost", "BufNewFile" },
        keys = {
            { "<leader>cc",       desc = "Toggle comment line" },
            { "<leader>c<space>", desc = "Toggle comment" },
            { "\\cc",             desc = "Toggle comment line" },
            { "\\c<space>",       desc = "Toggle comment" },
        },
        config = function()
            require('Comment').setup({
                toggler = {
                    line = '<leader>cc',
                    block = '<leader>cb',
                },
                opleader = {
                    line = '<leader>c<space>',
                    block = '<leader>cb',
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

            -- 添加自定义键映射
            vim.keymap.set('n', '\\cc', '<leader>cc', { remap = true, desc = "Toggle comment line" })
            vim.keymap.set('n', '\\c<space>', '<leader>c<space>', { remap = true, desc = "Toggle comment" })
            vim.keymap.set('v', '\\cc', '<leader>cc', { remap = true, desc = "Toggle comment selection" })
            vim.keymap.set('v', '\\c<space>', '<leader>c<space>', { remap = true, desc = "Toggle comment selection" })
        end,
    },

    -- 启动界面 (增强 dashboard)
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
                    footer = {
                        "",
                        "🚀 Fast, Modern, and Powerful Editor",
                        "",
                    },
                },
            })
        end,
    },

    -- Avante.nvim - AI 代码助手
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        version = false,
        opts = {
            provider = "claude",
            auto_suggestions_provider = "claude",
            behaviour = {
                auto_suggestions = false,
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = false,
            },
            mappings = {
                diff = {
                    ours = "co",
                    theirs = "ct",
                    all_theirs = "ca",
                    both = "cb",
                    cursor = "cc",
                    next = "]x",
                    prev = "[x",
                },
                suggestion = {
                    accept = "<M-l>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
                jump = {
                    next = "]]",
                    prev = "[[",
                },
                submit = {
                    normal = "<CR>",
                    insert = "<C-s>",
                },
            },
            windows = {
                position = "right",
                width = 30,
                sidebar_header = {
                    enabled = true,
                    align = "center",
                    rounded = true,
                },
            },
        },
        build = "make",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            "zbirenbaum/copilot.lua",
            {
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        use_absolute_path = true,
                    },
                },
            },
            {
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
        keys = {
            { "<leader>aa", function() require("avante.api").ask() end,     desc = "Avante: Ask" },
            { "<leader>ar", function() require("avante.api").refresh() end, desc = "Avante: Refresh" },
            { "<leader>ae", function() require("avante.api").edit() end,    desc = "Avante: Edit",          mode = "v" },
            { "<leader>at", function() require("avante").toggle() end,      desc = "Avante: Toggle Sidebar" },
            { "<leader>af", function() require("avante").focus() end,       desc = "Avante: Focus Sidebar" },
            { "<leader>ac", "<cmd>AvanteChat<cr>",                          desc = "Avante: Chat" },
            { "<leader>aN", "<cmd>AvanteChatNew<cr>",                       desc = "Avante: New Chat" },
            { "<leader>ah", "<cmd>AvanteHistory<cr>",                       desc = "Avante: Chat History" },
            { "<leader>aS", "<cmd>AvanteStop<cr>",                          desc = "Avante: Stop" },
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

    { 'j-hui/fidget.nvim',      opts = {} },

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
                providers = {
                    avante_commands = {
                        name = "avante_commands",
                        module = "blink.compat.source",
                        score_offset = 90,
                        opts = {},
                    },
                    avante_files = {
                        name = "avante_files",
                        module = "blink.compat.source",
                        score_offset = 100,
                        opts = {},
                    },
                    avante_mentions = {
                        name = "avante_mentions",
                        module = "blink.compat.source",
                        score_offset = 1000,
                        opts = {},
                    },
                },
            },
            completion = {
                accept = { auto_brackets = { enabled = true } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                ghost_text = { enabled = true },
            }
        },
    },

    -- Python 静态检查
    {
        'mfussenegger/nvim-lint',
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require('lint')
            lint.linters_by_ft = {
                python = { 'flake8', 'mypy' },
                lua = { 'luacheck' },
                javascript = { 'eslint' },
                typescript = { 'eslint' },
            }

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

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
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
                python = { "black", "isort" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
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
                { "<leader>a", group = "avante" },
                { "<leader>c", group = "comment/code" },
                { "<leader>f", group = "file/find" },
                { "<leader>g", group = "git" },
                { "<leader>l", group = "lsp" },
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
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Document Diagnostics" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
            { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location List" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List" },
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
            { "<C-\\>",     "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
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
                    { filetype = "oil",      text = "Oil" },
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
    install = { missing = true, colorscheme = { "gruvbox" } },
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
opt.laststatus = 3 -- 全局状态栏 (推荐用于 avante.nvim)

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

-- Python 自动移除尾随空格
autocmd("BufWritePre", {
    group = augroup("AutoRemoveTrailingSpacesPy", { clear = true }),
    pattern = "*.py",
    command = ":%s/\\s\\+$//e",
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

    -- LSP 导航 (实现 \d 或 gd 跳转到定义)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', '\\d', vim.lsp.buf.definition, bufopts) -- 添加 \d 快捷键
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, bufopts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)

    -- 类型定义和签名帮助
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
end

require('mason-lspconfig').setup({
    ensure_installed = { 'clangd', 'lua_ls', 'pylsp', 'ruff_lsp' },
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
                            pycodestyle = { enabled = true, maxLineLength = 120 },
                            pyflakes = { enabled = true },
                            autopep8 = { enabled = false },
                            yapf = { enabled = false },
                            isort = { enabled = true },
                            jedi_completion = { enabled = true },
                            jedi_definition = { enabled = true },
                            jedi_hover = { enabled = true },
                            jedi_references = { enabled = true },
                            jedi_signature_help = { enabled = true },
                            rope_completion = { enabled = true },
                        },
                    },
                },
            })
        end,

        ["ruff_lsp"] = function()
            require('lspconfig').ruff_lsp.setup({
                capabilities = get_capabilities(),
                on_attach = on_attach,
                init_options = {
                    settings = {
                        args = {},
                    }
                }
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
keymap("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })
keymap("n", "<leader>li", "<cmd>Lazy install<cr>", { desc = "Lazy Install" })
keymap("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "Lazy Update" })
keymap("n", "<leader>ls", "<cmd>Lazy sync<cr>", { desc = "Lazy Sync" })
keymap("n", "<leader>lx", "<cmd>Lazy clean<cr>", { desc = "Lazy Clean" })
keymap("n", "<leader>lc", "<cmd>Lazy check<cr>", { desc = "Lazy Check" })
keymap("n", "<leader>ld", "<cmd>Lazy debug<cr>", { desc = "Lazy Debug" })
keymap("n", "<leader>lp", "<cmd>Lazy profile<cr>", { desc = "Lazy Profile" })

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

-- 搜索居中
keymap("n", "n", "nzzzv", { desc = "Next search result" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result" })

-- Tab 导航
keymap("n", "<Tab>", "gt", { desc = "Next tab" })
keymap("n", "<S-Tab>", "gT", { desc = "Previous tab" })
keymap("n", "<S-t>", "<cmd>tabnew<CR>", { desc = "New tab" })
