set nocompatible
filetype plugin on
filetype indent on

" view settings
set nowrap
set ruler
set vb
set fenc=utf8
set fencs=utf8,big5,iso8859-1
set textwidth=78
syntax on
colorscheme delek

" search settings
nohl

" edit settings
set pt=<F10>
set bs=2
set autoindent
set copyindent

" programming settings
set tags+=./tags;
set cino=:0,l1,t0,(0
let c_space_errors=1

nmap <F5>  :make<CR>
nmap <F6>  :!./%<<CR>

au BufNewFile,BufRead SConstruct,SConscript :set ft=python

" coding styles

au FileType python set sw=4 sts=4 et

fun! Style4Spaces()
	set sw=4 sts=4 et
endfun
au BufNewFile,BufRead ~/fdo/piglit/*.[ch] :call Style4Spaces()
au BufNewFile,BufRead ~/projects/apitrace/*.[ch]pp :call Style4Spaces()
au BufNewFile,BufRead ~/google/gingerbread*/*.[ch],~/google/gingerbread*/*.cpp :call Style4Spaces()

fun! Style3Spaces()
	set sw=3 sts=3 et
endfun
au BufNewFile,BufRead ~/*/mesa/*.[ch],~/*/mesa/*.cpp :call Style3Spaces()
