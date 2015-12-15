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

nmap <F5> :make<CR>

au BufNewFile,BufRead SConstruct,SConscript :setl ft=python

au FileType python,cmake :setl sw=4 sts=4 et
au FileType vim :setl sw=2 sts=2
au FileType c,cpp :call ApplyCStyles()
fun! ApplyCStyles()
  let path = expand("%:p")

  " Mesa
  if path =~ "/mesa"
    setl sw=3 sts=3 et
  " Khronos
  elseif path =~ "/khronos"
    setl sw=4 sts=4 et
  endif
endfun
