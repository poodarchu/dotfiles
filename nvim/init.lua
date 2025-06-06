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
		},
		opts = {
			close_if_last_window = false,  -- 改为 false，避免自动关闭
			enable_git_status = true,
			popup_border_style = "rounded",
			window = { 
				position = "left", 
				width = function()
					-- 检查是否有参数传入且为文件夹
					local args = vim.fn.argv()
					if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
						return "100%"  -- 全屏宽度
					else
						return 35  -- 默认宽度
					end
				end,
				mapping_options = {
					noremap = true,
					nowait = true,
				},
				mappings = {
					["<space>"] = "none",
					["<cr>"] = "open",
					["o"] = "open",
					["S"] = "open_split",
					["s"] = "open_vsplit",
					["t"] = "open_tabnew",
					["C"] = "close_node",
					["z"] = "close_all_nodes",
					["R"] = "refresh",
					["a"] = "add",
					["A"] = "add_directory",
					["d"] = "delete",
					["r"] = "rename",
					["y"] = "copy_to_clipboard",
					["x"] = "cut_to_clipboard",
					["p"] = "paste_from_clipboard",
					["c"] = "copy",
					["m"] = "move",
					["q"] = "close_window",
					["?"] = "show_help",
					["<"] = "prev_source",
					[">"] = "next_source",
				},
			},
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
						vim.cmd("normal! ]c")
						return
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
				end, { desc = "Next Hunk" })

				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd("normal! [c")
						return
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
				end, { desc = "Previous Hunk" })

				map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
				map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
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

			-- 自动补全颜色配置
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
			ts_config = { lua = { "string" } },
		},
	},

	-- Toggle 注释插件
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPost", "BufNewFile" },
		keys = {
			-- <leader>cc 快捷键
			{ "<leader>cc", function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle comment", mode = "n" },
			{ "<leader>cc", function() require("Comment.api").toggle.linewise(vim.fn.visualmode()) end, desc = "Toggle comment", mode = "v" },
			-- <leader>c<space> 快捷键
			{ "<leader>c<space>", function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle comment", mode = "n" },
			{ "<leader>c<space>", function() require("Comment.api").toggle.linewise(vim.fn.visualmode()) end, desc = "Toggle comment", mode = "v" },
		},
		config = function()
			require("Comment").setup()
		end,
	},

	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
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
                        "                  💻 Welcome to Neovim 💻                  ",
                        "",
                    },
                    shortcut = {
                        { desc = '󰊳 Update Plugins', group = 'Function', action = 'Lazy update', key = 'u' },
                        { desc = ' Find Files', group = 'Identifier', action = 'Telescope find_files', key = 'f' },
                        { desc = ' Live Grep', group = 'String', action = 'Telescope live_grep', key = 'g' },
                        { desc = ' Projects', group = 'Type', action = 'Telescope project', key = 'p' },
                        { desc = ' Recent Files', group = 'Constant', action = 'Telescope oldfiles', key = 'r' },
                        { desc = ' Config', group = 'Keyword', action = 'edit $MYVIMRC', key = 'c' },
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

	-- LSP Setup (仅支持 C++ 和 Python)
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
				"black",
				"isort",
				"clang-format",
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
			appearance = { 
				use_nvim_cmp_as_default = true, 
				nerd_font_variant = "mono",
			},
			sources = { default = { "lsp", "path", "buffer" } },
			completion = {
				accept = { auto_brackets = { enabled = true } },
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = true },
				menu = { 
					border = "rounded", 
					scrolloff = 2, 
					scrollbar = true,
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon", "kind", gap = 1 },
						},
					},
				},
			},
			signature = { enabled = true, window = { border = "rounded" } },
		},
	},

	-- 代码格式化 (仅 C++ 和 Python)
	{
		"stevearc/conform.nvim",
		event = "VeryLazy",
		cmd = { "ConformInfo" },
		opts = {
			formatters_by_ft = {
				python = { "isort", "black" },
				c = { "clang-format" },
				cpp = { "clang-format" },
			},
		},
		init = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
		config = function(_, opts)
			require("conform").setup(opts)

			-- 创建 :fm 命令用于手动格式化
			vim.api.nvim_create_user_command("Fm", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, { desc = "Format code" })
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"c",
					"cpp",
					"python",
					"lua",
					"vim",
					"vimdoc",
				},
				auto_install = true,
				highlight = { enable = true, additional_vim_regex_highlighting = false },
				indent = { enable = true },
			})
		end,
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			spec = {
				{ "<leader>h", group = "Git Hunks (Gitsigns)" },
				{ "<leader>l", group = "LSP/Lazy" },
				{ "<leader>b", group = "Buffer/Breakpoint" },
				{ "<leader>c", group = "Code/Comment" },
				{ "<leader>d", group = "Diagnostics/Definition (LSP)" },
			},
		},
		config = function(_, opts)
			require("which-key").setup(opts)
		end,
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

	-- 自动删除行末空格 (仅针对 C++ 和 Python)
	autocmd("BufWritePre", {
		group = augroup("AutoRemoveTrailingSpaces", { clear = true }),
		pattern = { "*.cpp", "*.cc", "*.cxx", "*.c", "*.h", "*.hpp", "*.py" },
		callback = function()
			local save_cursor = vim.fn.getpos(".")
			local save_winsize = vim.fn.winsaveview()
			pcall(function()
				vim.cmd([[%s/\s\+$//e]])
			end)
			vim.fn.winrestview(save_winsize)
			vim.fn.setpos(".", save_cursor)
		end,
	})

	-- 自动显示诊断 (优化版本)
	autocmd("CursorHold", {
		group = augroup("AutoShowDiagnosticsOnCursorHold", { clear = true }),
		pattern = { "*.cpp", "*.cc", "*.cxx", "*.c", "*.h", "*.hpp", "*.py" },
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

	-- 打开文件夹时自动启动全屏 neo-tree
	autocmd("VimEnter", {
		group = augroup("AutoOpenFullScreenNeoTree", { clear = true }),
		callback = function()
			local args = vim.fn.argv()
			if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
				-- 切换到目标目录
				vim.cmd("cd " .. vim.fn.fnameescape(args[1]))
				
				-- 关闭当前的默认缓冲区和 dashboard
				local current_buf = vim.api.nvim_get_current_buf()
				vim.cmd("enew")
				if vim.api.nvim_buf_is_valid(current_buf) then
					vim.api.nvim_buf_delete(current_buf, { force = true })
				end
				
				-- 打开全屏 neo-tree
				vim.schedule(function()
					vim.cmd("Neotree show")
				end)
			end
		end,
	})

	-- 当从 neo-tree 打开文件时自动关闭 neo-tree (仅在全屏模式下)
	autocmd("BufEnter", {
		group = augroup("AutoCloseNeoTreeOnFileOpen", { clear = true }),
		callback = function()
			local buf_name = vim.api.nvim_buf_get_name(0)
			local is_regular_file = buf_name ~= "" and not buf_name:match("neo%-tree") and vim.fn.filereadable(buf_name) == 1
			
			if is_regular_file then
				-- 检查是否是通过文件夹参数启动的
				local args = vim.fn.argv()
				if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
					-- 查找并关闭 neo-tree 窗口
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						local name = vim.api.nvim_buf_get_name(buf)
						if name:match("neo%-tree") then
							vim.api.nvim_win_close(win, false)
							break
						end
					end
				end
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

-- LSP 配置 (仅 C++ 和 Python)
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

		-- LSP 跳转快捷键
		map("<C-]>", vim.lsp.buf.definition, "Go to Definition")
		map("gd", vim.lsp.buf.definition, "Go to Definition")
		map("<leader>dt", vim.lsp.buf.type_definition, "Type Definition")
		map("<leader>di", vim.lsp.buf.implementation, "Go to Implementation")
		map("<leader>dr", vim.lsp.buf.references, "Find References")
		map("<leader>dd", vim.lsp.buf.declaration, "Go to Declaration")

		map("K", vim.lsp.buf.hover, "Hover Documentation")
		map("<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
		map("gK", vim.lsp.buf.signature_help, "Signature Help")

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

	local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
	if not ok then
		vim.notify("mason-lspconfig not found", vim.log.levels.ERROR)
		return
	end

	mason_lspconfig.setup({
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

-- Breakpoint 功能 (仅 C++ 和 Python)
local function setup_breakpoint()
	-- 插入 breakpoint 函数 (在当前行上方添加)
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
			-- 在当前行上方插入断点 (line - 1)
			vim.fn.append(line - 1, indent_str .. breakpoint_line)
			vim.notify("断点已插入: " .. breakpoint_line, vim.log.levels.INFO)
		else
			vim.notify("不支持的文件类型: " .. filetype, vim.log.levels.WARN)
		end
	end

	-- 智能切换 breakpoint
	local function toggle_breakpoint()
		local line = vim.api.nvim_get_current_line()
		local filetype = vim.bo.filetype

		-- 检查当前行是否包含断点
		local has_breakpoint = false
		if filetype == "python" and line:match("breakpoint()") then
			has_breakpoint = true
		elseif (filetype == "c" or filetype == "cpp") and line:match("raise%(SIGTRAP%)") then
			has_breakpoint = true
		end

		if has_breakpoint then
			-- 删除当前行的断点
			vim.cmd("delete")
			vim.notify("断点已移除", vim.log.levels.INFO)
		else
			-- 检查上一行是否是断点
			local current_line_num = vim.fn.line(".")
			if current_line_num > 1 then
				local prev_line = vim.fn.getline(current_line_num - 1)
				local prev_has_breakpoint = false
				if filetype == "python" and prev_line:match("breakpoint()") then
					prev_has_breakpoint = true
				elseif (filetype == "c" or filetype == "cpp") and prev_line:match("raise%(SIGTRAP%)") then
					prev_has_breakpoint = true
				end

				if prev_has_breakpoint then
					-- 删除上一行的断点
					vim.cmd((current_line_num - 1) .. "delete")
					vim.notify("断点已移除", vim.log.levels.INFO)
					return
				end
			end
			-- 插入断点
			insert_breakpoint()
		end
	end

	-- 移除所有断点
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

	-- 键位映射
	vim.keymap.set("n", "<leader>bb", toggle_breakpoint, { desc = "Toggle breakpoint" })
	vim.keymap.set("n", "<leader>cb", remove_all_breakpoints, { desc = "Remove all breakpoints" })
end

-- 键位映射配置 (精简版)
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

	-- 基础编辑
	keymap({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear search highlight" })
	keymap({ "i", "x", "n", "s" }, "<C-s>", "<cmd>write<CR><esc>", { desc = "Save file" })
	keymap("v", "<", "<gv", { desc = "Decrease indent" })
	keymap("v", ">", ">gv", { desc = "Increase indent" })

	-- 窗口导航
	keymap("n", "<C-h>", "<C-w>h", { desc = "Navigate window left" })
	keymap("n", "<C-j>", "<C-w>j", { desc = "Navigate window down" })
	keymap("n", "<C-l>", "<C-w>l", { desc = "Navigate window right" })

	-- 缓冲区导航
	keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
	keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

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

	-- 诊断
	keymap("n", "<leader>de", function()
		vim.diagnostic.open_float(nil, { scope = "cursor", border = "rounded", focusable = true })
	end, { desc = "Show diagnostics at cursor" })
	keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
	keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

	-- Lazy 插件管理
	keymap("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })

	-- 搜索结果居中
	keymap("n", "n", "nzzzv", { desc = "Next search result (centered)" })
	keymap("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
end

-- 初始化所有配置
setup_options()
setup_autocmds()
setup_diagnostics()
setup_lsp()
setup_breakpoint()
setup_keymaps()
