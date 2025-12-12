# Neovim 配置使用说明（Python 优先｜lazy.nvim）

> 适用文件：`~/.config/nvim/init.lua`  
> 本配置以 **Python 开发体验** 为核心：LSP（pyright + ruff）、格式化（black + isort）、搜索（telescope）、文件树（neo-tree）、Git（gitsigns）等。

---

## 0. 环境要求

### 必需
- **Neovim ≥ 0.8**（推荐 **0.10+**）
- **Git ≥ 2.19**（lazy.nvim 使用 partial clone）
- 可选：**Nerd Font**（图标显示更完整）

### 推荐安装的命令行工具
- `rg`（ripgrep）：Telescope 的 `live_grep`/文件扫描更好用
- `make` / C 编译环境：用于编译 `telescope-fzf-native.nvim`

### Python 工具（由 Mason 自动安装）
本配置会通过 **Mason** 安装：
- `pyright`：Python LSP（类型检查、跳转等）
- `ruff`：lint + code action（快速修复）
- `black` + `isort`：通过 Conform 执行格式化

> Mason 安装到 Neovim data 目录，一般不需要你系统全局安装。

---

## 1. 第一次启动/安装流程

1. 启动 Neovim：
   ```bash
   nvim
   ```
2. `lazy.nvim` 会自动 bootstrap 并安装插件。
3. Mason 会尝试安装所需工具（pyright/ruff/black/isort 等）。

### 常用自检命令
在 Neovim 中执行：
- `:checkhealth`（环境与依赖检查）
- `:Lazy`（插件状态/安装/更新）
- `:Mason`（LSP/formatter 工具安装状态）

---

## 2. 启动界面与文件树

### Dashboard（启动页）
无参数启动时会进入 Dashboard，并提供快捷入口：
- `u`：`Lazy update` 更新插件
- `f`：`Telescope find_files` 查找文件
- `g`：`Telescope live_grep` 全局搜索
- `r`：`Telescope oldfiles` 最近文件
- `c`：打开配置文件 `$MYVIMRC`

### Neo-tree（文件管理器）
- `<F3>`：切换 Neo-tree
- `\e`：切换 Neo-tree（注意 leader 是反斜杠 `\`）
- `-`：在 Neo-tree 中定位当前文件

启动行为：
- `nvim`（无参数）：Dashboard 出现后自动打开 Neo-tree
- `nvim <目录>`：自动 `:cd` 到该目录并打开 Neo-tree

---

## 3. 核心快捷键速查（最常用）

> Leader 键：`\`（反斜杠）

### 3.1 搜索/文件（Telescope）
- `\ff`：查找文件（Find Files）
- `\fg`：全局搜索（Live Grep）
- `\fw`：搜索光标下单词（Grep Word）
- `\fb`：切换 Buffer 列表
- `\fr`：最近文件
- `\fh`：帮助文档搜索（help tags）
- `\f/`：当前 buffer 模糊搜索

### 3.2 Git（Telescope）
- `\\f`：git files
- `\\b`：git branches
- `\\c`：git commits
- `\\s`：git status

### 3.3 Git Hunk（Gitsigns）
- `]h` / `[h`：下/上一个 hunk
- `\hs`：stage hunk
- `\hr`：reset hunk
- `\hp`：预览 hunk
- `\hb`：blame 当前行

### 3.4 注释（Comment.nvim）
- `\cc`：切换注释（普通/可视模式）
- `\c<space>`：切换注释（普通/可视模式）

### 3.5 格式化（Conform）
- `:Fm`：格式化当前文件
- `\cf`：格式化当前文件（等价于 `:Fm`）

Python 格式化链路：
- 先 `isort`，后 `black`

> 本配置默认 **不自动保存格式化**，避免你在保存时被强制改动；需要时手动 `\cf` 即可。

### 3.6 LSP（Python：pyright + ruff）
常用跳转：
- `K`：悬浮文档（Hover）
- `<C-]>`：跳到定义（Definition）
- `<C-w>]`：在横向分屏打开定义
- `<C-w><C-]>`：在纵向分屏打开定义
- `\dd`：跳到声明（Declaration）
- `\di`：跳到实现（Implementation）
- `\dr`：引用列表（References）
- `\dt`：类型定义（Type Definition）

重构/动作：
- `\cr`：重命名（Rename）
- `\ca`：Code Action（普通/可视模式）
- `<C-k>`：签名帮助（Signature Help）

返回跳转：
- `<C-t>`：回到上一个位置（使用 jumplist 的 `<C-o>`）

> 注意：在开启 LSP 的 buffer 中，`<C-k>` 会被用于“签名帮助”，可能覆盖你原先的“窗口向上移动”。

### 3.7 诊断（Diagnostics）
- `\de`：光标处浮窗显示诊断
- `[d` / `]d`：上/下一个诊断
- `\dq`：把诊断放进 quickfix 列表

### 3.8 终端（ToggleTerm）
- `\tt`：切换浮动终端
- `<C-\>`：切换浮动终端
- 终端模式：`<Esc><Esc>` 返回普通模式

### 3.9 Buffer 与窗口
Buffer：
- `\bd`：关闭当前 buffer（若未保存会提示）
- `Shift-h` / `Shift-l`：上/下一个 buffer

窗口：
- `<C-h/j/k/l>`：窗口切换（在 LSP buffer 中 `<C-k>` 可能变为签名帮助）
- `\wv`：纵向分屏
- `\ws`：横向分屏
- `\wc`：关闭当前窗口
- `\wo`：关闭其它窗口

退出：
- `\qq`：退出全部（如有未保存会提示）
- `\q!`：强制退出不保存

---

## 4. Python 推荐工作流（从零到顺手）

### 4.1 打开项目
```bash
nvim /path/to/your_project
```
- Neo-tree 管理目录结构
- `\ff` 快速找文件
- `\fg` 全局搜字符串/函数名/变量名

### 4.2 类型检查/跳转（pyright）
- 打开 `.py` 文件后自动启动
- `<C-]>` 跳定义，`K` 看文档

### 4.3 Lint 与快速修复（ruff）
- 有警告/错误时，用：
  - `\ca` 调出 code action（例如修复 import、替换写法等）
- 想全局浏览诊断：
  - `\ld`（Telescope diagnostics 列表）
  - 或 `\dq` 进 quickfix

### 4.4 格式化（black + isort）
- 随时 `\cf` / `:Fm` 统一格式
- 适合在提交前/PR 前执行一次

---

## 5. lazy.nvim 插件管理（必学）

- `\ll`：打开 `:Lazy` 面板（安装/加载/性能/日志）
- `\lu`：更新插件（`Lazy update`）

常见排障：
- 插件不见了/没装全：`:Lazy sync`
- LSP/formatter 不工作：`:Mason` 看是否已安装工具

---

## 6. 断点辅助（Breakpoint）

用于快速插入/删除调试断点：
- `\bb`：智能切换断点（当前行有断点则删，没有则插）
- `\cb`：删除当前文件所有断点

Python 插入内容：
```python
breakpoint()  # DEBUG
```

---

## 7. 已知行为与可选调整

### `<C-k>` 冲突说明
- 全局：`<C-k>` 是“窗口向上”
- LSP buffer：`<C-k>` 变成“签名帮助”

如果你更想保留窗口导航：
- 修改 `on_attach()` 里 `<C-k>` 的 mapping，换成 `gK` 或 `\k` 等。

---

## 8. 快速验收清单（确认是否都正常）

在 Neovim 中执行：
1. `:Lazy` → 插件均已安装
2. `:Mason` → `pyright` / `ruff` / `black` / `isort` 状态为 installed
3. 打开 `test.py`：
   - 补全可用（blink.cmp）
   - `K` 有 hover
   - `\ca` 有 code action（ruff/pyright）
   - `\cf` 能格式化（black+isort）

---
