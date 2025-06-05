" vim-plug: Vim plugin manager
" ============================
"
" 1. Download plug.vim and put it in 'autoload' directory
"
"   # Neovim
"   sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"
" 2. Add a vim-plug section to your ~/.config/nvim/init.vim for Neovim
"
"   call plug#begin()
"
"   " List your plugins here
"   Plug 'tpope/vim-sensible'
"
"   call plug#end()
"
" 3. Reload the file or restart Vim, then you can,
"
"      :PlugInstall to install plugins
"      :PlugUpdate  to update plugins
"      :PlugDiff    to review the changes from the last update
"      :PlugClean   to remove plugins no longer in the list
"
" For more information, see https://github.com/junegunn/vim-plug
"

"*****************************************************************************
"" Vim-Plug core
"*****************************************************************************
" Standard path for vim-plug autoload
let vimplug_autoload_path = stdpath('data') . '/site/autoload/plug.vim'
let vimplug_plugged_path = stdpath('data') . '/plugged' " Standard path for plugins

if empty(glob(vimplug_autoload_path))
  if !executable('curl')
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent execute '!curl -fLo ' . shellescape(vimplug_autoload_path) . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  let g:not_finish_vimplug = "yes"
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC " More robust installation
endif

" Required:
call plug#begin(vimplug_plugged_path) " Use standard path

"*****************************************************************************
"" Plug install packages
"*****************************************************************************
Plug 'tpope/vim-sensible' " Sensible Vim defaults

" File Explorer
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs' " NERDTree and tabs integration

" Commenting
Plug 'scrooloose/nerdcommenter'

" Formatting
Plug 'sbdchd/neoformat'

" Git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb' " For :Gbrowse on GitHub etc.
Plug 'airblade/vim-gitgutter' " Git diff in sign column

" UI & Appearance
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox' " Theme
Plug 'Yggdroot/indentLine' " Indent guides
Plug 'mhinz/vim-startify' " Start screen
Plug 'vim-scripts/CSApprox' " Improved colors in terminal

" Editing Aids
Plug 'jiangmiao/auto-pairs' " Auto-close pairs

" Linting
Plug 'dense-analysis/ale'

" Fuzzy Finder
if isdirectory('/usr/local/opt/fzf') " Support for brew-installed FZF on macOS
  Plug '/usr/local/opt/fzf'
  Plug 'junegunn/fzf.vim'
else
  Plug 'junegunn/fzf', { 'do': './install --bin' } " Installs FZF if not found
  Plug 'junegunn/fzf.vim'
endif

" Async processes
let g:make = executable('gmake') ? 'gmake' : 'make'
Plug 'Shougo/vimproc.vim', {'do': g:make}

" Session Management
Plug 'xolox/vim-misc' " Dependency
Plug 'xolox/vim-session'

" Snippets & Completion
Plug 'hrsh7th/vim-vsnip'          " Snippet engine
Plug 'rafamadriz/friendly-snippets' " Snippet collection
Plug 'hrsh7th/nvim-cmp'           " Completion engine
Plug 'hrsh7th/cmp-nvim-lsp'       " LSP completion source
Plug 'hrsh7th/cmp-buffer'        " Buffer completion source
Plug 'hrsh7th/cmp-path'          " Path completion source
Plug 'hrsh7th/cmp-cmdline'       " Command line completion source
Plug 'hrsh7th/cmp-vsnip'         " Vsnip completion source
Plug 'onsails/lspkind-nvim'       " Icons for nvim-cmp

" LSP
Plug 'neovim/nvim-lspconfig'

" Language Specific
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
Plug 'vim-scripts/c.vim', {'for': ['c', 'cpp']}
Plug 'ludwig/split-manpage.vim'
Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}

"*****************************************************************************
"" Custom bundles
"*****************************************************************************
if filereadable(expand("~/.config/nvim/local_bundles.vim"))
  source ~/.config/nvim/local_bundles.vim
endif

call plug#end()

" Required: Enable filetype detection, plugin loading, and indenting
filetype plugin indent on

"*****************************************************************************
"" Basic Setup
"*****************************************************************************"
set nocompatible " Be iMproved (should be early, vim-sensible might also set this)

set noswapfile

" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,ucs-bom,latin1

"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overridden by autocmd rules
set tabstop=4       " Number of visual spaces per TAB
set shiftwidth=4    " Number of spaces for autoindent
set softtabstop=4   " Number of spaces for TAB key in insert mode (acts like tabstop if expandtab is off)
set expandtab       " Use spaces instead of tabs
set autoindent      " Copy indent from current line when starting a new line
set smartindent     " Smarter auto indentation for C-like languages
set smarttab        " Insert `shiftwidth` number of spaces on tab at beginning of line

"" Wrapping - DISABLED GLOBALLY, ENABLE PER FILETYPE IF NEEDED
set nowrap          " Disable global line wrapping
set textwidth=0     " Setting textwidth to 0 disables automatic wrapping based on it

"" Map leader to \
let mapleader='\'
let maplocalleader=',' " Often useful for plugin-local mappings

"" Enable hidden buffers
set hidden

"" Searching
set hlsearch               " Highlight search results
set incsearch              " Show matches while typing
set ignorecase             " Ignore case in search
set smartcase              " Override ignorecase if search pattern has uppercase letters

set fileformats=unix,dos,mac " Order of preference for file formats

if exists('$SHELL')
  set shell=$SHELL
else
  set shell=/bin/sh
endif

" Session management (vim-session)
let g:session_directory = stdpath('data') . "/session" " Use standard path
let g:session_autoload = "no"
let g:session_autosave = "no"
let g:session_command_aliases = 1
if !isdirectory(g:session_directory)
    call mkdir(g:session_directory, 'p')
endif

"*****************************************************************************
"" Visual Settings
"*****************************************************************************
syntax on
set ruler                  " Show cursor position (bottom right)
set number                 " Show absolute line numbers

set shortmess+=c           " Don't pass messages to |ins-completion-menu|
set signcolumn=yes         " Always show signcolumn to prevent layout shifts

" GRUVBOX THEME settings
if has('termguicolors')
  set termguicolors        " Enable true colors if terminal supports it
endif
colorscheme gruvbox

" Better command line completion
set wildmenu

" Mouse support
set mouse=a                " Enable mouse in all modes

" Scrolling offset
set scrolloff=8            " Keep 8 lines above/below cursor
set sidescrolloff=5        " Keep 5 columns left/right of cursor

set t_Co=256               " Ensure 256 colors (CSApprox might handle this better for non-truecolor)
set guioptions=egmrti      " Default guioptions

if has("gui_running")
  if has("gui_mac") || has("gui_macvim")
    set guifont=Menlo:h12
  else
    set guifont=Monospace\ 10
  endif
else
  let g:CSApprox_loaded = 1
endif

"" IndentLine
let g:indentLine_enabled = 1
let g:indentLine_char = '▏'
let g:indentLine_concealcursor = ''
let g:indentLine_faster = 1

"" Disable the blinking cursor.
set guicursor=a:blinkon0

au TermEnter * setlocal scrolloff=10
au TermLeave * setlocal scrolloff=10

"" Status bar
set laststatus=2           " Always show status line

"" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

" Highlight current line (cursorline) and column (cursorcolumn)
set cursorline
set cursorcolumn
augroup CursorLineManagement
  autocmd!
  autocmd WinEnter,FocusGained * set cursorline cursorcolumn
  autocmd WinLeave,FocusLost   * set nocursorline nocursorcolumn
augroup END

" Search mappings: center on match
nnoremap n nzzzv
nnoremap N Nzzzv

" Completion options
set completeopt=menu,menuone,noselect,preview

"" vim-airline
let g:airline_theme = 'gruvbox'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_skip_empty_sections = 1

"" Abbreviations
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall

"" NERDTree configuration
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['node_modules','\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__', '\.git', '\.DS_Store']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeWinSize = 35
let g:NERDTreeWinPos = "left"
let g:NERDTreeShowLineNumbers=0
let g:NERDTreeMinimalUI = 1
let g:NERDTreeQuitOnOpen = 1
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite,*/node_modules/*,*/__pycache__/*,*.DS_Store
nnoremap <silent> <F3> :NERDTreeToggle<CR>
nnoremap <silent> <F2> :NERDTreeFind<CR>
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
autocmd VimEnter * if !argc() && empty(expand('%')) | Startify | endif

"" STARTIFY Configuration
let g:startify_lists = [
      \ { 'type': 'files',     'header': ['   Recent Files']            },
      \ { 'type': 'sessions',  'header': ['   Sessions']                },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']               },
      \ { 'type': [
      \     '   Edit Neovim Config  >>>  :edit $MYVIMRC',
      \     '   Source Neovim Config>>>  :source $MYVIMRC',
      \   ], 'header': ['   Commands'] },
      \ ]
let g:startify_bookmarks = [ expand('~/.config/nvim/init.vim') ]
let g:startify_session_dir = stdpath('data') . '/session'
let g:startify_padding_left = 2
let g:startify_padding_top = 2
let g:startify_enable_special = 1

"" terminal emulation
nnoremap <silent> <leader>sh :terminal<CR>

"" remove trailing whitespaces command
command! FixWhitespace :%s/\s\+$//e

"" Functions
if !exists('*s:setupTextFileWrapping')
  function s:setupTextFileWrapping()
    setlocal wrap linebreak nolist
    setlocal textwidth=100
    setlocal wm=2
  endfunction
endif

"" Autocmd Rules
augroup GlobalAutoCmds
  autocmd!
  autocmd BufWritePre *.py :%s/\s\+$//e
  autocmd BufEnter * :syntax sync maxlines=1000
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif
  autocmd BufRead,BufNewFile *.txt call s:setupTextFileWrapping()
  autocmd FileType make setlocal noexpandtab
  autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
  autocmd FocusGained,BufEnter * if mode() != 'c' | checktime | endif
augroup END

set autoread

"" Mappings

"" Split
noremap <Leader>h :<C-u>split<CR><C-w>j
noremap <Leader>v :<C-u>vsplit<CR><C-w>l

"" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Git commit --verbose<CR>
noremap <Leader>gsh :Git push<CR>
noremap <Leader>gll :Git pull<CR>
noremap <Leader>gs :Git<CR>
noremap <Leader>gb :Git blame<CR>
noremap <Leader>gd :Gvdiffsplit!<CR>
noremap <Leader>gr :GRemove<CR>
noremap <leader>gp :Git push<CR>
noremap <leader>G :Git fetch --all --prune<CR>

"" session management
nnoremap <leader>so :OpenSession<Space>
nnoremap <leader>ss :SaveSession<Space>
nnoremap <leader>sd :DeleteSession<CR>
nnoremap <leader>sc :CloseSession<CR>

"" Tabs
nnoremap <silent> <leader>tn :tabnew<CR>
nnoremap <silent> <leader>tc :tabclose<CR>
nnoremap <silent> <leader>to :tabonly<CR>
nnoremap <silent> <leader>tm :tabmove<Space>
nnoremap <silent> <S-Tab> gT
nnoremap <silent> <Tab> gt

"" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>:pwd<CR>

"" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>oe :e <C-R>=expand("%:p:h") . "/" <CR>

"" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>ot :tabe <C-R>=expand("%:p:h") . "/" <CR>

"" fzf.vim
if executable('fd')
  let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude target --exclude dist'
elseif executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*" --glob "!node_modules/*" --glob "!target/*" --glob "!dist/*"'
else
  let $FZF_DEFAULT_COMMAND =  "find . -type f \\( -path '*/\\.*' -o -path './node_modules/*' -o -path './target/*' -o -path './dist/*' \\) -prune -o -print -o -type l -print 2>/dev/null"
endif

if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
  set grepformat=%f:%l:%c:%m
endif

" FZF Mappings
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fg :Rg<CR>
nnoremap <silent> <leader>fb :Buffers<CR>
nnoremap <silent> <leader>fh :History<CR>

"" Recovery commands from history through FZF
nnoremap <leader>fy :History<CR>

"" ale - Linter
let g:ale_python_flake8_options = '--max-line-length=120 --ignore=E203,W503,E266'
let g:ale_python_pylint_options = '--max-line-length=120 --disable=all --enable=E,F,W0611,W0612,W0613,W0614'
let g:ale_linters = {
\   'python': ['flake8', 'pylint'],
\   'c': ['clangtidy', 'gcc'],
\   'cpp': ['clangtidy', 'g++'],
\   'javascript': ['eslint'],
\   'typescript': ['eslint'],
\   'lua': ['luacheck'],
\   'sh': ['shellcheck'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['autopep8', 'black', 'isort'],
\   'javascript': ['eslint', 'prettier'],
\   'typescript': ['eslint', 'prettier'],
\   'lua': ['stylua'],
\}
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 0
let g:airline#extensions#ale#enabled = 1

" ALE sign settings
let g:ale_sign_error = 'E'   " Simpler signs for ALE
let g:ale_sign_warning = 'W'
" Define highlight groups for ALE signs for consistency if ALE is placing them
highlight ALEErrorSign ctermfg=red guifg=Red
highlight ALEWarningSign ctermfg=yellow guifg=Yellow


"" Neoformat - Formatter
let g:neoformat_python_autopep8 = {
  \ 'exe': 'autopep8',
  \ 'args': ['--max-line-length', '120', '--ignore', 'E203,W503,E266'],
  \ 'stdin': 1,
\ }
let g:neoformat_enabled_python = ['autopep8']
" autocmd BufWritePre *.py Neoformat " Uncomment to enable Neoformat on save for Python

"" Disable visualbell
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"" Copy/Paste/Cut
if has('clipboard')
  set clipboard=unnamedplus,unnamed
endif
vnoremap <leader>y "+y
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p

"" Buffer nav
noremap <leader>z :bprevious<CR>
noremap <leader>x :bnext<CR>

nmap <F9> :bprevious<CR>
nmap <F10> :bnext<CR>

"" Close buffer
noremap <leader>bd :bd<CR>

"" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>

"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

"" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

"" Open current line on GitHub
nnoremap <Leader>o :.Gbrowse<CR>

"" Custom configs for filetypes
augroup FileTypeConfig
  autocmd!
  autocmd FileType c,cpp setlocal cindent tabstop=4 shiftwidth=4 expandtab colorcolumn=100
  autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab colorcolumn=100
  autocmd FileType json setlocal tabstop=2 shiftwidth=2 expandtab colorcolumn=100
  autocmd FileType markdown setlocal tabstop=2 shiftwidth=2 expandtab colorcolumn=100
  autocmd FileType html,css,javascript,typescript setlocal tabstop=2 shiftwidth=2 expandtab colorcolumn=100
  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4 colorcolumn=120
    \ softtabstop=4 cinwords=if,elif,else,for,while,try,except,finally,def,class,with
augroup END

"" vim-airline symbols
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
if !g:airline_powerline_fonts
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline_left_sep = '▶'
  let g:airline_left_alt_sep = '»'
  let g:airline_right_sep = '◀'
  let g:airline_right_alt_sep = '«'
  let g:airline_symbols.branch = '⎇'
  let g:airline_symbols.readonly = '⊘'
  let g:airline_symbols.linenr = '☰'
else
  let g:airline#extensions#tabline#left_sep = ''
  let g:airline#extensions#tabline#left_alt_sep = ''
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''
endif
let g:airline#extensions#virtualenv#enabled = 1

"" NERD Commenter
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_python = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '/**', 'right': '*/' } }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

"" Python-mode settings
let g:pymode_lint_ignore="E203,W503,E266"
let g:pymode_options_max_line_length=120
let g:pymode_warnings = 0
let g:pymode_trim_whitespaces = 0
let g:pymode_options = 0
let g:pymode_indent = 0
let g:pymode_folding = 0
let g:pymode_motion = 0
let g:pymode_doc = 0
let g:pymode_doc_bind = ''
let g:pymode_virtualenv = 1
let g:pymode_lint = 0
let g:pymode_rope = 0
let g:pymode_syntax = 1
let g:pymode_run = 1
let g:pymode_run_bind = '<leader>rr'
let g:pymode_breakpoint = 1
let g:pymode_breakpoint_bind = '<leader>bb'
let g:pymode_breakpoint_cmd = ''

"" Include user's local vim config
if filereadable(expand("~/.config/nvim/local_init.vim"))
  source ~/.config/nvim/local_init.vim
endif


lua <<EOF
-- Setup nvim-cmp.
local cmp = require'cmp'
local lspkind = require('lspkind')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer', keyword_length = 3 },
    { name = 'path' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
      ellipsis_char = '...',
    })
  }
})

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = 'buffer' } }
})
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, bufopts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
  vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, bufopts)
end

require('lspconfig')['pylsp'].setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    pylsp = {
      plugins = {
        flake8 = {
          enabled = true,
          maxLineLength = 120,
          ignore = {'E203', 'W503', 'E266'},
        },
        autopep8 = { enabled = false },
        black = { enabled = false },
        yapf = { enabled = false },
        jedi_completion = { enabled = true },
        jedi_definition = { enabled = true },
        jedi_hover = { enabled = true },
        jedi_references = { enabled = true },
        jedi_signature_help = { enabled = true },
        jedi_symbols = { enabled = true },
        pylint = { enabled = false },
        pycodestyle = { enabled = false }
      },
      configurationSources = {"flake8"}
    }
  }
}

require('lspconfig')['clangd'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = {"clangd", "--offset-encoding=utf-16"},
}

-- Define colors for diagnostic levels
vim.cmd("highlight default link DiagnosticError ErrorMsg")
vim.cmd("highlight default link DiagnosticWarn WarningMsg")
vim.cmd("highlight default link DiagnosticInfo Information") -- Or a custom group
vim.cmd("highlight default link DiagnosticHint HintMsg") -- Or a custom group

-- Use standard Neovim diagnostic highlight groups for the sign text color
vim.fn.sign_define("DiagnosticSignError", {text = "E", texthl = "DiagnosticError"})
vim.fn.sign_define("DiagnosticSignWarn",  {text = "W", texthl = "DiagnosticWarn"})
vim.fn.sign_define("DiagnosticSignInfo",  {text = "I", texthl = "DiagnosticInfo"})
vim.fn.sign_define("DiagnosticSignHint",  {text = "H", texthl = "DiagnosticHint"})

vim.diagnostic.config({
    virtual_text = false,
    signs = true, -- This enables the signs defined above
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})

EOF
