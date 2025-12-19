lua vim.loader.enable()

" File Format
set encoding=UTF-8
set fileformat=unix
set fileformats=unix

" Mouse Support
set mouse=a

" 24Bit Terminal Colors
set termguicolors

" CursorLine Support
set nowrap
set cursorline
set scrolloff=10

" Internal UpdateTime
set updatetime=500

" Always active StatusLine
set laststatus=2

" Search Support
set incsearch
set ignorecase
set smartcase

set showmatch

" Tab Support
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent

" NumberLine Support
set number
set relativenumber
set noequalalways

set list
set listchars=tab:│\ ,space:\ ,trail:\ 

set noswapfile

set signcolumn=yes

set hidden

set noerrorbells
set novisualbell
set t_vb=
set tm=500

set shadafile=NONE

set clipboard=unnamed,unnamedplus

set shortmess+=c
set shortmess+=I

" Mappings
nnoremap <silent> <A-Right> :wincmd l<CR>
nnoremap <silent> <A-Left> :wincmd h<CR>
nnoremap <silent> <A-Up> :wincmd k<CR>
nnoremap <silent> <A-Down> :wincmd j<CR>
nnoremap <silent> <A-l> :wincmd l<CR>
nnoremap <silent> <A-h> :wincmd h<CR>
nnoremap <silent> <A-k> :wincmd k<CR>
nnoremap <silent> <A-j> :wincmd j<CR>

nnoremap <silent> <A-<> <C-w><
nnoremap <silent> <A->> <C-w>>

nnoremap <silent> <C-Right> w
nnoremap <silent> <C-Left> b
nnoremap <silent> <S-Up> <C-u>
nnoremap <silent> <S-Down> <C-d>

vnoremap <silent> < <gv
vnoremap <silent> > >gv

tnoremap <silent> <ESC> <C-\><C-n>

if has("win32") || has("win64")
    set shell=C:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe
    set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
    set shellquote=
    set shellxquote=

    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

if exists("g:neovide")
    set guifont=KawaiiMono
    set termguicolors
    set mousemodel=extend
    
    autocmd VimEnter * execute 'cd ' . fnameescape(stdpath('config'))
endif

" Load Neovim Plugins
call defines#load()
call packages#load()
call plugins#load()

colorscheme onedark

