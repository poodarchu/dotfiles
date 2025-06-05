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

    -- 文件浏览器 - 仅使用 Neo-tree
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
            { "<F3>",      "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
            { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
            { "-",         "<cmd>Neotree reveal<cr>", desc = "Reveal current file in Neo-tree" },
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
                    hide_by_name = {
                        "node_modules",
                        "__pycache__",
                        ".git",
                        ".DS_Store",
                        "thumbs.db",
                    },
                },
            },
            buffers = {
                follow_current_file = { enabled = true },
            },
            git_status = {
                window = {
                    position = "float",
                    mappings = {
                        ["A"]  = "git_add_all",
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

                -- Navigation
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

                -- Actions
                map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage hunk" })
                map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset hunk" })
                map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
                    { desc = "Stage hunk" })
                map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
                    { desc = "Reset hunk" })
                map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage buffer" })
                map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
                map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset buffer" })
                map('n', '<leader>hp', gs.preview_hunk, { desc = "Preview hunk" })
                map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = "Blame line" })
                map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "Toggle line blame" })
                map('n', '<leader>hd', gs.diffthis, { desc = "Diff this" })
                map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = "Diff this ~" })
                map('n', '<leader>td', gs.toggle_deleted, { desc = "Toggle deleted" })
            end
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
                disabled_filetypes = { statusline = { "dashboard", "alpha" } },
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { 'filename' },
                lualine_x = { 'encoding', 'fileformat', 'filetype' },
                lualine_y = { 'progress' },
                lualine_z = { 'location' }
            },
            extensions = { 'neo-tree', 'fugitive', 'trouble' },
        },
    },

    -- 主题
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
        opts = {
            check_ts = true, -- 重新启用 treesitter 检查
            ts_config = {
                lua = { 'string' },
                javascript = { 'template_string' },
                java = false,
            }
        },
    },

    -- 模糊查找
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
                },
            })

            -- 加载扩展
            telescope.load_extension('fzf')
            telescope.load_extension('ui-select')
            telescope.load_extension('file_browser')
            telescope.load_extension('project')
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

    -- 注释 - 修复配置
    {
        'numToStr/Comment.nvim',
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require('Comment').setup({
                padding = true,
                sticky = true,
                ignore = nil,
                toggler = {
                    line = 'gcc',
                    block = 'gbc',
                },
                opleader = {
                    line = 'gc',
                    block = 'gb',
                },
                extra = {
                    above = 'gcO',
                    below = 'gco',
                    eol = 'gcA',
                },
                mappings = {
                    basic = true,
                    extra = true,
                },
                pre_hook = nil,
                post_hook = nil,
            })

            -- 自定义键映射
            local function setup_comment_mappings()
                local comment = require('Comment.api')

                -- 单行注释
                vim.keymap.set('n', '<leader>cc', function()
                    comment.toggle.linewise.current()
                end, { desc = "Toggle comment line" })

                -- 块注释
                vim.keymap.set('n', '<leader>cb', function()
                    comment.toggle.blockwise.current()
                end, { desc = "Toggle comment block" })

                -- 可视模式注释
                vim.keymap.set('v', '<leader>cc', function()
                    comment.toggle.linewise(vim.fn.visualmode())
                end, { desc = "Toggle comment selection" })

                vim.keymap.set('v', '<leader>cb', function()
                    comment.toggle.blockwise(vim.fn.visualmode())
                end, { desc = "Toggle comment block selection" })

                -- 备用快捷键
                vim.keymap.set('n', '\\cc', function()
                    comment.toggle.linewise.current()
                end, { desc = "Toggle comment line" })

                vim.keymap.set('v', '\\cc', function()
                    comment.toggle.linewise(vim.fn.visualmode())
                end, { desc = "Toggle comment selection" })
            end

            -- 延迟设置映射以确保插件完全加载
            vim.defer_fn(setup_comment_mappings, 100)
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
                    footer = {
                        "",
                        "🚀 Fast, Modern, and Powerful Editor",
                        "",
                    },
                },
            })
        end,
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
        opts = {
            ui = { border = "rounded" },
        },
    },

    { 'j-hui/fidget.nvim',      opts = {} },

    -- 补全引擎 - 仅使用 blink.cmp
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
                menu = {
                    border = 'rounded',
                    scrolloff = 2,
                    scrollbar = true,
                },
            },
            signature = {
                enabled = true,
                window = { border = 'rounded' },
            },
        },
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
                javascript = { "prettier" },
                typescript = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
                python = { "black", "isort" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        },
    },

    -- Treesitter - 重新添加
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
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
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
                { "<leader>c", group = "comment/code" },
                { "<leader>f", group = "file/find" },
                { "<leader>g", group = "git" },
                { "<leader>h", group = "git hunks" },
                { "<leader>l", group = "lsp" },
                { "<leader>q", group = "quit/session" },
                { "<leader>w", group = "windows" },
                { "<leader>b", group = "buffer/breakpoint" },
                { "<leader>t", group = "toggle/terminal" },
                { "<leader>x", group = "trouble/diagnostics" },
                { "<leader>d", group = "diagnostics/definition" },
            },
        },
    },

    -- Trouble - 增强的诊断显示
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = "Trouble",
        keys = {
            -- 美观的诊断窗口
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
            -- 快速打开当前行诊断
            {
                "<leader>dd",
                function()
                    local trouble = require("trouble")
                    if trouble.is_open() then
                        trouble.close()
                    else
                        -- 优先使用 Trouble 显示当前缓冲区诊断
                        trouble.open("diagnostics")
                        trouble.focus()
                    end
                end,
                desc = "Toggle Diagnostics (Trouble)",
            },
        },
        opts = {
            -- 美观的配置
            position = "bottom",            -- position of the list can be: bottom, top, left, right
            height = 10,                    -- height of the trouble list when position is top or bottom
            width = 50,                     -- width of the list when position is left or right
            icons = true,                   -- use devicons for filenames
            mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
            severity = nil,                 -- nil (ALL) or vim.diagnostic.severity.ERROR | WARN | INFO | HINT
            fold_open = "",                 -- icon used for open folds
            fold_closed = "",               -- icon used for closed folds
            group = true,                   -- group results by file
            padding = true,                 -- add an extra new line on top of the list
            cycle_results = true,           -- cycle item list when reaching beginning or end of list
            action_keys = {                 -- key mappings for actions in the trouble list
                -- map to {} to remove a mapping, for example:
                -- close = {},
                close = "q",                                 -- close the list
                cancel = "<esc>",                            -- cancel the preview and get back to your last window / buffer / cursor
                refresh = "r",                               -- manually refresh
                jump = { "<cr>", "<tab>", "<2-leftmouse>" }, -- jump to the diagnostic or open / close folds
                open_split = { "<c-x>" },                    -- open buffer in new split
                open_vsplit = { "<c-v>" },                   -- open buffer in new vsplit
                open_tab = { "<c-t>" },                      -- open buffer in new tab
                jump_close = { "o" },                        -- jump to the diagnostic and close the list
                toggle_mode = "m",                           -- toggle between "workspace" and "document" diagnostics mode
                switch_severity = "s",                       -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
                toggle_preview = "P",                        -- toggle auto_preview
                hover = "K",                                 -- opens a small popup with the full multiline message
                preview = "p",                               -- preview the diagnostic location
                open_code_href = "c",                        -- if present, open a URI with more information about the diagnostic error
                close_folds = { "zM", "zm" },                -- close all folds
                open_folds = { "zR", "zr" },                 -- open all folds
                toggle_fold = { "zA", "za" },                -- toggle fold of current file
                previous = "k",                              -- previous item
                next = "j",                                  -- next item
                help = "?"                                   -- help menu
            },
            multiline = true,                                -- render multi-line messages
            indent_lines = true,                             -- add an indent guide below the fold icons
            win_config = { border = "single" },              -- window configuration for floating windows. See |nvim_open_win()|.
            auto_open = false,                               -- automatically open the list when you have diagnostics
            auto_close = false,                              -- automatically close the list when you have no diagnostics
            auto_preview = true,                             -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
            auto_fold = false,                               -- automatically fold a file trouble list at creation
            auto_jump = { "lsp_definitions" },               -- for the given modes, automatically jump if there is only a single result
            include_declaration = {
                "lsp_references",
                "lsp_implementations",
                "lsp_definitions",
            }, -- for the given modes, include the declaration of the current symbol in the results
            signs = {
                -- icons / text used for a diagnostic
                error = "",
                warning = "",
                hint = "",
                information = "",
                other = "",
            },
            use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
        },
        config = function(_, opts)
            require("trouble").setup(opts)

            -- 自动命令：在有诊断错误时自动显示 Trouble（可选）
            vim.api.nvim_create_autocmd("DiagnosticChanged", {
                group = vim.api.nvim_create_augroup("TroubleRefresh", { clear = true }),
                callback = function()
                    local trouble = require("trouble")
                    if trouble.is_open() then
                        trouble.refresh()
                    end
                end,
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
                    { filetype = "Trouble",  text = "Trouble" },
                },
                show_buffer_close_icons = false,
                show_close_icon = false,
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
    pattern = { "help", "lspinfo", "man", "notify", "qf", "query", "Trouble" },
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
-- 诊断配置 - 与 Trouble 结合使用
-- ===========================

vim.diagnostic.config({
    virtual_text = {
        source = true,
        prefix = "●",
        format = function(diagnostic)
            local message = diagnostic.message
            if #message > 80 then
                message = message:sub(1, 77) .. "..."
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
        max_width = 120,
        max_height = 30,
        wrap = true,
        header = "",
        prefix = "",
    },
})

-- 减少自动弹窗的频率，优先使用 Trouble
autocmd({ "CursorHold" }, {
    group = augroup("DiagnosticFloat", { clear = true }),
    callback = function()
        -- 只在没有打开 Trouble 窗口时显示诊断弹窗
        local trouble = require("trouble")
        if not trouble.is_open() then
            local opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = 'rounded',
                source = 'always',
                prefix = ' ',
                scope = 'cursor',
                max_width = 120,
                max_height = 30,
                wrap = true,
            }
            vim.diagnostic.open_float(nil, opts)
        end
    end
})

-- ===========================
-- LSP 设置 - 修复跨文件跳转问题
-- ===========================

require('neodev').setup()

local function get_capabilities()
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    -- 确保支持跨文件跳转
    capabilities.textDocument.definition = {
        dynamicRegistration = true,
        linkSupport = true
    }
    capabilities.textDocument.declaration = {
        dynamicRegistration = true,
        linkSupport = true
    }
    capabilities.textDocument.implementation = {
        dynamicRegistration = true,
        linkSupport = true
    }
    capabilities.textDocument.typeDefinition = {
        dynamicRegistration = true,
        linkSupport = true
    }
    capabilities.textDocument.references = {
        dynamicRegistration = true
    }
    return capabilities
end

local on_attach = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    -- LSP 导航 - 修复跨文件跳转
    vim.keymap.set('n', 'gD', function()
        vim.lsp.buf.declaration()
    end, bufopts)

    vim.keymap.set('n', 'gd', function()
        vim.lsp.buf.definition()
    end, bufopts)

    vim.keymap.set('n', '\\d', function()
        vim.lsp.buf.definition()
    end, bufopts)

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

    -- 调试信息
    vim.keymap.set('n', '<leader>dl', function()
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
        for _, c in pairs(clients) do
            print("LSP Client:", c.name, "Root:", c.config.root_dir)
        end
    end, { buffer = bufnr, desc = "Show LSP info" })
end

-- Mason LSP 设置 - 增强 pylsp 配置以支持跨文件跳转
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
                            -- 使用标准 PEP 错误代码
                            pycodestyle = {
                                enabled = true,
                                maxLineLength = 120,
                                ignore = { "E501" }
                            },
                            pyflakes = { enabled = true },
                            autopep8 = { enabled = true },
                            yapf = { enabled = false },
                            isort = { enabled = true },
                            -- 增强 Jedi 功能以支持跨文件跳转
                            jedi_completion = {
                                enabled = true,
                                include_params = true,
                                include_class_objects = true,
                                fuzzy = true,
                            },
                            jedi_definition = {
                                enabled = true,
                                follow_imports = true,
                                follow_builtin_imports = true,
                            },
                            jedi_hover = { enabled = true },
                            jedi_references = {
                                enabled = true,
                                include_declaration = true,
                            },
                            jedi_signature_help = { enabled = true },
                            jedi_symbols = {
                                enabled = true,
                                all_scopes = true,
                            },
                            rope_completion = { enabled = true },
                            rope_autoimport = {
                                enabled = true,
                                completions = { enabled = true },
                                code_actions = { enabled = true },
                            },
                            mccabe = { enabled = false },
                            pydocstyle = { enabled = false },
                            flake8 = { enabled = false },
                        },
                        configurationSources = { "pycodestyle" },
                    },
                },
                -- 改进根目录检测以支持更好的项目管理
                root_dir = function(fname)
                    local util = require('lspconfig.util')
                    -- 首先查找项目标记文件
                    local root = util.root_pattern(
                        'pyproject.toml',
                        'setup.py',
                        'setup.cfg',
                        'requirements.txt',
                        'Pipfile',
                        'poetry.lock',
                        '.git'
                    )(fname)

                    -- 如果没找到，使用文件目录
                    return root or util.path.dirname(fname)
                end,
                -- 增加初始化选项
                init_options = {
                    settings = {
                        args = {},
                        path = {},
                    }
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
                        diagnostics = { globals = { 'vim' } },
                        workspace = {
                            checkThirdParty = false,
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        telemetry = { enable = false },
                    },
                },
            })
        end,
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
