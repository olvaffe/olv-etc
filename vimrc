set nocompatible
filetype on
filetype plugin on
filetype indent on

" view settings
syntax on
colorscheme delek
set nowrap
set ruler
set vb
set encoding=utf8
set textwidth=78

" search settings
set nohls

" edit settings
set pastetoggle=<F10>
set backspace=indent,eol,start
set autoindent
set copyindent

" programming settings
set tags=./tags;
set cino=:0,l1,t0,W1
let c_space_errors=1

nmap <F5>  :make<CR>

fun! Style3Spaces()
	set sw=3 sts=3 et
endfun

fun! Style4Spaces()
	set sw=4 sts=4 et
endfun

au BufNewFile,BufRead SConstruct,SConscript :set ft=python

au FileType python :call Style4Spaces()
au FileType cmake :call Style4Spaces()

au BufNewFile,BufRead ~/*/mesa/*.[ch],~/*/mesa/*.cpp :call Style3Spaces()
