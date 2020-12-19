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

let mapleader=","
nnoremap <Leader>m :make<CR>

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
augroup END

fun! InitializeProject()
  let dot_git = finddir(".git", ";")
  if empty(dot_git)
    return
  endif

  let g:project_path = fnamemodify(dot_git, ":p:h:h")

  let project_vimrc = findfile("project_vimrc", dot_git)
  if !empty(project_vimrc)
    exec "source " . project_vimrc
  endif
endfunc

call InitializeProject()
