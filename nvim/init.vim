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
"     :PlugInstall to install plugins
"     :PlugUpdate  to update plugins
"     :PlugDiff    to review the changes from the last update
"     :PlugClean   to remove plugins no longer in the list
"
" For more information, see https://github.com/junegunn/vim-plug
"

"*****************************************************************************
"" Vim-Plug core
"*****************************************************************************
let vimplug_exists=expand('~/.config/nvim/autoload/plug.vim')
let curl_exists=expand('curl')

let g:vim_bootstrap_langs = "c,python"
let g:vim_bootstrap_editor = "nvim"				" nvim or vim
let g:vim_bootstrap_theme = "gruvbox"
let g:vim_bootstrap_frams = ""

if !filereadable(vimplug_exists)
  if !executable(curl_exists)
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent exec "!"curl_exists" -fLo " . shellescape(vimplug_exists) . " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif

" Required:
call plug#begin(expand('~/.config/nvim/plugged'))

"*****************************************************************************
"" Plug install packages
"*****************************************************************************
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'scrooloose/nerdcommenter'
Plug 'sbdchd/neoformat'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" -- REFINED: Removed 'crispgm/nvim-tabline' as vim-airline's tabline is enabled and sufficient.
Plug 'airblade/vim-gitgutter'
" -- REFINED: Removed 'vim-scripts/grep.vim'. :Rg from fzf.vim + ripgrep is more powerful.
Plug 'vim-scripts/CSApprox'
Plug 'jiangmiao/auto-pairs'
Plug 'dense-analysis/ale' " -- REFINED: Kept for generic fixers; Python linting primarily via LSP.
Plug 'Yggdroot/indentLine'
Plug 'editor-bootstrap/vim-bootstrap-updater'
Plug 'tpope/vim-rhubarb' " required by fugitive to :Gbrowse
Plug 'morhetz/gruvbox'
Plug 'mhinz/vim-startify'
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' } " -- REFINED: Kept for specific features like :PyRun and breakpoints. Overlapping features are disabled below.

if isdirectory('/usr/local/opt/fzf')
  Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
else
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
  Plug 'junegunn/fzf.vim'
endif

let g:make = 'gmake'
if executable('make')
        let g:make = 'make'
endif

Plug 'Shougo/vimproc.vim', {'do': g:make}

"" Vim-Session
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'

"" Snippets
" -- REFINED: Removed 'SirVer/ultisnips' and 'honza/vim-snippets'.
" -- REFINED: nvim-cmp is configured to use vim-vsnip.
" -- REFINED: ACTION REQUIRED: Add a vsnip snippet collection if you haven't, e.g.:
" Plug 'rafamadriz/friendly-snippets'

""" Auto Completion & LSP """
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

"*****************************************************************************
"" Custom bundles
"*****************************************************************************

" c
Plug 'vim-scripts/c.vim', {'for': ['c', 'cpp']}
Plug 'ludwig/split-manpage.vim'


" python
"" Python Bundle
Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}


"*****************************************************************************
"*****************************************************************************

"" Include user's extra bundle
if filereadable(expand("~/.config/nvim/local_bundles.vim"))
  source ~/.config/nvim/local_bundles.vim
endif

call plug#end()

" Required:
filetype plugin indent on


"*****************************************************************************
"" Basic Setup
"*****************************************************************************"

set noswapfile

" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8


"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overridden by autocmd rules
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smarttab

"" Map leader to \
let mapleader='\'

"" Enable hidden buffers
set hidden

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

set fileformats=unix,dos,mac

if exists('$SHELL')
    set shell=$SHELL
else
    set shell=/bin/sh
endif

" session management
let g:session_directory = expand("~/.config/nvim/session")
let g:session_autoload = "no"
let g:session_autosave = "no"
let g:session_command_aliases = 1

"*****************************************************************************
"" Visual Settings
"*****************************************************************************
syntax on
set ruler
set number

let no_buffers_menu=1
colorscheme gruvbox

" Better command line completion
set wildmenu

" mouse support
set mouse=a " Changed to 'a' for all modes
set scrolloff=15

set t_Co=256
set guioptions=egmrti
set gfn=Monospace\ 10

if has("gui_running")
  if has("gui_mac") || has("gui_macvim")
    set guifont=Menlo:h12
    set transparency=7
  endif
else
  let g:CSApprox_loaded = 1

  " IndentLine
  let g:indentLine_enabled = 1
  let g:indentLine_concealcursor = ''
  let g:indentLine_char = '┆'
  let g:indentLine_faster = 1
endif

"" Disable the blinking cursor.
set guicursor=a:blinkon0

au TermEnter * setlocal scrolloff=10
au TermLeave * setlocal scrolloff=10


"" Status bar
set laststatus=2

"" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\

set guifont=Menlo\ Regular:h18

" highlight current line
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline cursorcolumn

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

if exists("*fugitive#statusline")
  set statusline+=%{fugitive#statusline()}
endif

set completeopt=menu,menuone,noselect,preview " Added preview

"" vim-airline
let g:airline_theme = 'powerlineish'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#ale#enabled = 1 " For ALE integration with airline
let g:airline#extensions#tabline#enabled = 1 " Airline will handle the tabline
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
let g:NERDTreeIgnore=['node_modules','\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__', '\.git']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 40
let g:NERDTreeWinPos = "right"
let g:NERDTreeShowLineNumbers=1
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite,*/node_modules/*,*/__pycache__/*
nnoremap <silent> <F2> :NERDTreeFind<CR>
nnoremap <silent> <F3> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd VimEnter * if !argc() | NERDTree | wincmd p | endif


"" -- REFINED: grep.vim settings removed.
"" nnoremap <silent> <leader>f :Rgrep<CR> -- REFINED: Re-mapped below to use :Rg
"" let Grep_Default_Options = '-IR'
"" let Grep_Skip_Files = '*.log *.db'
"" let Grep_Skip_Dirs = '.git node_modules __pycache__'

"" terminal emulation
nnoremap <silent> <leader>sh :terminal<CR>


"" remove trailing whitespaces
command! FixWhitespace :%s/\s\+$//e

"" Functions
if !exists('*s:setupWrapping')
  function s:setupWrapping()
    set wrap linebreak wm=2 textwidth=120 " Added linebreak
  endfunction
endif

"" Autocmd Rules
augroup auto-remove-trailing-spaces-py
    autocmd!
    autocmd BufWritePre *.py :%s/\s\+$//e
augroup END

augroup vimrc-sync-fromstart
  autocmd!
  autocmd BufEnter * :syntax sync maxlines=1000
augroup END

augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif
augroup END

augroup vimrc-wrapping
  autocmd!
  autocmd BufRead,BufNewFile *.txt call s:setupWrapping()
augroup END

augroup vimrc-make-cmake
  autocmd!
  autocmd FileType make setlocal noexpandtab
  autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
augroup END

set autoread

"" Mappings

"" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Git commit --verbose<CR>
noremap <Leader>gsh :Git push<CR>
noremap <Leader>gll :Git pull<CR>
noremap <Leader>gs :Git<CR>
noremap <Leader>gb :Git blame<CR>
noremap <Leader>gd :Gvdiffsplit<CR>
noremap <Leader>gr :GRemove<CR>

"" session management
nnoremap <leader>so :OpenSession<Space>
nnoremap <leader>ss :SaveSession<Space>
nnoremap <leader>sd :DeleteSession<CR>
nnoremap <leader>sc :CloseSession<CR>

"" Tabs
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

"" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>

"" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

"" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

"" fzf.vim
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,*/__pycache__/*,"*/node_modules/*"
if executable('fd')
  let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git --exclude node_modules'
elseif executable('find')
  let $FZF_DEFAULT_COMMAND =  "find . -type f \( -path '*/\.*' -o -path './node_modules/*' -o -path './target/*' -o -path './dist/*' \) -prune -o -print -o -type l -print 2>/dev/null"
endif

"" The Silver Searcher
if executable('ag')
  " -- REFINED: FZF_DEFAULT_COMMAND is set above based on fd or find. This ag setting might override it if ag is found.
  " -- REFINED: Consider if you want 'ag' to be the default for FZF file finding or just for grepprg.
  " -- REFINED: If you prefer rg for file finding (as set below), you might comment out the next line.
  let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
  set grepprg=ag\ --nogroup\ --nocolor\ --vimgrep
endif

"" ripgrep
if executable('rg')
  " -- REFINED: This will override FZF_DEFAULT_COMMAND if rg is found, making it the default for FZF file listing.
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Rg call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1, <bang>0)
  nnoremap <leader>fr :Rg<CR>
  " -- REFINED: Re-mapped <leader>f to also use :Rg for consistency
  nnoremap <silent> <leader>f :Rg<CR>
endif

cnoremap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>e :FZF -m<CR> " FZF for files (uses $FZF_DEFAULT_COMMAND)


"" Recovery commands from history through FZF
nmap <leader>y :History:<CR>


"" -- REFINED: UltiSnips settings removed as UltiSnips plugin is removed.
"" -- REFINED: Snippet expansion and navigation are now handled by nvim-cmp and vim-vsnip.
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<tab>"
" let g:UltiSnipsJumpBackwardTrigger="<c-b>"
" let g:UltiSnipsEditSplit="vertical"

"" ale
" -- REFINED: Explicitly disabling ALE linters for Python, assuming LSP will handle it.
" -- REFINED: If you want ALE for specific Python linters alongside LSP, adjust this.
let g:ale_linters = {'python': []} " Explicitly empty for python to defer to LSP
let g:ale_linters_explicit = 1
let g:ale_fixers = {'*': ['remove_trailing_lines', 'trim_whitespace']}
" let g:ale_fix_on_save = 1 " Keep this commented if you prefer manual fixing or LSP formatting on save

"" Disable visualbell
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"" Copy/Paste/Cut
if has('clipboard')
  set clipboard=unnamed,unnamedplus
endif

noremap YY "+y<CR>
noremap <leader>p "+gP<CR>
noremap XX "+x<CR>

if has('macunix')
  vmap <C-x> :!pbcopy<CR>
  vmap <C-c> :w !pbcopy<CR><CR>
endif

"" Buffer nav
noremap <leader>z :bprevious<CR>
noremap <leader>q :bprevious<CR>
noremap <leader>x :bnext<CR>
noremap <leader>w :bnext<CR>

nmap <F9> :bprevious<CR>
nmap <F10> :bnext<CR>

"" Close buffer
noremap <leader>c :bd<CR>

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

"" Custom configs

"" c
autocmd FileType c setlocal cindent tabstop=4 shiftwidth=4 expandtab
autocmd FileType cpp setlocal cindent tabstop=4 shiftwidth=4 expandtab

autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab

"" python
augroup vimrc-python
  autocmd!
  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4 colorcolumn=120 formatoptions+=cq softtabstop=4
      \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
augroup END

"" vim-airline
let g:airline#extensions#virtualenv#enabled = 1


"" Include user's local vim config
if filereadable(expand("~/.config/nvim/local_init.vim"))
  source ~/.config/nvim/local_init.vim
endif

"" Convenience variables

"" vim-airline symbols
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

if !get(g:, 'airline_powerline_fonts', 0)
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline_left_sep          = '▶'
  let g:airline_left_alt_sep      = '»'
  let g:airline_right_sep         = '◀'
  let g:airline_right_alt_sep     = '«'
  let g:airline#extensions#branch#prefix     = '⤴'
  let g:airline#extensions#readonly#symbol   = '⊘'
  let g:airline#extensions#linecolumn#prefix = '¶'
  let g:airline#extensions#paste#symbol      = 'ρ'
  let g:airline_symbols.crypt     = '🔒'
  let g:airline_symbols.linenr    = '☰'
  let g:airline_symbols.maxlinenr = '㏑'
  let g:airline_symbols.branch    = '⎇'
  let g:airline_symbols.paste     = 'ρ'
  let g:airline_symbols.whitespace = 'Ξ'
  let g:airline_symbols.spell     = 'Ꞩ'
  let g:airline_symbols.notexists = 'Ɇ'
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


"" NERD Commenter
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_python = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1


"" Neoformat
" -- REFINED: Custom Neoformat settings for Python using autopep8 with specific arguments
let g:neoformat_python_autopep8 = {
    \ 'exe': 'autopep8',
    \ 'args': ['--ignore=E226,E302,E41,E722,E731,W504,W503', '--max-line-length=120'],
    \ 'stdin': 1
    \ }
let g:neoformat_enabled_python = ['autopep8'] " Ensure autopep8 is the formatter for python

"" Python-mode settings
" -- REFINED: These settings ensure python-mode doesn't overlap with LSP for core dev features
let g:pymode = 1
let g:pymode_warnings = 0         " Disable pymode's own warnings
let g:pymode_trim_whitespaces = 0 " Let other tools handle this if needed
let g:pymode_options = 0          " Disable pymode options menu
let g:pymode_indent = 0           " Disable pymode's indenting
let g:pymode_folding = 0          " Disable pymode's folding
let g:pymode_motion = 0           " Disable pymode's motions
let g:pymode_doc = 0              " Disable pymode's documentation feature
let g:pymode_doc_bind = ''        " Unbind K if it was for pymode
let g:pymode_virtualenv = 0       " Disable pymode's virtualenv support (can be handled externally)
let g:pymode_lint = 0             " Disable pymode's linting (LSP/ALE)
let g:pymode_rope = 0             " Disable pymode's rope integration
let g:pymode_syntax = 0           " Disable pymode's syntax checking

" -- REFINED: Features from python-mode we are keeping:
let g:pymode_run = 1              " Enable running python code
let g:pymode_run_bind = '<leader>rr'
let g:pymode_breakpoint = 1       " Enable breakpoint features
let g:pymode_breakpoint_bind = '<leader>bb'
let g:pymode_breakpoint_cmd = ''  " Default breakpoint command


lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
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
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- Ensure vsnip is a source
    }, {
      { name = 'buffer' },
      { name = 'path' },
    })
  })

  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- If you have cmp-git or similar
    }, {
      { name = 'buffer' },
    })
  })

  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } }
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } })
  })

  -- Setup lspconfig.
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  -- Define on_attach function for LSP keybindings
  local on_attach = function(client, bufnr)
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', '<leader>d', vim.lsp.buf.definition, bufopts) -- Key for go-to-definition
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)                -- Key for hover documentation
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, bufopts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, bufopts)

    if client.supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<leader>fm", function() vim.lsp.buf.format { async = true } end, bufopts)
    end
  end

  -- REFINED: pylsp configuration with flake8 for diagnostics
  require('lspconfig')['pylsp'].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      pylsp = {
        plugins = {
          flake8 = {
            enabled = true,
            ignore = {'E226', 'E302', 'E41', 'E722', 'E731', 'W504', 'W503'},
            maxLineLength = 120
          },
          -- autopep8 = { enabled = false }, -- Ensure pylsp's autopep8 is off if you use Neoformat
          -- black = { enabled = false },    -- Ensure pylsp's black is off if you use Neoformat
          -- mypy = { enabled = true, live_mode = true }, -- You can enable mypy if desired
          jedi_completion = { enabled = true }, -- pylsp uses jedi internally
          jedi_definition = { enabled = true },
          jedi_hover = { enabled = true },
          jedi_references = { enabled = true },
          jedi_signature_help = { enabled = true },
          jedi_symbols = { enabled = true }
        }
      }
    }
  }
EOF
