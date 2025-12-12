# Neovim 配置

一个现代化、功能丰富的 Neovim 配置，专注于 Python、C/C++ 开发，集成 LSP、AI 辅助编程，提供简洁高效的用户体验。

## 📋 环境要求

| 依赖项 | 版本要求 | 备注 |
|--------|----------|------|
| Neovim | >= 0.8.0 | 需要 LuaJIT 支持 |
| Git | >= 2.19.0 | 支持部分克隆 |
| Nerd Font | 任意版本 | 可选，用于显示图标 |
| Node.js | 最新 LTS | Copilot 需要 |
| ripgrep | 最新版 | Telescope 实时搜索需要 |
| Python | 3.8+ | Python 开发需要 |

## 🚀 安装步骤

### 1. 备份现有配置

```bash
# 备份现有配置
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

### 2. 创建配置目录

```bash
mkdir -p ~/.config/nvim
```

### 3. 安装配置文件

```bash
# 将 init.lua 复制到配置目录
cp init.lua ~/.config/nvim/init.lua
```

### 4. 安装外部依赖

#### macOS (Homebrew)

```bash
brew install neovim ripgrep node python3
```

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install neovim ripgrep nodejs npm python3 python3-pip
```

#### Arch Linux

```bash
sudo pacman -S neovim ripgrep nodejs npm python python-pip
```

#### Windows (Scoop)

```powershell
scoop install neovim ripgrep nodejs python
```

### 5. 首次启动

```bash
nvim
```

首次启动时，lazy.nvim 会自动完成以下操作：

- 自动安装插件管理器
- 安装所有配置的插件
- 通过 Mason 安装 LSP 服务器
- 安装格式化工具和代码检查器

### 6. 配置 Copilot

安装完成后，需要进行 GitHub Copilot 认证：

```vim
:Copilot auth
```

按照提示完成 GitHub 账户认证即可。

### 7. 验证安装

```vim
:checkhealth
:Mason
:Lazy
```

---

## ✨ 功能概览

### 🎨 用户界面

| 功能 | 插件 | 说明 |
|------|------|------|
| 主题配色 | gruvbox | 温暖复古的配色方案 |
| 状态栏 | lualine.nvim | 美观且信息丰富的状态栏 |
| 文件浏览器 | neo-tree.nvim | 现代文件树，集成 Git 状态 |
| 启动面板 | dashboard-nvim | 自定义启动界面，快捷操作 |
| 文件图标 | nvim-web-devicons | 全局文件类型图标支持 |
| 缩进指示 | indent-blankline.nvim | 可视化缩进层级 |
| 通知弹窗 | nvim-notify | 美观的弹出式通知 |
| 按键提示 | which-key.nvim | 显示可用快捷键的弹窗 |

### 📝 代码编辑

| 功能 | 插件/方法 | 说明 |
|------|-----------|------|
| 自动补全 | blink.cmp | 快速、现代的补全引擎 |
| 自动配对 | nvim-autopairs | 自动闭合括号、引号 |
| 注释切换 | Comment.nvim | 快速注释/取消注释代码 |
| 代码格式化 | conform.nvim | 多格式化器支持 |
| 语法高亮 | nvim-treesitter | 基于语法树的高级高亮 |

### 🤖 AI 辅助编程

| 功能 | 插件 | 快捷键 | 说明 |
|------|------|--------|------|
| Copilot 建议 | copilot.lua | `<M-l>` | 接受 AI 补全建议 |
| Copilot 面板 | copilot.lua | `<leader>cp` | 打开建议面板 |
| Copilot 开关 | copilot.lua | `<leader>ct` | 启用/禁用 Copilot |

### 🔧 语言服务器协议 (LSP)

| 功能 | 说明 | 快捷键 |
|------|------|--------|
| 跳转定义 | 跳转到符号定义处 | `<C-]>` |
| 跳转定义（水平分屏） | 在水平分屏中打开定义 | `<C-w>]` |
| 跳转定义（垂直分屏） | 在垂直分屏中打开定义 | `<C-w><C-]>` |
| 查找引用 | 列出所有引用位置 | `<leader>dr` |
| 类型定义 | 跳转到类型定义 | `<leader>dt` |
| 实现 | 跳转到实现 | `<leader>di` |
| 声明 | 跳转到声明 | `<leader>dd` |
| 悬停文档 | 显示文档弹窗 | `K` |
| 签名帮助 | 显示函数签名 | `<C-k>` |
| 重命名符号 | 跨项目重命名 | `<leader>cr` |
| 代码操作 | 快速修复和操作 | `<leader>ca` |

### 📝 文档生成

| 功能 | 插件 | 快捷键 | 说明 |
|------|------|--------|------|
| 生成文档字符串 | neogen | `<leader>ng` | 自动检测类型 |
| 函数文档 | neogen | `<leader>nf` | 为函数生成文档 |
| 类文档 | neogen | `<leader>nc` | 为类生成文档 |
| 类型文档 | neogen | `<leader>nt` | 为类型生成文档 |

**支持的文档风格：**

- Python：Google Docstrings
- C/C++：Doxygen
- Lua：EmmyLua

### 🔍 诊断与代码检查

| 来源 | 语言 | 说明 |
|------|------|------|
| Pyright | Python | 类型检查、诊断 |
| Ruff | Python | 快速代码检查器（通过 LSP + nvim-lint） |
| clangd | C/C++ | 诊断、补全 |
| cppcheck | C/C++ | 静态分析（通过 nvim-lint） |

| 快捷键 | 说明 |
|--------|------|
| `<leader>de` | 显示光标处的诊断信息 |
| `[d` | 上一个诊断 |
| `]d` | 下一个诊断 |
| `<leader>dq` | 将诊断发送到快速修复列表 |
| `<leader>ld` | 列出所有诊断（Telescope） |

### 🎯 代码格式化

| 语言 | 格式化工具 |
|------|------------|
| Python | isort + black |
| C/C++ | clang-format |
| Lua | stylua |
| JavaScript/TypeScript | prettier |
| HTML/CSS/SCSS | prettier |
| JSON/YAML | prettier |
| Markdown | prettier |
| Bash/Shell | shfmt |

| 快捷键 | 说明 |
|--------|------|
| `<leader>cf` | 格式化当前缓冲区 |
| `:Fm` | 格式化命令 |

### 🔎 模糊查找 (Telescope)

| 快捷键 | 说明 |
|--------|------|
| `<leader>ff` | 查找文件 |
| `<leader>fg` | 实时搜索（在文件中搜索） |
| `<leader>fw` | 搜索光标下的单词 |
| `<leader>fb` | 列出缓冲区 |
| `<leader>fh` | 帮助标签 |
| `<leader>fr` | 最近文件 |
| `<leader>f/` | 在当前缓冲区模糊查找 |
| `<leader>\f` | Git 文件 |
| `<leader>\b` | Git 分支 |
| `<leader>\c` | Git 提交 |
| `<leader>\s` | Git 状态 |
| `<leader>ls` | 文档符号 |
| `<leader>lS` | 工作区符号 |

### 🐛 调试支持

| 快捷键 | 说明 |
|--------|------|
| `<leader>bb` | 在光标处切换断点 |
| `<leader>bx` | 移除当前文件所有断点 |

**断点类型：**

- Python：`breakpoint()  # DEBUG`
- C/C++：`raise(SIGTRAP);  // DEBUG`

### 📦 Git 集成

| 快捷键 | 说明 |
|--------|------|
| `]h` | 下一个 Git 变更块 |
| `[h` | 上一个 Git 变更块 |
| `<leader>hs` | 暂存变更块 |
| `<leader>hr` | 重置变更块 |
| `<leader>hS` | 暂存整个缓冲区 |
| `<leader>hR` | 重置整个缓冲区 |
| `<leader>hp` | 预览变更块 |
| `<leader>hb` | 显示行 blame 信息 |

### 🖥️ 终端

| 快捷键 | 说明 |
|--------|------|
| `<leader>tt` | 切换浮动终端 |
| `<C-\>` | 切换浮动终端 |
| `<Esc><Esc>` | 退出终端模式 |

### 🪟 窗口管理

| 快捷键 | 说明 |
|--------|------|
| `<C-h>` | 导航到左侧窗口 |
| `<C-j>` | 导航到下方窗口 |
| `<C-k>` | 导航到上方窗口 |
| `<C-l>` | 导航到右侧窗口 |
| `<leader>wv` | 垂直分屏 |
| `<leader>ws` | 水平分屏 |
| `<leader>wc` | 关闭当前窗口 |
| `<leader>wo` | 关闭其他窗口 |

### 📄 缓冲区管理

| 快捷键 | 说明 |
|--------|------|
| `<S-h>` | 上一个缓冲区 |
| `<S-l>` | 下一个缓冲区 |
| `<leader>bd` | 删除缓冲区（带确认） |

### 💾 文件操作

| 快捷键 | 说明 |
|--------|------|
| `<C-s>` | 保存文件 |
| `<leader>qq` | 退出所有（带确认） |
| `<leader>q!` | 强制退出所有 |
| `<F3>` | 切换文件浏览器 |
| `<leader>e` | 切换文件浏览器 |
| `-` | 在浏览器中定位当前文件 |

### 📋 剪贴板

| 快捷键 | 说明 |
|--------|------|
| `<leader>y` | 复制到系统剪贴板 |
| `<leader>p` | 从系统剪贴板粘贴（光标后） |
| `<leader>P` | 从系统剪贴板粘贴（光标前） |

### ⚡ 插件管理

| 快捷键 | 说明 |
|--------|------|
| `<leader>ll` | 打开 Lazy 插件管理器 |
| `<leader>lu` | 更新所有插件 |

---

## 🗂️ Leader 键分组

| 前缀 | 分组 | 说明 |
|------|------|------|
| `<leader>f` | 查找/文件 | Telescope 文件操作 |
| `<leader>\` | Git | Telescope Git 操作 |
| `<leader>h` | 变更块 | Gitsigns 变更块操作 |
| `<leader>l` | LSP/Lazy | LSP 符号、Lazy 管理器 |
| `<leader>d` | 诊断 | LSP 诊断 |
| `<leader>c` | 代码/注释 | 注释、格式化、Copilot |
| `<leader>n` | Neogen | 文档字符串生成 |
| `<leader>b` | 缓冲区/断点 | 缓冲区和调试操作 |
| `<leader>w` | 窗口 | 窗口管理 |
| `<leader>t` | 切换/终端 | 终端操作 |
| `<leader>q` | 退出 | 会话退出操作 |

---

## 🔌 已安装插件

### 核心

- **lazy.nvim** - 插件管理器
- **plenary.nvim** - Lua 工具库

### 界面

- **gruvbox** - 配色方案
- **lualine.nvim** - 状态栏
- **neo-tree.nvim** - 文件浏览器
- **dashboard-nvim** - 启动界面
- **nvim-web-devicons** - 文件图标
- **indent-blankline.nvim** - 缩进指示
- **nvim-notify** - 通知弹窗
- **which-key.nvim** - 按键提示

### 编辑器

- **nvim-treesitter** - 语法高亮
- **nvim-autopairs** - 自动配对
- **Comment.nvim** - 注释切换
- **telescope.nvim** - 模糊查找
- **toggleterm.nvim** - 终端

### LSP 与补全

- **nvim-lspconfig** - LSP 配置
- **mason.nvim** - LSP/工具安装器
- **mason-lspconfig.nvim** - Mason LSP 桥接
- **blink.cmp** - 补全引擎
- **lsp_signature.nvim** - 签名帮助

### AI 与文档

- **copilot.lua** - GitHub Copilot
- **neogen** - 文档字符串生成

### 格式化与检查

- **conform.nvim** - 格式化工具
- **nvim-lint** - 代码检查器

### Git

- **gitsigns.nvim** - Git 装饰

---

## 📁 文件结构

```
~/.config/nvim/
└── init.lua          # 完整配置文件

~/.local/share/nvim/
├── lazy/             # 插件安装目录
├── mason/            # LSP 服务器、格式化工具、检查器
└── undodir/          # 持久化撤销历史
```

---

## 🛠️ 自定义配置

### 更改 Leader 键

编辑 `init.lua` 顶部：

```lua
vim.g.mapleader = " "       -- 改为空格键
vim.g.maplocalleader = ","
```

### 添加新的 LSP 服务器

在 `setup_lsp()` 函数中，添加到 `ensure_installed`：

```lua
local ensure_installed = {
  -- 现有服务器...
  "rust_analyzer",  -- 添加新服务器
}
```

### 添加新的格式化工具

在 `conform.nvim` 配置中：

```lua
formatters_by_ft = {
  -- 现有格式化工具...
  rust = { "rustfmt" },
}
```

### 添加新的代码检查器

在 `nvim-lint` 配置中：

```lua
lint.linters_by_ft = {
  -- 现有检查器...
  javascript = { "eslint" },
}
```

### 更改 Python 文档字符串风格

在 `neogen` 配置中：

```lua
languages = {
  python = {
    template = { annotation_convention = "numpydoc" },  -- 或 "sphinx", "reST"
  },
},
```

---

## ❓ 常见问题

### 插件无法安装

```vim
:Lazy sync
```

### LSP 不工作

```vim
:LspInfo
:Mason
```

### Copilot 问题

```vim
:Copilot status
:Copilot auth
```

### 健康检查

```vim
:checkhealth
```

### 重置配置

```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
nvim  # 重新安装所有内容
```

---

## 📄 许可证

本配置仅供个人使用。欢迎自由修改和分发。
