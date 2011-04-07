set tabstop=8 sw=2 softtabstop=2 smarttab expandtab smartindent
set nocompatible history=100 incsearch ruler showcmd title titleold=
set ignorecase smartcase scrolloff=1 sidescrolloff=1
set t_Co=256
if version >= 720
  filetype plugin indent on
  syntax enable

  let g:solarized_termcolors=16
  colorscheme solarized
endif
