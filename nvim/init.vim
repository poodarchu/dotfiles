" vim-plug: Vim plugin manager
" ============================
" (Instructions unchanged)

"*****************************************************************************
"" Vim-Plug core
"*****************************************************************************
let vimplug_autoload_path = stdpath('data') . '/site/autoload/plug.vim'
let vimplug_plugged_path = stdpath('data') . '/plugged'

if empty(glob(vimplug_autoload_path))
  if !executable('curl')
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent execute '!curl -fLo ' . shellescape(vimplug_autoload_path) . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  let g:not_finish_vimplug = "yes"
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(vimplug_plugged_path)

"*****************************************************************************
"" Plug install packages
"*****************************************************************************
Plug 'tpope/vim-sensible'

Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'scrooloose/nerdcommenter'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'airblade/vim-gitgutter'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'
Plug 'Yggdroot/indentLine'
Plug 'mhinz/vim-startify'

Plug 'jiangmiao/auto-pairs'

if isdirectory('/usr/local/opt/fzf')
  Plug '/usr/local/opt/fzf'
  Plug 'junegunn/fzf.vim'
else
  Plug 'junegunn/fzf', { 'do': './install --bin' }
  Plug 'junegunn/fzf.vim'
endif

Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'

Plug 'hrsh7th/vim-vsnip'
Plug 'rafamadriz/friendly-snippets'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-vsnip'
Plug 'onsails/lspkind-nvim'

Plug 'neovim/nvim-lspconfig'

Plug 'ludwig/split-manpage.vim'
Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}

"*****************************************************************************
"" Custom bundles
"*****************************************************************************
if filereadable(expand("~/.config/nvim/local_bundles.vim"))
  source ~/.config/nvim/local_bundles.vim
endif

call plug#end()

filetype plugin indent on

"*****************************************************************************
"" Basic Setup
"*****************************************************************************"
set nocompatible
set noswapfile
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,ucs-bom,latin1
set backspace=indent,eol,start
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smartindent
set smarttab
set nowrap
set textwidth=0
let mapleader='\'
let maplocalleader=','
set hidden
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

let g:session_directory = stdpath('data') . "/session"
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
set ruler
set number
set shortmess+=c
set signcolumn=yes

if has('termguicolors')
  set termguicolors
endif
colorscheme gruvbox

set wildmenu
set mouse=a
set scrolloff=8
set sidescrolloff=5
set t_Co=256 " Keep as a fallback or if specific colors are needed beyond termguicolors for some contexts
set guioptions=egmrti

if has("gui_running")
  if has("gui_mac") || has("gui_macvim")
    set guifont=Menlo:h12
  else
    set guifont=Monospace\ 10
  endif
" Removed CSApprox specific line here
endif

let g:indentLine_enabled = 1
let g:indentLine_char = '▏'
let g:indentLine_concealcursor = ''
let g:indentLine_faster = 1
set guicursor=a:blinkon0
au TermEnter * setlocal scrolloff=10
au TermLeave * setlocal scrolloff=10
set laststatus=2
set modeline
set modelines=10
set title
set titleold="Terminal"
set titlestring=%F
set cursorline
set cursorcolumn

augroup CursorLineManagement
  autocmd!
  autocmd WinEnter,FocusGained * set cursorline cursorcolumn
  autocmd WinLeave,FocusLost   * set nocursorline nocursorcolumn
augroup END

nnoremap n nzzzv
nnoremap N Nzzzv
set completeopt=menu,menuone,noselect,preview

"" vim-airline
let g:airline_theme = 'gruvbox'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 0 " Set to 1 for Powerline/Nerd Fonts

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

if !g:airline_powerline_fonts
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline_left_sep = '>'
  let g:airline_left_alt_sep = '>>'
  let g:airline_right_sep = '<'
  let g:airline_right_alt_sep = '<<'
  let g:airline_symbols.branch = 'git:'
  let g:airline_symbols.readonly = '[RO]'
  let g:airline_symbols.linenr = 'L:'
  let g:airline_symbols.maxlinenr = ''
  let g:airline_symbols.dirty = '*'
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
  let g:airline_symbols.dirty = '⚡'
endif
let g:airline#extensions#virtualenv#enabled = 1
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
      \ { 'type': 'files',     'header': ['   Recent Files']                 },
      \ { 'type': 'sessions',  'header': ['   Sessions']                     },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']                    },
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

"" Run current Python file
nnoremap <leader>rr :execute 'terminal python3 ' . shellescape(expand('%'))<CR>

"" Trailing Whitespace Highlighting and Auto-trimming
augroup TrailingWhitespace
  autocmd!
  " Highlight trailing whitespace with a red background.
  " Using a specific hex for guibg and 'Red' for ctermbg which gruvbox should handle.
  autocmd ColorScheme * highlight TrailingSpace guibg=#FF5555 ctermbg=Red
  autocmd VimEnter,WinEnter,ColorScheme * match TrailingSpace /\s\+$/
  " Automatically remove trailing whitespace on save
  autocmd BufWritePre * :%s/\s\+$//e
augroup END

"" Functions
if !exists('*s:setupTextFileWrapping')
  function s:setupTextFileWrapping()
    setlocal wrap linebreak nolist
    setlocal textwidth=100
    setlocal wm=2
  endfunction
endif

"" Python PDB Breakpoint Toggle
function! TogglePdbAbove()
  let current_line_nr = line('.')
  let current_indent = matchstr(getline(current_line_nr), '^\s*')
  " Added a comment to the pdb line for clarity when reading code
  let pdb_line = current_indent . "import pdb; pdb.set_trace()  # Breakpoint"

  if current_line_nr == 1
    let line_content_1 = getline(1)
    if trim(line_content_1) == trim(pdb_line) " Check if line 1 is already the breakpoint
      silent 1delete
      echom "Breakpoint removed from line 1."
    else " Add breakpoint at the top
      call append(0, pdb_line)
      echom "Breakpoint added at new line 1 (above original line 1)."
    endif
  else
    let line_above_nr = current_line_nr - 1
    let line_above_content = getline(line_above_nr)
    if trim(line_above_content) == trim(pdb_line) " Check if line above is the breakpoint
      execute line_above_nr . 'delete'
      echom "Breakpoint removed from line " . line_above_nr . "."
    else " Add breakpoint above current line
      call append(line_above_nr, pdb_line)
      echom "Breakpoint added on line " . line_above_nr . " (above current)."
    endif
  endif
endfunction
nnoremap <leader>b :call TogglePdbAbove()<CR>


"" Autocmd Rules
augroup GlobalAutoCmds
  autocmd!
  autocmd BufEnter * :syntax sync maxlines=1000
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif
  autocmd BufRead,BufNewFile *.txt call s:setupTextFileWrapping()
  autocmd FileType make setlocal noexpandtab
  autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
  autocmd FocusGained,BufEnter * if mode() != 'c' | checktime | endif
augroup END

set autoread

"" Mappings (General - selected, most are unchanged)
noremap <Leader>h :<C-u>split<CR><C-w>j
noremap <Leader>v :<C-u>vsplit<CR><C-w>l
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
nnoremap <leader>so :OpenSession<Space>
nnoremap <leader>ss :SaveSession<Space>
nnoremap <leader>sd :DeleteSession<CR>
nnoremap <leader>sc :CloseSession<CR>
nnoremap <silent> <leader>tn :tabnew<CR>
nnoremap <silent> <leader>tc :tabclose<CR>
nnoremap <silent> <leader>to :tabonly<CR>
nnoremap <silent> <leader>tm :tabmove<Space>
nnoremap <silent> <S-Tab> gT
nnoremap <silent> <Tab> gt
nnoremap <leader>. :lcd %:p:h<CR>:pwd<CR>
noremap <Leader>oe :e <C-R>=expand("%:p:h") . "/" <CR>
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

nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fg :Rg<CR>
nnoremap <silent> <leader>fb :Buffers<CR>
nnoremap <silent> <leader>fh :History<CR>
nnoremap <leader>fy :History<CR> " Note: <leader>fy was same as <leader>fh, kept for consistency if intended


"" Disable visualbell
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"" Copy/Paste/Cut
if has('clipboard')
  set clipboard=unnamedplus,unnamed " Consider 'unnamedplus' alone if 'unnamed' causes issues with primary selection
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
  autocmd FileType c,cpp setlocal cindent tabstop=4 shiftwidth=4 expandtab colorcolumn=100 " cindent is built-in, works fine with clangd
  autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab colorcolumn=100
  autocmd FileType json setlocal tabstop=2 shiftwidth=2 expandtab colorcolumn=100
  autocmd FileType markdown setlocal tabstop=2 shiftwidth=2 expandtab colorcolumn=100
  autocmd FileType html,css,javascript,typescript setlocal tabstop=2 shiftwidth=2 expandtab colorcolumn=100
  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4 colorcolumn=120 softtabstop=4 cinwords=if,elif,else,for,while,try,except,finally,def,class,with
augroup END

"" NERD Commenter
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_python = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '/**', 'right': '*/' } }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

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
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts) -- Note: C-k for signature_help might conflict with some terminal emulators or window managers.
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

  -- NEW: Manual LSP formatting command
  if client.supports_method("textDocument/formatting") then
    vim.keymap.set({'n', 'v'}, '<leader>fm', function()
        vim.lsp.buf.format({ async = true, timeout_ms = 5000 }) -- Use async for non-blocking format
        print("LSP formatting requested...")
      end, bufopts)
  end

  -- REMOVED: LSP Formatting on Save (BufWritePre)
  -- Auto-formatting on save is now disabled. Use <leader>fm to format manually.
end

require('lspconfig')['pylsp'].setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    pylsp = {
      -- Explicitly set pycodestyle maxLineLength for autopep8 (formatter).
      -- NOTE: If formatting still defaults to 80 columns, check for project-specific
      -- configuration files (e.g., pyproject.toml, setup.cfg, .flake8, .autopep8)
      -- as they might override this global setting.
      pycodestyle = {
        maxLineLength = 120
      },
      plugins = {
        flake8 = {
          enabled = true,
          maxLineLength = 120, -- For flake8 linter
          ignore = {'E203', 'W503', 'E266'},
        },
        pylint = {
          enabled = true,
          args = {"--max-line-length=120", "--disable=all", "--enable=E,F,W0611,W0612,W0613,W0614"}, -- For pylint linter
        },
        autopep8 = { -- For formatting
          enabled = true,
          -- autopep8 should pick up maxLineLength from the global pylsp.pycodestyle setting above.
        },
        isort = { -- For import sorting
          enabled = true,
        },
        jedi_completion = { enabled = true },
        jedi_definition = { enabled = true },
        jedi_hover = { enabled = true },
        jedi_references = { enabled = true },
        jedi_signature_help = { enabled = true },
        jedi_symbols = { enabled = true },
        pycodestyle = { enabled = false }, -- Linting plugin for pycodestyle; covered by flake8
        rope = { enabled = false }
      },
      configurationSources = {"flake8"} -- Allows project-specific .flake8 to influence pylsp
    }
  }
}

require('lspconfig')['clangd'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = {"clangd", "--offset-encoding=utf-16"},
    -- For clangd, formatting style is typically controlled by a .clang-format file in your project root.
}

vim.cmd("highlight default link DiagnosticError ErrorMsg")
vim.cmd("highlight default link DiagnosticWarn WarningMsg")
vim.cmd("highlight default link DiagnosticInfo Information")
vim.cmd("highlight default link DiagnosticHint HintMsg")

vim.fn.sign_define("DiagnosticSignError", {text = "E", texthl = "DiagnosticError"})
vim.fn.sign_define("DiagnosticSignWarn",  {text = "W", texthl = "DiagnosticWarn"})
vim.fn.sign_define("DiagnosticSignInfo",  {text = "I", texthl = "DiagnosticInfo"})
vim.fn.sign_define("DiagnosticSignHint",  {text = "H", texthl = "DiagnosticHint"})

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
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
