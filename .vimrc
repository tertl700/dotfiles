syntax on

colorscheme smyck

"------------------
" Syntax and indent
"------------------
syntax on " turn on syntax highlighting
set showmatch " show matching braces when text indicator is over them

"---------------------
" Basic editing config
"---------------------
set nu  " set number lines
set autoindent
set smartindent 
set mouse+=a " enable mouse mode (scrolling, selection, etc)
set ignorecase
set smartcase " searching only case-sensitive for uppercase
set lbr
set tabstop=4 " make tab appear 4 spaces
set shiftwidth=4
set softtabstop=0 noexpandtab

autocmd BufNewFile,BufRead .aliases set syntax=zsh
