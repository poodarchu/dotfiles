-- init.lua - 精简的 Neovim 配置
-- ====================================

-- 基础设置
vim.g.mapleader = '\\'
vim.g.maplocalleader = ','
vim.g.have_nerd_font = true -- 确保你的终端和字体设置支持Nerd Font

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
    -- 文件管理器
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = "v3.x",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
        cmd = "Neotree",
        keys = {
            { "<F3>",      "<cmd>Neotree toggle<cr>", desc = "Toggle NeoTree" },
            { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle NeoTree" },
            { "-",         "<cmd>Neotree reveal<cr>", desc = "Reveal current file in NeoTree" },
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
                    hide_by_name = { "node_modules", "__pycache__", ".git", ".DS_Store", "thumbs.db", "venv", ".venv" },
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
                local function map(mode, l, r, opts_param)
                    local opts = opts_param or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                map('n', ']h', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, { expr = true, desc = "Next Hunk" })

                map('n', '[h', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, { expr = true, desc = "Previous Hunk" })

                map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage hunk" })
                map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset hunk" })
                map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage buffer" })
                map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset buffer" })
                map('n', '<leader>hp', gs.preview_hunk, { desc = "Preview hunk" })
                map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = "Blame line" })

                map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
                    { desc = "Stage selected lines" })
                map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
                    { desc = "Reset selected lines" })
            end
        },
    },

    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        dependencies = { 'nvim-tree/nvim-web-devicons', 'morhetz/gruvbox' },
        opts = {
            options = { theme = 'gruvbox', globalstatus = true },
            extensions = { 'neo-tree' }, -- fugitive removed
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

    {
        'lukas-reineke/indent-blankline.nvim',
        event = { "BufReadPost", "BufNewFile" },
        main = "ibl",
        opts = {
            indent = { char = "│" },
            scope = { enabled = true },
            exclude = { filetypes = { "help", "alpha", "dashboard", "neo-tree", "lazy", "mason" } },
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

    {
        'nvim-telescope/telescope.nvim',
        version = false, -- Removing version = false as it's for specific use cases; can be added back if issues arise
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
            'nvim-telescope/telescope-ui-select.nvim',
            -- 'nvim-telescope/telescope-file-browser.nvim', -- REMOVED
            -- 'nvim-telescope/telescope-project.nvim', -- REMOVED
        },
        cmd = "Telescope",
        keys = function()
            local builtin = require('telescope.builtin')
            local keys = {
                { "<leader>ff", builtin.find_files, desc = "Find Files" },
                { "<leader>fg", builtin.live_grep, desc = "Live Grep" },
                { "<leader>fw", builtin.grep_string, desc = "Grep Word" },
                { "<leader>fb", builtin.buffers, desc = "Buffers" },
                { "<leader>fh", builtin.help_tags, desc = "Help Tags" },
                { "<leader>fr", builtin.oldfiles, desc = "Recent Files" },
                -- { "<leader>fc", builtin.commands, desc = "Commands" }, -- Less common
                -- { "<leader>fk", builtin.keymaps, desc = "Keymaps" }, -- Less common
                { "<leader>gf", builtin.git_files, desc = "Git Files" },
                { "<leader>gb", builtin.git_branches, desc = "Git Branches" },
                { "<leader>gC", builtin.git_commits, desc = "Git Commits (Telescope)" }, -- Distinct from Fugitive's original gC
                { "<leader>gt", builtin.git_status, desc = "Git Status (Telescope)" },
                { "<leader>ls", builtin.lsp_document_symbols, desc = "Document Symbols" },
                { "<leader>lS", builtin.lsp_workspace_symbols, desc = "Workspace Symbols" },
                { "<leader>ld", builtin.diagnostics, desc = "Diagnostics (List)" },
                -- { "<leader>fp", function() require('telescope').extensions.project.project({}) end, "Projects" }, -- REMOVED
                -- { "<leader>fe", function() require('telescope').extensions.file_browser.file_browser({}) end, "File Browser" }, -- REMOVED
                { "<leader>f/", builtin.current_buffer_fuzzy_find, desc = "Buffer Fuzzy Find" },
            }
            return keys
        end,
        config = function()
            local telescope = require('telescope')
            local actions = require('telescope.actions')

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
                        find_command = vim.fn.executable('rg') == 1 and
                            { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "--glob", "!**/venv/*", "--glob",
                                "!**/.venv/*" } or nil,
                    },
                    live_grep = {
                        additional_args = function()
                            return { "--hidden", "--glob", "!**/.git/*", "--glob", "!**/venv/*",
                                "--glob", "!**/.venv/*" }
                        end
                    },
                },
                extensions = {
                    fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
                    -- file_browser = { theme = "ivy", hijack_netrw = false }, -- REMOVED
                    -- project = { base_dirs = { '~/.config', }, hidden_files = true }, -- REMOVED
                    ['ui-select'] = { theme = "ivy" },
                },
            })

            for _, ext in ipairs({ 'fzf', 'ui-select' }) do -- project, file_browser removed
                pcall(telescope.load_extension, ext)
            end
        end,
    },

    {
        'numToStr/Comment.nvim',
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require('Comment').setup()
        end,
    },

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
                        "                 💻 Welcome to Neovim 💻                 ",
                        "",
                    },
                    shortcut = {
                        { desc = '󰊳 Update Plugins', group = 'Function', action = 'Lazy update', key = 'u' },
                        { desc = ' Find Files', group = 'Identifier', action = 'Telescope find_files', key = 'f' },
                        { desc = ' Live Grep', group = 'String', action = 'Telescope live_grep', key = 'g' },
                        -- { desc = ' Projects', group = 'Type', action = 'Telescope project', key = 'p' }, -- REMOVED
                        { desc = ' Recent Files', group = 'Constant', action = 'Telescope oldfiles', key = 'r' },
                        { desc = ' Config', group = 'Keyword', action = 'edit $MYVIMRC', key = 'c' },
                    },
                    packages = { enable = true },
                    project = { enable = false }, -- Disabled as telescope-project is removed; re-enable if you use another project manager
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

    { 'neovim/nvim-lspconfig', event = { "BufReadPre", "BufNewFile" } },
    { 'williamboman/mason.nvim', cmd = "Mason", opts = { ui = { border = "rounded" } } },
    'williamboman/mason-lspconfig.nvim',
    -- 'folke/neodev.nvim', -- REMOVED
    -- { 'j-hui/fidget.nvim', opts = {}, tag = "legacy" }, -- REMOVED

    {
        'saghen/blink.cmp',
        lazy = false,
        -- dependencies = 'rafamadriz/friendly-snippets', -- REMOVED dependency
        version = 'v0.*',
        opts = {
            keymap = {
                preset = 'default',
                ['<CR>'] = { 'accept', 'fallback' },
                ['<Tab>'] = { 'select_next', 'fallback' }, -- snippet_forward removed
                ['<S-Tab>'] = { 'select_prev', 'fallback' }, -- snippet_backward removed
                ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
            },
            appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = 'mono' },
            sources = { default = { 'lsp', 'path', 'buffer' } }, -- 'snippets' removed
            completion = {
                accept = { auto_brackets = { enabled = true } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                ghost_text = { enabled = true },
                menu = { border = 'rounded', scrolloff = 2, scrollbar = true },
            },
            signature = { enabled = true, window = { border = 'rounded' } },
        },
    },

    -- { -- stevearc/conform.nvim REMOVED
    -- },

    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { "BufReadPost", "BufNewFile" },
        -- dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' }, -- REMOVED dependency
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = { "bash", "c", "cpp", "html", "javascript", "json", "lua", "markdown",
                    "python", "query", "regex", "tsx", "typescript", "vim", "vimdoc", "yaml" },
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
                -- textobjects = { -- REMOVED
                -- },
            })
        end,
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            spec = {
                { "<leader>c", group = "Comment" }, -- Code Format removed
                { "<leader>f", group = "Find/File (Telescope)" },
                { "<leader>g", group = "Git/Gitsigns/Telescope Git" },
                { "<leader>h", group = "Git Hunks (Gitsigns)" },
                { "<leader>l", group = "LSP/Lazy" }, { "<leader>q", group = "Quit/Session" },
                { "<leader>w", group = "Windows" }, { "<leader>b", group = "Buffer" }, -- Breakpoint removed
                { "<leader>t", group = "Toggle/Terminal/Tabs" },
                { "<leader>d", group = "Diagnostics/Definition (LSP)" },
            },
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)
            wk.register({
                ["<leader>c"] = {
                    c = { function() require('Comment.api').toggle.linewise.current() end, "Toggle Comment Line" },
                    b = { function() require('Comment.api').toggle.blockwise.current() end, "Toggle Comment Block" },
                    -- f removed (format code)
                }
            }, { mode = "n", prefix = "" })
            wk.register({
                ["<leader>c"] = {
                    c = { function() require('Comment.api').toggle.linewise(vim.fn.visualmode()) end, "Toggle Comment Line (Visual)" },
                    b = { function() require('Comment.api').toggle.blockwise(vim.fn.visualmode()) end, "Toggle Comment Block (Visual)" },
                    -- f removed
                }
            }, { mode = "v", prefix = "" })
        end
    },

    {
        'akinsho/toggleterm.nvim',
        version = "*",
        keys = {
            { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal (Float)" },
            { "<C-\\>",      "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal (Float)" },
            -- { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle Terminal (Horizontal)" }, -- Less common
            -- { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>",   desc = "Toggle Terminal (Vertical)" }, -- Less common
        },
        opts = {
            direction = 'float',
            float_opts = { border = 'curved' },
            open_mapping = [[<c-\>]],
        },
    },

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
        rtp = { disabled_plugins = vim.g.disabled_plugins },
        cache = { enabled = true },
        reset_packpath = true,
    },
    checker = { enabled = true, notify = false, frequency = 3600 },
    change_detection = { enabled = true, notify = false },
    install = { missing = true, colorscheme = { "gruvbox" } },
})

local function setup_options()
    local opt = vim.opt

    opt.encoding = 'utf-8'
    opt.fileencoding = 'utf-8'
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
    opt.signcolumn = 'yes'
    opt.wrap = false
    opt.scrolloff = 8
    opt.sidescrolloff = 8
    opt.colorcolumn = '120'
    opt.termguicolors = true
    opt.mouse = 'a'
    opt.clipboard = 'unnamedplus'
    opt.splitbelow = true
    opt.splitright = true
    opt.laststatus = 3
    opt.showmode = false

    opt.completeopt = { 'menu', 'menuone', 'noselect' }
    opt.shortmess:append "c"
    opt.textwidth = 0

    if vim.fn.has("nvim-0.9") == 1 then
        opt.pumblend = 10
        opt.winblend = 10
    end

    vim.env.MYVIMRC = vim.fn.stdpath("config") .. "/init.lua"
end
setup_options()

local function setup_autocmds()
    local augroup = vim.api.nvim_create_augroup
    local autocmd = vim.api.nvim_create_autocmd

    local yank_group = augroup("HighlightYank", { clear = true })
    local lastloc_group = augroup("LastLoc", { clear = true })
    local autocreatedir_group = augroup("AutoCreateDir", { clear = true })
    local closeq_group = augroup("CloseWithQ", { clear = true })
    local trailing_spaces_group = augroup("AutoRemoveTrailingSpaces", { clear = true })

    autocmd("TextYankPost", {
        group = yank_group,
        callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
    })

    autocmd("BufReadPost", {
        group = lastloc_group,
        callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
        end,
    })

    autocmd("BufWritePre", {
        group = autocreatedir_group,
        pattern = "*",
        nested = true,
        callback = function(event)
            if event.match:match("^%w%w+://") then return end
            local file = vim.loop.fs_realpath(event.match) or event.match
            local dir = vim.fn.fnamemodify(file, ":p:h")
            if dir ~= "" and dir ~= "." and dir ~= vim.fn.fnamemodify(file, ":h") and vim.fn.isdirectory(dir) == 0 then
                pcall(vim.fn.mkdir, dir, "p")
            end
        end,
    })

    autocmd("FileType", {
        group = closeq_group,
        pattern = { "help", "lspinfo", "man", "notify", "qf", "query", "checkhealth", "mason", "lazy" },
        callback = function(event)
            vim.bo[event.buf].buflisted = false
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
        end,
    })

    autocmd("BufWritePre", {
        group = trailing_spaces_group,
        pattern = "*",
        callback = function()
            local excluded_filetypes = { "markdown", "diff", "gitcommit" }
            if vim.tbl_contains(excluded_filetypes, vim.bo.filetype) then
                return
            end
            local save_cursor = vim.fn.getpos(".")
            local save_winsize = vim.fn.winsaveview()
            pcall(function() vim.cmd([[%s/\s\+$//e]]) end)
            vim.fn.winrestview(save_winsize)
            vim.fn.setpos(".", save_cursor)
        end,
    })
end
setup_autocmds()

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
            active = true,
            text = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN]  = "",
                [vim.diagnostic.severity.INFO]  = "",
                [vim.diagnostic.severity.HINT]  = "",
            },
        },
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
end
setup_diagnostics()

local function setup_lsp()
    -- require('neodev').setup() -- REMOVED

    local function get_capabilities()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
        capabilities.textDocument.completion.completionItem.snippetSupport = true -- blink.cmp might handle this or ignore if no snippet engine
        return capabilities
    end

    local function on_attach(client, bufnr)
        local function map(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, noremap = true, silent = true, desc = "LSP: " .. desc })
        end

        map('gD', vim.lsp.buf.declaration, "Go to Declaration")
        map('<leader>d', vim.lsp.buf.definition, "Go to Definition")
        map('<leader>dt', vim.lsp.buf.type_definition, "Type Definition")

        map('K', vim.lsp.buf.hover, "Hover Documentation")
        map('gi', vim.lsp.buf.implementation, "Go to Implementation")
        map('<leader>cr', vim.lsp.buf.rename, "Rename Symbol")
        map('gr', vim.lsp.buf.references, "Find References")
        map('<C-k>', vim.lsp.buf.signature_help, "Signature Help")

        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action,
            { buffer = bufnr, noremap = true, silent = true, desc = "LSP: Code Action" })

        if client.supports_method("textDocument/formatting") then
            map("<leader>clf", function() vim.lsp.buf.format { async = true } end, "Format (LSP Fallback)")
        end
        -- map('<leader>dli', ..., "Show LSP Info") -- REMOVED (Less common)
    end

    require('mason-lspconfig').setup({
        ensure_installed = {
            'clangd',   -- C/C++
            'pyright',  -- Python (or pylsp if you prefer and install it)
            'bashls',   -- Bash
            'jsonls',   -- JSON
            'yamlls',   -- YAML
            'marksman', -- Markdown
            'lua_ls',   -- Lua (for Neovim config)
        },
        handlers = {
            function(server_name) -- Default handler
                require('lspconfig')[server_name].setup({
                    capabilities = get_capabilities(),
                    on_attach = on_attach,
                })
            end,
            ["lua_ls"] = function()
                require('lspconfig').lua_ls.setup({
                    capabilities = get_capabilities(),
                    on_attach = on_attach,
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            diagnostics = { globals = { 'vim' }, disable = { "missing-fields" } },
                            workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
                            telemetry = { enable = false },
                            completion = { callSnippet = "Replace" } -- Might not work fully without snippet engine
                        },
                    },
                })
            end,
            ["pyright"] = function() -- If using pylsp, you'd add a similar handler for it
                require('lspconfig').pyright.setup({
                    capabilities = get_capabilities(),
                    on_attach = on_attach,
                    settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "basic",
                                useLibraryCodeForTypes = true,
                                autoSearchPaths = true,
                                diagnosticMode = "workspace",
                            }
                        }
                    },
                })
            end,
        },
    })
end
setup_lsp()

local function setup_keymaps()
    local keymap = vim.keymap.set

    keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'",
        { expr = true, silent = true, desc = "Move down (visual lines)" })
    keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'",
        { expr = true, silent = true, desc = "Move up (visual lines)" })
    keymap("n", "<leader>y", "\"+y", { desc = "Yank to system clipboard" })
    keymap("v", "<leader>y", "\"+y", { desc = "Yank selection to system clipboard" })
    keymap("n", "<leader>p", "\"+p", { desc = "Paste from system clipboard (after cursor)" })
    keymap("n", "<leader>P", "\"+P", { desc = "Paste from system clipboard (before cursor)" })

    keymap("n", "<C-h>", "<C-w>h", { desc = "Navigate window left" })
    keymap("n", "<C-j>", "<C-w>j", { desc = "Navigate window down" })
    keymap("n", "<C-k>", "<C-w>k", { desc = "Navigate window up" })
    keymap("n", "<C-l>", "<C-w>l", { desc = "Navigate window right" })
    keymap("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
    keymap("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
    keymap("n", "<leader>wc", "<cmd>close<CR>", { desc = "Close current window" })
    keymap("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })

    keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear search highlight" })
    keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>write<CR><esc>", { desc = "Save file" })
    keymap("v", "<", "<gv", { desc = "Decrease indent" })
    keymap("v", ">", ">gv", { desc = "Increase indent" })

    keymap("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })
    keymap("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "Lazy Update" })
    -- keymap("n", "<leader>li", "<cmd>Lazy install<cr>", { desc = "Lazy Install" }) -- REMOVED
    -- keymap("n", "<leader>lx", "<cmd>Lazy clean<cr>", { desc = "Lazy Clean" }) -- REMOVED
    keymap("n", "<leader>lsync", "<cmd>Lazy sync<cr>", { desc = "Lazy Sync" })

    -- Fugitive keymaps REMOVED
    -- <leader>gs, <leader>gC, <leader>ga, <leader>gp, <leader>gl

    keymap("n", "<leader>bd", function()
        local current_buf = vim.api.nvim_get_current_buf()
        if vim.bo[current_buf].modified then
            local choice = vim.fn.confirm("Buffer has unsaved changes. Save before closing?", "&Yes\n&No\n&Cancel", 1,
                "Warning")
            if choice == 1 then
                vim.cmd("write")
                vim.cmd("bdelete")
            elseif choice == 2 then
                vim.cmd("bdelete!")
            end
        else
            vim.cmd("bdelete")
        end
    end, { desc = "Delete current buffer" })
    -- keymap("n", "<leader>bda", ...) -- REMOVED (Delete all other buffers)

    keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" }) -- Kept <S-h>/<S-l> set
    keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
    -- keymap("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous Buffer" }) -- REMOVED (duplicate)
    -- keymap("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" }) -- REMOVED (duplicate)

    -- Python breakpoint toggle keymaps REMOVED
    -- <leader>bb, <F9>

    keymap("n", "<leader>de", function() vim.diagnostic.open_float(nil, { scope = "cursor", border = 'rounded' }) end,
        { desc = "Show diagnostics at cursor" })
    keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
    keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
    -- keymap("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "Previous diagnostic (alias)" }) -- REMOVED
    -- keymap("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "Next diagnostic (alias)" }) -- REMOVED
    keymap("n", "<leader>dq", function() vim.diagnostic.setqflist() end, { desc = "Diagnostics to Quickfix list" })

    keymap("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Terminal: Enter Normal Mode" })

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

    keymap("n", "n", "nzzzv", { desc = "Next search result (centered)" })
    keymap("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

    keymap("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
    keymap("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close current tab" })
    keymap("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
    keymap("n", "<S-PageDown>", "<cmd>tabnext<CR>", { desc = "Next tab" })
    keymap("n", "<S-PageUp>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
end
setup_keymaps()
