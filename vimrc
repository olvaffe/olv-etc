set nocompatible
filetype on
filetype plugin on
filetype indent on

set viminfofile=~/.vim/viminfo
set directory=~/.vim

" color settings
syntax on
colorscheme base16-hcl007070
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" view settings
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

augroup filetype_indent
  au!
  au FileType vim setl sw=2 sts=2
augroup END
