call plug#begin('~/.config/nvim/plugged')
  Plug 'scrooloose/nerdtree'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  Plug 'airblade/vim-gitgutter'
  Plug 'vim-airline/vim-airline'
  Plug 'neoclide/coc.nvim', {'tag': '*', 'do': './install.sh'}
  Plug 'manasthakur/vim-commentor'
  Plug 'w0rp/ale'
call plug#end()
