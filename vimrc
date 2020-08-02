set nocompatible
filetype on
filetype plugin on
filetype indent on

" view settings
syntax on
colorscheme desert
set nowrap
set ruler
set encoding=utf8
set scrolloff=2

" search settings
set ignorecase
set smartcase
set nohls

" edit settings
set textwidth=78
set pastetoggle=<F10>
set backspace=indent,eol,start
set autoindent
set copyindent

" programming settings
set tags=./tags;
set cino=:0,l1,t0,W1
let c_space_errors=1

nmap <F5> :make<CR>

augroup filetype_fix
  au!
  au BufNewFile,BufRead SConstruct,SConscript setl ft=python
  au BufNewFile,BufRead Android.bp setl ft=go
  au BufNewFile,BufRead *.hal setl ft=cpp
augroup END

augroup filetype_indent
  au!
  au FileType gitcommit setl tw=72
  au FileType python,cmake,groovy,java setl sw=4 sts=4 et
  au FileType vim setl sw=2 sts=2
  au FileType c,cpp call ApplyCStyles()
augroup END

fun! ApplyCStyles()
  let path = expand("%:p")

  " Mesa
  if path =~ "projects/mesa"
    setl sw=3 sts=3 et
  elseif path =~ "projects/virglrenderer"
    setl sw=3 sts=3 et
  elseif path =~ "projects/venus-protocol"
    setl sw=4 sts=4 et
  " Vulkan
  elseif path =~ "olv/vulkan"
    setl sw=4 sts=4 et
  " Android
  elseif path =~ "/android"
    setl sw=4 sts=4 et
  endif
endfun
