-- init.lua - ¿¿¿ Neovim ¿¿
-- ====================================

-- ¿¿¿¿ - ¿¿¿¿¿¿¿¿¿¿
local disabled_built_ins = {
    "gzip", "tar", "tarPlugin", "zip", "zipPlugin", "getscript", "getscriptPlugin",
    "vimball", "vimballPlugin", "2html_plugin", "logiPat", "rrhelper",
    "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
    "matchit", "matchparen", "spec"
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end

-- Leader ¿¿¿
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

-- ¿¿¿¿
local plugins = {
    -- ¿¿¿¿
    'tpope/vim-sensible',

    -- ¿¿¿¿¿ - ¿¿¿ Neo-tree
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
            { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
            { "-", "<cmd>Neotree reveal<cr>", desc = "Reveal current file in Neo-tree" },
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

    -- Git ¿¿
    {
        'lewis6991/gitsigns.nvim',
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = '¿' },
                change = { text = '¿' },
                delete = { text = '_' },
                topdelete = { text = '¿' },
                changedelete = { text = '~' },
                untracked = { text = '¿' },
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
                end, {expr=true})

                map('n', '[h', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, {expr=true})

                -- Actions
                map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage hunk" })
                map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset hunk" })
                map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Stage hunk" })
                map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Reset hunk" })
                map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage buffer" })
                map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
                map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset buffer" })
                map('n', '<leader>hp', gs.preview_hunk, { desc = "Preview hunk" })
                map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = "Blame line" })
                map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "Toggle line blame" })
                map('n', '<leader>hd', gs.diffthis, { desc = "Diff this" })
                map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = "Diff this ~" })
                map('n', '<leader>td', gs.toggle_deleted, { desc = "Toggle deleted" })
            end
        },
    },

    'tpope/vim-fugitive',

    -- ¿¿¿
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
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {'filename'},
                lualine_x = {'encoding', 'fileformat', 'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location'}
            },
            extensions = { 'neo-tree', 'fugitive', 'trouble' },
        },
    },

    -- ¿¿
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

    -- ¿¿¿¿
    {
        'lukas-reineke/indent-blankline.nvim',
        event = { "BufReadPost", "BufNewFile" },
        main = "ibl",
        opts = {
            indent = { char = "¿" },
            scope = { enabled = true },
            exclude = {
                filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
            },
        },
    },

    -- ¿¿¿¿
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        opts = { 
            check_ts = true, -- ¿¿¿¿ treesitter ¿¿
            ts_config = {
                lua = {'string'},
                javascript = {'template_string'},
                java = false,
            }
        },
    },

    -- ¿¿¿¿
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
            -- ¿¿¿¿
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
            { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep Word" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
            { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
            { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
            { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Marks" },
            { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },

            -- Git ¿¿
            { "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "Git Files" },
            { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
            { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
            { "<leader>gt", "<cmd>Telescope git_status<cr>", desc = "Git Status" },

            -- LSP ¿¿
            { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
            { "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },
            { "<leader>ld", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
            { "<leader>lr", "<cmd>Telescope lsp_references<cr>", desc = "References" },

            -- ¿¿¿¿
            { "<leader>fp", "<cmd>Telescope project<cr>", desc = "Projects" },
            { "<leader>fe", "<cmd>Telescope file_browser<cr>", desc = "File Browser" },

            -- ¿¿¿¿
            { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer Fuzzy Find" },
            { "<leader>f?", "<cmd>Telescope search_history<cr>", desc = "Search History" },
            { "<leader>f:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
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

            -- ¿¿¿¿
            telescope.load_extension('fzf')
            telescope.load_extension('ui-select')
            telescope.load_extension('file_browser')
            telescope.load_extension('project')
        end,
    },

    -- ¿¿¿¿
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

    -- ¿¿ - ¿¿¿¿
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
            
            -- ¿¿¿¿¿¿
            local function setup_comment_mappings()
                local comment = require('Comment.api')
                
                -- ¿¿¿¿
                vim.keymap.set('n', '<leader>cc', function()
                    comment.toggle.linewise.current()
                end, { desc = "Toggle comment line" })
                
                -- ¿¿¿
                vim.keymap.set('n', '<leader>cb', function()
                    comment.toggle.blockwise.current()
                end, { desc = "Toggle comment block" })
                
                -- ¿¿¿¿¿¿
                vim.keymap.set('v', '<leader>cc', function()
                    comment.toggle.linewise(vim.fn.visualmode())
                end, { desc = "Toggle comment selection" })
                
                vim.keymap.set('v', '<leader>cb', function()
                    comment.toggle.blockwise(vim.fn.visualmode())
                end, { desc = "Toggle comment block selection" })
                
                -- ¿¿¿¿¿
                vim.keymap.set('n', '\\cc', function()
                    comment.toggle.linewise.current()
                end, { desc = "Toggle comment line" })
                
                vim.keymap.set('v', '\\cc', function()
                    comment.toggle.linewise(vim.fn.visualmode())
                end, { desc = "Toggle comment selection" })
            end
            
            -- ¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿
            vim.defer_fn(setup_comment_mappings, 100)
        end,
    },

    -- ¿¿¿¿
    {
        'nvimdev/dashboard-nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('dashboard').setup({
                theme = 'hyper',
                config = {
                    header = {
                        "¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿¿¿¿¿¿   ¿¿¿     ¿¿¿¿¿¿¿¿¿¿   ¿¿¿    ¿¿¿¿¿¿¿¿¿¿¿  ¿¿¿¿¿¿   ¿¿¿",
                        "¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿  ¿¿¿     ¿¿¿¿¿¿¿¿¿¿¿  ¿¿¿    ¿¿¿¿¿¿¿¿¿¿¿  ¿¿¿¿¿¿   ¿¿¿",
                        "¿¿¿¿¿¿¿¿¿¿¿¿¿¿  ¿¿¿¿¿¿ ¿¿¿     ¿¿¿¿¿¿¿¿¿¿¿¿ ¿¿¿      ¿¿¿¿¿ ¿¿¿¿¿¿¿¿¿¿¿   ¿¿¿",
                        "¿¿¿¿¿¿¿¿¿¿¿¿¿¿  ¿¿¿¿¿¿¿¿¿¿¿¿   ¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿     ¿¿¿¿¿  ¿¿¿¿¿¿¿¿¿¿¿   ¿¿¿",
                        "¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿ ¿¿¿¿¿¿    ¿¿¿¿¿¿¿¿¿¿¿  ¿¿¿¿¿¿¿¿¿¿¿¿",
                        "¿¿¿¿¿¿¿ ¿¿¿¿¿¿¿¿¿¿¿  ¿¿¿¿¿ ¿¿¿¿¿¿ ¿¿¿¿¿¿  ¿¿¿¿¿    ¿¿¿¿¿¿¿¿¿¿¿  ¿¿¿ ¿¿¿¿¿¿¿ ",
                        "",
                        "                         ¿ Welcome to Neovim ¿                           ",
                        "",
                    },
                    shortcut = {
                        { desc = '¿ Update Plugins', group = 'Function', action = 'Lazy update', key = 'u' },
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
                        icon = '¿',
                        label = ' Recent Projects',
                        action = 'Telescope find_files cwd='
                    },
                    mru = {
                        limit = 10,
                        icon = '¿',
                        label = ' Recent Files',
                        cwd_only = false
                    },
                    footer = {
                        "",
                        "¿ Fast, Modern, and Powerful Editor",
                        "",
                    },
                },
            })
        end,
    },

    -- LSP ¿¿
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

    { 'j-hui/fidget.nvim', opts = {} },

    -- ¿¿¿¿ - ¿¿¿ blink.cmp
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

    -- ¿¿¿
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

    -- Treesitter - ¿¿¿¿
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
                { "<leader>x", group = "diagnostics" },
                { "<leader>d", group = "diagnostics/definition" },
            },
        },
    },

    -- ¿¿¿¿
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Document Diagnostics" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
            { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
        },
        config = function()
            require("trouble").setup({
                modes = {
                    diagnostics = { auto_open = false, auto_close = false, auto_preview = true },
                },
            })
        end,
    },

    -- ¿¿
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

    -- UI ¿¿
    { 'stevearc/dressing.nvim', lazy = true },

    -- ¿¿
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

    -- ¿¿¿¿¿
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
                },
                show_buffer_close_icons = false,
                show_close_icon = false,
            },
        },
    },

    -- ¿¿¿¿¿¿¿¿
    {
        'mcauley-penney/tidy.nvim',
        event = "BufWritePre",
        opts = { filetype_exclude = { "markdown", "diff" } },
    },
}

-- ¿¿¿¿
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
-- ¿¿¿¿
-- ===========================

local opt = vim.opt

-- ¿¿¿¿
opt.encoding = 'utf-8'
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.confirm = true

-- ¿¿
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- ¿¿
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

-- ¿¿
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.textwidth = 120

-- ===========================
-- ¿¿¿¿
-- ===========================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ¿¿¿¿¿¿
autocmd("TextYankPost", {
    group = augroup("HighlightYank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

-- ¿¿¿¿¿¿¿
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

-- ¿¿¿¿¿¿
autocmd("BufWritePre", {
    group = augroup("AutoCreateDir", { clear = true }),
    callback = function(event)
        if event.match:match("^%w%w+://") then return end
        local file = vim.loop.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- ¿¿ q ¿¿¿¿¿¿¿¿
autocmd("FileType", {
    group = augroup("CloseWithQ", { clear = true }),
    pattern = { "help", "lspinfo", "man", "notify", "qf", "query" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- Python ¿¿¿¿¿¿¿¿
autocmd("BufWritePre", {
    group = augroup("AutoRemoveTrailingSpacesPy", { clear = true }),
    pattern = "*.py",
    command = ":%s/\\s\\+$//e",
})

-- ===========================
-- ¿¿¿¿ - ¿¿¿¿¿¿¿¿¿¿¿¿¿
-- ===========================

vim.diagnostic.config({
    virtual_text = {
        source = true,
        prefix = "¿",
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
        max_width = 120,
        max_height = 30,
        wrap = true,
        header = "",
        prefix = "",
    },
})

-- ¿¿¿¿¿¿¿¿ - ¿¿¿¿¿¿¿¿¿¿¿¿¿
autocmd({ "CursorHold", "CursorHoldI" }, {
    group = augroup("DiagnosticFloat", { clear = true }),
    callback = function()
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
})

-- ===========================
-- LSP ¿¿ - ¿¿¿¿¿¿¿¿¿
-- ===========================

require('neodev').setup()

local function get_capabilities()
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    -- ¿¿¿¿¿¿¿¿¿
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

    -- LSP ¿¿ - ¿¿¿¿¿¿¿
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

    -- ¿¿¿¿¿¿¿¿¿
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    
    -- ¿¿¿¿¿¿¿¿ - ¿¿¿ <leader>dd ¿¿¿ Neo-tree ¿¿
    vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, bufopts)
    
    -- ¿¿¿¿
    vim.keymap.set('n', '<leader>dl', function()
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
        for _, c in pairs(clients) do
            print("LSP Client:", c.name, "Root:", c.config.root_dir)
        end
    end, { buffer = bufnr, desc = "Show LSP info" })
end

-- Mason LSP ¿¿ - ¿¿ pylsp ¿¿¿¿¿¿¿¿¿¿
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
                            -- ¿¿¿¿ PEP ¿¿¿¿
                            pycodestyle = { 
                                enabled = true, 
                                maxLineLength = 120,
                                ignore = {"E501"}
                            },
                            pyflakes = { enabled = true },
                            autopep8 = { enabled = true },
                            yapf = { enabled = false },
                            isort = { enabled = true },
                            -- ¿¿ Jedi ¿¿¿¿¿¿¿¿¿¿
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
                        configurationSources = {"pycodestyle"},
                    },
                },
                -- ¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿
                root_dir = function(fname)
                    local util = require('lspconfig.util')
                    -- ¿¿¿¿¿¿¿¿¿¿
                    local root = util.root_pattern(
                        'pyproject.toml', 
                        'setup.py', 
                        'setup.cfg', 
                        'requirements.txt', 
                        'Pipfile',
                        'poetry.lock',
                        '.git'
                    )(fname)
                    
                    -- ¿¿¿¿¿¿¿¿¿¿¿¿
                    return root or util.path.dirname(fname)
                end,
                -- ¿¿¿¿¿¿¿
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
-- ¿¿¿¿
-- ===========================

local keymap = vim.keymap.set

-- ¿¿¿¿¿¿¿
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- ¿¿¿¿
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- ¿¿¿¿¿¿
keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- ¿¿¿¿
keymap({ "i", "x", "n", "s" }, "<C-s>", function()
    if vim.bo.modified then vim.cmd("write") end
end, { desc = "Save file" })

-- ¿¿¿¿¿
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

-- ¿¿¿¿
keymap("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
keymap("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Git ¿¿
keymap("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
keymap("n", "<leader>gc", "<cmd>Git commit --verbose<CR>", { desc = "Git commit" })

-- ¿¿¿¿¿
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

-- ¿¿¿¿
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

-- ¿¿¿¿¿¿¿
keymap("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })

-- ¿¿¿¿
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

-- ¿¿¿¿
keymap("n", "n", "nzzzv", { desc = "Next search result" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result" })

-- Tab ¿¿
keymap("n", "<Tab>", "gt", { desc = "Next tab" })
keymap("n", "<S-Tab>", "gT", { desc = "Previous tab" })
keymap("n", "<S-t>", "<cmd>tabnew<CR>", { desc = "New tab" })

-- ¿¿¿¿¿¿¿ - ¿¿¿¿¿¿
keymap("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
keymap("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
