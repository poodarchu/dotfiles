# Neovim 配置功能指南

欢迎使用这份为您定制的 Neovim 配置功能指南！本文档旨在帮助您理解并充分利用当前配置中的各项强大功能，提升编码效率和体验。

## 安装 (Installation)

在您开始使用此 Neovim 配置之前，请确保您的系统满足以下条件并按照步骤进行设置。

### 1. 先决条件 (Prerequisites)

* **Neovim**: 版本 **> 0.11** (建议使用 Nightly 版本或更新版本，以确保所有功能正常工作)。
* **Node.js**: 版本 **> 20.x**。一些 LSP 服务器和工具依赖 Node.js。
* **Git**: 用于插件管理和版本控制。
* **C 编译器**: 如 GCC 或 Clang。用于编译 Treesitter 解析器和 Telescope 的 fzf-native 等。
* **`make`**: 构建工具，fzf-native 等需要。
* **`ripgrep` (rg)**: 强烈推荐。Telescope 用它来提供更快速的文件内容搜索。
* **Nerd Font**: 您需要安装一款 Nerd Font 并在您的终端模拟器中设置为默认字体，以便正确显示图标和符号 (配置中已设置 `vim.g.have_nerd_font = true`)。

您可以访问以下链接获取上述工具：
* Neovim: [https://github.com/neovim/neovim/wiki/Installing-Neovim](https://github.com/neovim/neovim/wiki/Installing-Neovim)
* Node.js: [https://nodejs.org/](https://nodejs.org/)
* Git: [https://git-scm.com/downloads](https://git-scm.com/downloads)
* Ripgrep: [https://github.com/BurntSushi/ripgrep#installation](https://github.com/BurntSushi/ripgrep#installation)
* Nerd Fonts: [https://www.nerdfonts.com/font-downloads](https://www.nerdfonts.com/font-downloads)

### 2. 配置步骤 (Configuration Steps)

1.  **备份现有配置 (重要)**:
    如果您之前有 Neovim 配置，请务必备份。通常位于：
    * Linux/macOS: `~/.config/nvim/`
    * Windows: `%LOCALAPPDATA%\nvim\`
    您可以将其重命名，例如 `mv ~/.config/nvim ~/.config/nvim.bak`。

2.  **放置配置文件**:
    此配置的核心文件是 `init.lua`。您需要将这个 `init.lua` 文件放置到 Neovim 的配置目录下。
    * 对于 Linux 和 macOS 用户，标准路径是：
        ```bash
        mkdir -p ~/.config/nvim
        # 假设您的 init.lua 文件在当前目录
        cp path/to/your/init.lua ~/.config/nvim/init.lua
        ```
        请将 `path/to/your/init.lua` 替换为您的 `init.lua` 文件的实际路径。如果您的配置包含多个文件（例如 `lua/` 目录下的模块），请确保整个结构被正确复制到 `~/.config/nvim/`下。

    * 对于 Windows 用户，路径通常是：
        `C:\Users\<YourUser>\AppData\Local\nvim\init.lua`
        确保 `%LOCALAPPDATA%\nvim` 目录存在。

3.  **启动 Neovim 并初始化**:
    * 第一次启动 Neovim 时：
        ```bash
        nvim
        ```
    * `lazy.nvim` (插件管理器) 会自动进行引导。它会首先克隆 `lazy.nvim` 自身到指定路径 (通常是 `~/.local/share/nvim/lazy/lazy.nvim`)。
    * 随后，`lazy.nvim` 会读取您的 `init.lua` 中的插件列表，并自动开始下载和安装所有列出的插件。您会在屏幕上看到安装进度。
    * 请耐心等待所有插件安装完成。某些插件（如 `nvim-treesitter` 的解析器，`telescope-fzf-native`）可能需要编译，这会花费一些时间。

4.  **安装后检查**:
    * 插件安装完毕后，重启 Neovim。
    * 如果遇到任何问题，可以运行 `:Lazy` 命令打开 `lazy.nvim` 的管理界面，查看插件状态，或使用 `:Lazy sync`、`:Lazy update` 等命令进行同步或更新。
    * 确保所有 LSP 服务器、格式化器和 Linters 都已通过 `:Mason` 正确安装 (您的配置会自动尝试安装 `ensure_installed` 列表中的工具)。

现在，您的 Neovim 环境应该已经配置完毕并可以使用了！

## 目录
1.  [核心理念与基础设置](#核心理念与基础设置)
2.  [插件管理 (Lazy.nvim)](#插件管理-lazy-nvim)
3.  [用户界面与体验 (UI & UX)](#用户界面与体验-ui--ux)
    * [主题与颜色 (Gruvbox)](#主题与颜色-gruvbox)
    * [状态栏 (Lualine)](#状态栏-lualine)
    * [启动屏 (Dashboard-nvim)](#启动屏-dashboard-nvim)
    * [文件浏览器 (Neo-tree)](#文件浏览器-neo-tree)
    * [缩进指示 (Indent-blankline)](#缩进指示-indent-blankline)
    * [通知系统 (Nvim-notify)](#通知系统-nvim-notify)
4.  [核心编辑增强 (Core Editing Enhancements)](#核心编辑增强-core-editing-enhancements)
    * [自动括号/引号配对 (Nvim-autopairs)](#自动括号引号配对-nvim-autopairs)
    * [注释切换 (Comment.nvim)](#注释切换-comment-nvim)
    * [模糊搜索与操作 (Telescope.nvim)](#模糊搜索与操作-telescope-nvim)
5.  [代码开发与 LSP (Code Development & LSP)](#代码开发与-lsp-code-development--lsp)
    * [LSP 环境管理 (Mason & Mason-lspconfig)](#lsp-环境管理-mason--mason-lspconfig)
    * [LSP 核心功能 (Nvim-lspconfig)](#lsp-核心功能-nvim-lspconfig)
    * [代码补全 (Blink.cmp)](#代码补全-blink-cmp)
    * [代码格式化 (Conform.nvim)](#代码格式化-conform-nvim)
    * [语法高亮与代码分析 (Nvim-treesitter)](#语法高亮与代码分析-nvim-treesitter)
    * [Git 集成 (Gitsigns.nvim)](#git-集成-gitsigns-nvim)
6.  [实用工具 (Utilities)](#实用工具-utilities)
    * [集成终端 (Toggleterm.nvim)](#集成终端-toggleterm-nvim)
    * [自定义断点功能](#自定义断点功能)
7.  [重要 Vim 选项与自动命令](#重要-vim-选项与自动命令)
8.  [快捷键提示 (Which-Key)](#快捷键提示-which-key)
9. [如何进一步自定义](#如何进一步自定义)

---

## 核心理念与基础设置

* **Leader 键**:
    * 全局 Leader: `\` (反斜杠)
    * 局部 Leader: `,` (逗号)
    * 您的大部分自定义快捷键都将以这些前缀开始。
* **Nerd Font 支持**: `vim.g.have_nerd_font = true` 表明配置期望您已安装并使用 Nerd Font，以便正确显示图标。
* **禁用内置插件**: 为了性能或使用替代插件，一些内置插件（如 `netrw`, `gzip` 等）已被禁用。

## 插件管理 (Lazy.nvim)

您的配置使用 `lazy.nvim` 进行插件管理。

* **打开 Lazy.nvim 管理界面**: `<leader>ll`
* **更新插件**: `<leader>lu` 或在 Lazy 界面按 `U`。
* 插件配置位于 `init.lua` 文件中的 `plugins` 表内。大部分插件都配置为按需加载（lazy loading）以优化启动速度。

## 用户界面与体验 (UI & UX)

### 主题与颜色 (Gruvbox)

* **主题**: Gruvbox (`morhetz/gruvbox`) 已被设为默认主题。
* **对比度**: `vim.g.gruvbox_contrast_dark = "medium"`
* **自定义高亮**:
    * 为 Treesitter 和 BlinkCmp 定制了颜色以更好地匹配 Gruvbox 主题。
    * 例如，变量、属性、字符串及补全菜单 (`BlinkCmp*`) 都有特定颜色设置。

### 状态栏 (Lualine)

* **插件**: `nvim-lualine/lualine.nvim`
* **主题**: Gruvbox (与主编辑器主题一致)
* **特性**: 显示当前模式、Git 分支、文件名、LSP 状态、诊断信息等。集成了 Neo-tree 和 Mason 的状态。
* **全局状态栏**: `globalstatus = true` (即使只有一个窗口也显示状态栏)。

### 启动屏 (Dashboard-nvim)

* **插件**: `nvimdev/dashboard-nvim`
* **主题**: Hyper
* **特性**:
    * 启动 Neovim 时显示欢迎界面和 ASCII Art。
    * 提供常用操作的快捷方式，如：
        * `u`: 更新插件 (Lazy update)
        * `f`: 查找文件 (Telescope find_files)
        * `g`: 全局搜索 (Telescope live_grep)
        * `p`: 项目管理 (Telescope project - *通常需要如 `project.nvim` 插件配合*)
        * `r`: 最近文件 (Telescope oldfiles)
        * `c`: 编辑 Neovim 配置 (`edit $MYVIMRC`)
    * 显示最近使用的项目和文件列表。

### 文件浏览器 (Neo-tree)

* **插件**: `nvim-neo-tree/neo-tree.nvim`
* **快捷键**:
    * `<F3>` 或 `<leader>e`: 打开/关闭 Neo-tree
    * `-` (连字符): 在 Neo-tree 中定位并展开当前打开的文件
* **特性**:
    * 默认在左侧打开，宽度为 35。
    * 当 Neo-tree 是最后一个窗口时关闭它会自动关闭。
    * 显示 Git 状态。
    * 自动跟踪当前文件 (`follow_current_file`)。
    * 过滤特定文件和目录 (如 `node_modules`, `.git`, `__pycache__` 等)。

### 缩进指示 (Indent-blankline)

* **插件**: `lukas-reineke/indent-blankline.nvim`
* **特性**:
    * 使用 `│` 字符显示缩进线。
    * 启用范围高亮 (`scope.enabled = true`)，帮助可视化代码块。
    * 在特定文件类型（如 `help`, `neo-tree` 等）中禁用。

### 通知系统 (Nvim-notify)

* **插件**: `rcarriga/nvim-notify`
* **特性**: 使用自定义的通知系统替代 Neovim 默认的通知，提供更美观的通知样式。`vim.notify` 将使用此插件。

## 核心编辑增强 (Core Editing Enhancements)

### 自动括号/引号配对 (Nvim-autopairs)

* **插件**: `windwp/nvim-autopairs`
* **特性**:
    * 在输入括号、引号等时自动插入配对的另一半。
    * 集成了 Treesitter (`check_ts = true`) 以获得更智能的配对行为。

### 注释切换 (Comment.nvim)

* **插件**: `numToStr/Comment.nvim`
* **快捷键**:
    * 普通模式: `<leader>cc` 或 `<leader>c<space>` - 切换当前行或选区的行注释。
    * 可视模式: `<leader>cc` 或 `<leader>c<space>` - 切换选中内容的行注释。
* **配置**: 使用默认配置，根据文件类型智能判断注释符号。

### 模糊搜索与操作 (Telescope.nvim)

Telescope 是一个强大的模糊查找器，用于快速查找文件、文本、缓冲区、Git 对象等。

* **通用操作**:
    * 在 Telescope 窗口中，`<C-j>` 和 `<C-k>` 用于上下选择。
    * `<C-q>` 将选中项发送到 Quickfix 列表并打开。
* **主要查找快捷键**:
    * `<leader>ff`: 查找文件
    * `<leader>fg`: 全局实时搜索 (Live Grep)
    * `<leader>fw`: 搜索光标下的单词
    * `<leader>fb`: 查找已打开的缓冲区
    * `<leader>fh`: 查找帮助文档标签
    * `<leader>fr`: 查找最近打开的文件
    * `<leader>\\f`: 查找项目中的 Git 文件
    * `<leader>\\b`: 查看 Git 分支
    * `<leader>\\c`: 查看 Git 提交记录
    * `<leader>\\s`: 查看 Git 状态
    * `<leader>ls`: 列出当前文件的 LSP 文档符号 (如函数、变量)
    * `<leader>lS`: 列出工作区的 LSP 工作区符号
    * `<leader>ld`: 列出 LSP 诊断信息 (错误、警告)
    * `<leader>f/`: 在当前缓冲区内模糊查找内容
* **配置**:
    * 使用 `rg` (ripgrep) 进行文件查找和内容搜索（如果已安装）。
    * 忽略特定文件和目录 (如 `.git`, `node_modules`)。
    * 集成了 `telescope-fzf-native` 以提升排序性能。
    * UI 选择器使用 `ivy` 主题。

## 代码开发与 LSP (Code Development & LSP)

### LSP 环境管理 (Mason & Mason-lspconfig)

* **Mason (`williamboman/mason.nvim`)**:
    * 用于管理 LSP 服务器、DAP (Debug Adapter Protocol) 服务器、Linter 和 Formatter。
    * 命令: `:Mason` 打开管理界面。
    * 自动安装配置中 `ensure_installed` 列出的工具 (如 `clangd`, `pyright`, `stylua`, `black` 等)。
* **Mason-lspconfig (`williamboman/mason-lspconfig.nvim`)**:
    * 桥接 Mason 和 `nvim-lspconfig`。
    * 自动为通过 Mason 安装的 LSP 服务器配置 `nvim-lspconfig`。
    * 确保 `clangd` 和 `pyright` 等 LSP 服务器已安装并配置。

### LSP 核心功能 (Nvim-lspconfig)

LSP (Language Server Protocol) 为各种语言提供了代码补全、跳转到定义、查找引用、诊断等功能。

* **通用 LSP 快捷键** (在 `on_attach` 中定义，对支持的 LSP 服务器生效):
    * `<C-]>`: 跳转到定义
    * `<C-w>]`: 在新水平分割窗口中打开定义
    * `<C-w><C-]>`: 在新垂直分割窗口中打开定义
    * `<C-t>`: (等效于 `<C-o>`) 返回上一个位置
    * `<leader>dt`: 跳转到类型定义
    * `<leader>di`: 跳转到实现
    * `<leader>dr`: 查找引用
    * `<leader>dd`: 跳转到声明
    * `K`: 显示悬停文档/信息 (Hover)
    * `<leader>cr`: 重命名符号
    * `<C-k>`: 显示函数签名帮助
    * `<leader>ca`: 执行代码操作 (Code Action)
    * `<leader>cf`: 使用 LSP 格式化代码 (如果 LSP 服务器支持)
* **诊断信息**:
    * 通过虚拟文本 (`prefix = "●"`)、下划线显示。
    * 浮动窗口 (`vim.diagnostic.open_float` 或 `<leader>de`) 显示详细诊断。
    * `[d` / `]d`: 跳转到上一个/下一个诊断。
    * `<leader>dq`: 将诊断信息发送到 Quickfix 列表。
* **特定 LSP 服务器配置**:
    * **Clangd**: 针对 C/C++，配置了更详细的命令行参数和初始化选项。
    * **Pyright**: 针对 Python，配置了类型检查模式、自动导入补全等。

### 代码补全 (Blink.cmp)

* **插件**: `saghen/blink.cmp`
* **特性**: 提供了一个美观且功能强大的补全引擎。
* **主要快捷键** (在补全菜单激活时):
    * `<CR>` 或 `<Right>`: 接受选中项
    * `<Tab>` / `<S-Tab>`: 选择下一个/上一个候选项
    * `<C-space>`: 手动触发补全 / 显示/隐藏文档
* **来源**: LSP (`lsp`), 路径 (`path`), 当前缓冲区内容 (`buffer`)。
* **外观**:
    * 使用 Nerd Font Mono 变体。
    * 菜单边框为圆角。
    * 启用幽灵文本 (Ghost Text) 预览。
* **颜色**: BlinkCmp 的颜色高亮已在 Gruvbox 主题配置中特别定制。

### 代码格式化 (Conform.nvim)

* **插件**: `stevearc/conform.nvim`
* **特性**:
    * 统一的格式化框架，支持多种格式化工具。
    * 按文件类型配置格式化器 (如 Lua 使用 `stylua`, Python 使用 `isort` 和 `black`)。
    * **手动格式化命令**: `:Fm` (会异步格式化当前缓冲区，可回退到 LSP 格式化)。
    * **集成到 Vim 的格式化命令**: `gq` 会使用 Conform.nvim 进行格式化 (通过 `vim.o.formatexpr`)。
    * **保存时自动格式化已禁用**: 您需要手动运行 `:Fm` 或使用 `gq`。

### 语法高亮与代码分析 (Nvim-treesitter)

* **插件**: `nvim-treesitter/nvim-treesitter`
* **特性**:
    * 提供更快速、更准确的语法高亮。
    * 支持多种语言，并会自动安装缺失的解析器。
    * **代码缩进**: 基于 Treesitter 的语法树进行缩进。
    * **增量选择**:
        * `<C-space>`: 初始化/扩大基于语法的选择
        * `<bs>` (Backspace): 缩小选择

### Git 集成 (Gitsigns.nvim)

* **插件**: `lewis6991/gitsigns.nvim`
* **特性**:
    * 在符号列 (signcolumn) 中显示当前文件相对于 Git 仓库的更改状态 (添加、修改、删除的行)。
    * 自定义了差异指示符 (`│`, `_`, `~` 等)。
* **快捷键** (以 `<leader>h` 开头):
    * `]h` / `[h`: 跳转到下一个/上一个 Git Hunk (代码块更改)
    * `<leader>hs`: Staging 当前 Hunk (或可视模式选中的行)
    * `<leader>hr`: Reset 当前 Hunk (或可视模式选中的行)
    * `<leader>hS`: Staging整个缓冲区
    * `<leader>hR`: Reset 整个缓冲区
    * `<leader>hp`: 预览当前 Hunk 的内容
    * `<leader>hb`: 查看当前行的 Git Blame 信息

## 实用工具 (Utilities)

### 集成终端 (Toggleterm.nvim)

* **插件**: `akinsho/toggleterm.nvim`
* **快捷键**:
    * `<leader>tt` 或 `<C-\>`: 打开/关闭浮动终端
* **特性**:
    * 默认以浮动窗口形式打开，边框为圆角。
    * 在终端模式下，按 `<esc><esc>` 可以回到普通模式。

### 自定义断点功能

这是一个您在配置中自定义的功能，用于快速插入/删除调试断点。

* **快捷键**:
    * `<leader>bb`: 切换当前行的断点 (智能判断插入或删除)
    * `<leader>cb`: 移除当前文件中所有由该功能插入的调试断点
* **支持的文件类型与断点语句**:
    * Python: `breakpoint()  # DEBUG`
    * C/C++: `raise(SIGTRAP);  // DEBUG`
* **操作**: 会在对应位置插入或删除断点语句，并给出通知。

## 重要 Vim 选项与自动命令

您的配置中设置了许多有用的 Vim 选项和自动命令：

* **编码**: UTF-8
* **备份与撤销**: 禁用备份和交换文件，启用持久化撤销 (`undofile`)，撤销文件存储在 `vim.fn.stdpath("data") .. "/undodir"`。
* **缩进**: Tab=4空格，自动缩进。
* **搜索**: 忽略大小写（除非包含大写字母），增量搜索，高亮搜索结果。
* **界面**: 显示行号，高亮当前行，显示符号列，禁用自动换行，滚动偏移量，120字符列标尺，真彩色，剪贴板与系统共享 (`unnamedplus`)。
* **自动命令**:
    * **高亮复制内容**: 复制文本后短暂高亮。
    * **记住光标位置**: 重新打开文件时恢复上次光标位置。
    * **自动创建目录**: 保存文件时如果父目录不存在则自动创建。
    * **特定窗口按 q 关闭**: 如帮助、LSP 信息、Quickfix 列表等窗口可以用 `q` 关闭。
    * **自动删除行末空格**: 保存文件前自动移除行尾多余空格 (Markdown, diff, gitcommit 文件类型除外)。

## 快捷键提示 (Which-Key)

* **插件**: `folke/which-key.nvim`
* **特性**: 当您按下 `<leader>` (即 `\`) 并稍等片刻，`which-key` 会弹出一个窗口，显示所有可用的后续按键及其功能描述。
* **分组**: 快捷键被组织成逻辑分组，方便查找和记忆，例如：
    * `<leader>f`: 文件/查找 (Telescope)
    * `<leader>\\`: Git 相关 (Telescope)
    * `<leader>h`: Git Hunks (Gitsigns)
    * `<leader>l`: LSP/Lazy 相关
    * `<leader>c`: 代码/注释 相关
    * ... 等等 (详见 `which-key` 配置部分)

## 如何进一步自定义

* **配置文件**: 您的主要配置文件是 `vim.fn.stdpath("config") .. "/init.lua"` (通常是 `~/.config/nvim/init.lua`)。您可以通过 `:edit $MYVIMRC` 快速打开它。
* **插件配置**: 大部分插件的配置都在 `init.lua` 文件内 `plugins` 表的对应条目中。您可以修改 `opts` 或 `config` 函数。
* **添加新插件**: 在 `plugins` 表中添加新的条目，遵循 `lazy.nvim` 的规范。
* **修改快捷键**: 快捷键主要在各个插件的 `keys` 部分，以及 `setup_keymaps()` 函数中定义。
* **LSP 和格式化器**: 使用 `:Mason` 管理 LSP 服务器和格式化工具的安装。

---

希望这份包含了安装说明的更全面的指南能帮助您更好地使用和理解您的 Neovim 配置！
