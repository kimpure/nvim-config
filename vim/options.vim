set encoding=UTF-8
set fileformat=unix
set fileformats=unix
set clipboard=unnamedplus
set mouse+=a
set termguicolors
set background=dark
set nowrap
set cursorline
set scrolloff=10
set updatetime=500
set laststatus=2

set incsearch
set ignorecase
set smartcase

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent

set number
set relativenumber
set cmdheight=0
set noshowmatch
set noequalalways

set shadafile=NONE
set noswapfile

set signcolumn=yes
set background=dark

set fillchars=eob:\ ,fold:\ ,foldopen:,foldsep:\ ,foldclose:

set foldcolumn=0
set foldlevel=99
set foldlevelstart=99
set foldenable

set list
set listchars=tab:│\ ,space:\ ,trail:\ 

if exists("g:neovide")
    set guifont=KawaiiMono

    if isdirectory(expand("~/dev"))
        autocmd VimEnter * cd ~/dev
    else
        autocmd VimEnter * cd ~
    endif
endif

if has("win32") || has("win64")
    set shell=C:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe
    set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
    set shellquote=
    set shellxquote=
endif
