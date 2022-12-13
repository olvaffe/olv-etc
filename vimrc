set nocompatible
filetype on
filetype plugin on
filetype indent on

set viminfofile=~/.vim/viminfo
set directory=~/.vim

" view settings
syntax on
colorscheme desert
set nowrap
set ruler
set encoding=utf8
set scrolloff=2

" search settings
set nohls

" edit settings
set textwidth=78
set backspace=indent,eol,start
set autoindent
set copyindent

" programming settings
set tags=./tags;
set cino=:0,l1,t0,W1
let c_space_errors=1

" plugin settings
let g:EditorConfig_max_line_indicator = "none"

augroup filetype_fix
  au!
  au BufNewFile,BufRead SConstruct,SConscript setl ft=python
  au BufNewFile,BufRead Android.bp setl ft=go
augroup END

augroup filetype_indent
  au!
  au FileType c,cpp,cmake,groovy,java setl sw=4 sts=4 et
  au FileType vim setl sw=2 sts=2
augroup END
