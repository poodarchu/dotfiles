-- 基础设置
vim.g.mapleader = "\\"
vim.g.maplocalleader = ","
vim.g.have_nerd_font = true

-- 禁用内置插件
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
	"matchparen",
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

-- 插件配置
local plugins = {
	-- 文件管理器
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
				bind_to_cwd = false,
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

	-- Git 集成
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

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons", "morhetz/gruvbox" },
		opts = {
			options = { theme = "gruvbox", globalstatus = true },
			extensions = { "neo-tree", "mason" },
		},
	},

	{
		"morhetz/gruvbox",
		priority = 1000,
		init = function()
			vim.g.gruvbox_contrast_dark = "medium"
			vim.g.gruvbox_improved_strings = 1
			vim.g.gruvbox_improved_warnings = 1
		end,
		config = function()
			vim.cmd.colorscheme("gruvbox")

			-- 修改 treesitter 配色以匹配 gruvbox
			local colors = {
				fg1 = "#ebdbb2",
				green = "#b8bb26",
			}

			vim.api.nvim_set_hl(0, "@variable", { fg = colors.fg1 })
			vim.api.nvim_set_hl(0, "@variable.member", { fg = colors.fg1 })
			vim.api.nvim_set_hl(0, "@property", { fg = colors.fg1 })

			-- 字符串相关高亮
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
		end,
	},

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

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
			ts_config = { lua = { "string" }, javascript = { "template_string" }, java = false },
		},
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-ui-select.nvim",
		},
		cmd = "Telescope",
		keys = {
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live Grep",
			},
			{
				"<leader>fw",
				function()
					require("telescope.builtin").grep_string()
				end,
				desc = "Grep Word",
			},
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "Help Tags",
			},
			{
				"<leader>fr",
				function()
					require("telescope.builtin").oldfiles()
				end,
				desc = "Recent Files",
			},
			{
				"<leader>\\f",
				function()
					require("telescope.builtin").git_files()
				end,
				desc = "Git Files",
			},
			{
				"<leader>\\b",
				function()
					require("telescope.builtin").git_branches()
				end,
				desc = "Git Branches",
			},
			{
				"<leader>\\c",
				function()
					require("telescope.builtin").git_commits()
				end,
				desc = "Git Commits",
			},
			{
				"<leader>\\s",
				function()
					require("telescope.builtin").git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>ls",
				function()
					require("telescope.builtin").lsp_document_symbols()
				end,
				desc = "Document Symbols",
			},
			{
				"<leader>lS",
				function()
					require("telescope.builtin").lsp_workspace_symbols()
				end,
				desc = "Workspace Symbols",
			},
			{
				"<leader>ld",
				function()
					require("telescope.builtin").diagnostics()
				end,
				desc = "Diagnostics (List)",
			},
			{
				"<leader>f/",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find()
				end,
				desc = "Buffer Fuzzy Find",
			},
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

	{
		"numToStr/Comment.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("Comment").setup()
		end,
	},

	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("dashboard").setup({
				theme = "hyper",
				config = {
					header = {
						"██████╗ ███████╗███╗    ██╗      ██╗██╗███╗   ██╗     ███████╗██╗  ██╗██╗   ██╗",
						"██╔══██╗██╔════╝████╗   ██║      ██║██║████╗  ██║     ╚══███╔╝██║  ██║██║   ██║",
						"██████╔╝█████╗  ██╔██╗ ██║      ██║██║██╔██╗ ██║       ███╔╝ ███████║██║   ██║",
						"██╔══██╗██╔══╝  ██║╚██╗██║██    ██║██║██║╚██╗██║      ███╔╝  ██╔══██║██║   ██║",
						"██████╔╝███████╗██║ ╚████║╚█████╔╝██║██║ ╚████║     ███████╗██║  ██║╚██████╔╝",
						"╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚════╝ ╚═╝╚═╝  ╚═══╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ",
						"",
						"                      💻 Welcome to Neovim 💻                      ",
					},
					shortcut = {
						{ desc = "󰊳 Update Plugins", group = "Function", action = "Lazy update", key = "u" },
						{ desc = " Find Files", group = "Identifier", action = "Telescope find_files", key = "f" },
						{ desc = " Live Grep", group = "String", action = "Telescope live_grep", key = "g" },
						{ desc = " Recent Files", group = "Constant", action = "Telescope oldfiles", key = "r" },
						{ desc = " Config", group = "Keyword", action = "edit $MYVIMRC", key = "c" },
					},
					packages = { enable = true },
					project = { enable = false },
					mru = { limit = 10, icon = "󰋚", label = " Recent Files", cwd_only = false },
				},
			})
		end,
	},

	-- LSP Setup
	{ "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = { ui = { border = "rounded" } },
		config = function(_, opts)
			require("mason").setup(opts)

			local ensure_installed = {
				"clangd",
				"pyright",
				"stylua",
				"black",
				"isort",
				"clang-format",
				"prettier",
				"shfmt",
			}

			local mr = require("mason-registry")
			for _, tool in ipairs(ensure_installed) do
				local p = mr.get_package(tool)
				if not p:is_installed() then
					p:install()
				end
			end
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim" },
		opts = { ensure_installed = { "clangd", "pyright" } },
	},

	{
		"saghen/blink.cmp",
		lazy = false,
		version = "v0.*",
		opts = {
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			},
			appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono" },
			sources = { default = { "lsp", "path", "buffer" } },
			completion = {
				accept = { auto_brackets = { enabled = true } },
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = true },
				menu = { border = "rounded", scrolloff = 2, scrollbar = true },
			},
			signature = { enabled = true, window = { border = "rounded" } },
		},
	},

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
			format_on_save = {
				timeout_ms = 700,
				lsp_fallback = true,
			},
		},
		init = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},

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
				{ "<leader>b", group = "Buffer" },
				{ "<leader>t", group = "Toggle/Terminal/Tabs" },
				{ "<leader>d", group = "Diagnostics/Definition (LSP)" },
			},
		},
		config = function(_, opts)
			require("which-key").setup(opts)
		end,
	},

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
		rtp = { disabled_plugins = disabled_plugins },
		cache = { enabled = true },
		reset_packpath = true,
	},
	checker = { enabled = true, notify = false, frequency = 3600 },
	change_detection = { enabled = true, notify = false },
	install = { missing = true, colorscheme = { "gruvbox" } },
})

-- 基础选项配置
local function setup_options()
	local opt = vim.opt

	-- 文件编码
	opt.encoding = "utf-8"
	opt.fileencoding = "utf-8"

	-- 备份和撤销
	opt.backup = false
	opt.swapfile = false
	opt.undofile = true
	local undodir_path = vim.fn.stdpath("data") .. "/undodir"
	opt.undodir = undodir_path
	if vim.fn.isdirectory(undodir_path) == 0 then
		pcall(vim.fn.mkdir, undodir_path, "p")
	end

	-- 响应时间
	opt.updatetime = 250
	opt.timeoutlen = 300
	opt.confirm = true

	-- 缩进
	opt.tabstop = 4
	opt.shiftwidth = 4
	opt.softtabstop = 4
	opt.expandtab = true
	opt.autoindent = true
	opt.smartindent = true

	-- 搜索
	opt.hlsearch = true
	opt.incsearch = true
	opt.ignorecase = true
	opt.smartcase = true

	-- 界面
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

	-- 补全
	opt.completeopt = { "menu", "menuone", "noselect" }
	opt.shortmess:append("c")

	if vim.fn.has("nvim-0.9") == 1 then
		opt.pumblend = 10
		opt.winblend = 10
	end

	vim.env.MYVIMRC = vim.fn.stdpath("config") .. "/init.lua"
end

-- 自动命令配置
local function setup_autocmds()
	local augroup = vim.api.nvim_create_augroup
	local autocmd = vim.api.nvim_create_autocmd

	-- 高亮复制内容
	autocmd("TextYankPost", {
		group = augroup("HighlightYank", { clear = true }),
		callback = function()
			vim.highlight.on_yank({ timeout = 200 })
		end,
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

	-- Q 关闭特殊窗口
	autocmd("FileType", {
		group = augroup("CloseWithQ", { clear = true }),
		pattern = { "help", "lspinfo", "man", "notify", "qf", "query", "checkhealth", "mason", "lazy" },
		callback = function(event)
			vim.bo[event.buf].buflisted = false
			vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
		end,
	})

	-- 自动删除行末空格
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

	-- 自动显示诊断
	autocmd("CursorHold", {
		group = augroup("AutoShowDiagnosticsOnCursorHold", { clear = true }),
		pattern = "*",
		callback = function()
			local current_buf = vim.api.nvim_get_current_buf()
			local cursor_pos = vim.api.nvim_win_get_cursor(0)
			local current_line_0_indexed = cursor_pos[1] - 1

			local diagnostics_on_line = vim.diagnostic.get(current_buf, {
				lnum = current_line_0_indexed,
				severity = { min = vim.diagnostic.severity.WARN },
			})

			if #diagnostics_on_line > 0 then
				vim.diagnostic.open_float(nil, {
					scope = "line",
					focusable = false,
				})
			end
		end,
	})
end

-- 诊断配置
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

-- LSP 配置
local function setup_lsp()
	local function get_capabilities()
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		return capabilities
	end

	local function on_attach(client, bufnr)
		local function map(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = bufnr, noremap = true, silent = true, desc = "LSP: " .. desc })
		end

		-- LSP 跳转快捷键改为 Ctrl 开头
		map("<C-]>", vim.lsp.buf.definition, "Go to Definition")
		map("<C-w>]", function()
			vim.cmd("split | lua vim.lsp.buf.definition()")
		end, "Go to Definition (Split)")
		map("<C-w><C-]>", function()
			vim.cmd("vsplit | lua vim.lsp.buf.definition()")
		end, "Go to Definition (Vsplit)")
		map("<C-t>", "<C-o>", "Jump back")
		map("<leader>dt", vim.lsp.buf.type_definition, "Type Definition")
		map("<leader>di", vim.lsp.buf.implementation, "Go to Implementation")
		map("<leader>dr", vim.lsp.buf.references, "Find References")
		map("<leader>dd", vim.lsp.buf.declaration, "Go to Declaration")

		map("K", vim.lsp.buf.hover, "Hover Documentation")
		map("<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
		map("<C-k>", vim.lsp.buf.signature_help, "Signature Help")

		vim.keymap.set(
			{ "n", "v" },
			"<leader>ca",
			vim.lsp.buf.code_action,
			{ buffer = bufnr, noremap = true, silent = true, desc = "LSP: Code Action" }
		)

		if client.supports_method("textDocument/formatting") then
			map("<leader>cf", function()
				vim.lsp.buf.format({ async = true })
			end, "Format (LSP)")
		end
	end

	require("mason-lspconfig").setup({
		ensure_installed = { "clangd", "pyright" },
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
		},
	})
end

-- 键位映射配置
local function setup_keymaps()
	local keymap = vim.keymap.set

	-- 基础移动
	keymap(
		{ "n", "x" },
		"j",
		"v:count == 0 ? 'gj' : 'j'",
		{ expr = true, silent = true, desc = "Move down (visual lines)" }
	)
	keymap(
		{ "n", "x" },
		"k",
		"v:count == 0 ? 'gk' : 'k'",
		{ expr = true, silent = true, desc = "Move up (visual lines)" }
	)

	-- 系统剪贴板
	keymap("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
	keymap("v", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
	keymap("n", "<leader>p", '"+p', { desc = "Paste from system clipboard (after cursor)" })
	keymap("n", "<leader>P", '"+P', { desc = "Paste from system clipboard (before cursor)" })

	-- 窗口导航
	keymap("n", "<C-h>", "<C-w>h", { desc = "Navigate window left" })
	keymap("n", "<C-j>", "<C-w>j", { desc = "Navigate window down" })
	keymap("n", "<C-k>", "<C-w>k", { desc = "Navigate window up" })
	keymap("n", "<C-l>", "<C-w>l", { desc = "Navigate window right" })
	keymap("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
	keymap("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
	keymap("n", "<leader>wc", "<cmd>close<CR>", { desc = "Close current window" })
	keymap("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })

	-- 基础编辑
	keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear search highlight" })
	keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>write<CR><esc>", { desc = "Save file" })
	keymap("v", "<", "<gv", { desc = "Decrease indent" })
	keymap("v", ">", ">gv", { desc = "Increase indent" })

	-- Lazy 插件管理
	keymap("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })
	keymap("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "Lazy Update Plugins" })

	-- 缓冲区管理
	keymap("n", "<leader>bd", function()
		local current_buf = vim.api.nvim_get_current_buf()
		if vim.bo[current_buf].modified then
			local choice =
				vim.fn.confirm("Buffer has unsaved changes. Save before closing?", "&Yes\n&No\n&Cancel", 1, "Warning")
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

	-- 诊断
	keymap("n", "<leader>de", function()
		vim.diagnostic.open_float(nil, { scope = "cursor", border = "rounded", focusable = true })
	end, { desc = "Show diagnostics at cursor" })
	keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
	keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
	keymap("n", "<leader>dq", function()
		vim.diagnostic.setqflist()
	end, { desc = "Diagnostics to Quickfix list" })

	-- 终端
	keymap("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Terminal: Enter Normal Mode" })

	-- 退出
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

	-- 搜索结果居中
	keymap("n", "n", "nzzzv", { desc = "Next search result (centered)" })
	keymap("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

	-- 标签页
	keymap("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
	keymap("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close current tab" })
	keymap("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
	keymap("n", "<S-PageDown>", "<cmd>tabnext<CR>", { desc = "Next tab" })
	keymap("n", "<S-PageUp>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
end

-- 初始化所有配置
setup_options()
setup_autocmds()
setup_diagnostics()
setup_lsp()
setup_keymaps()
