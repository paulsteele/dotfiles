call plug#begin('~/.config/nvim/plugged')
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  Plug 'airblade/vim-gitgutter'
  Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}
  Plug 'manasthakur/vim-commentor'
  Plug 'w0rp/ale'
  Plug 'itchyny/lightline.vim'
  Plug 'maximbaz/lightline-ale'
  Plug 'tpope/vim-fugitive'
  Plug 'kamykn/spelunker.vim'
  Plug 'leafgarland/typescript-vim'
  Plug 'tpope/vim-surround'
  Plug 'vmchale/dhall-vim'
  Plug 'arcticicestudio/nord-vim'
  Plug 'towolf/vim-helm'
  Plug 'neoclide/coc-python', {'do': 'yarn install --frozen-lockfile'}
  Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
  Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
  Plug 'neoclide/coc-tslint-plugin', {'do': 'yarn install --frozen-lockfile'}
  Plug 'neoclide/coc-java', {'do': 'yarn install --frozen-lockfile'}
  Plug 'neoclide/coc-yaml', {'do': 'yarn install --frozen-lockfile'}
  Plug 'neoclide/coc-solargraph', {'do': 'yarn install --frozen-lockfile'}
  Plug 'amiralies/coc-elixir', {'do': 'yarn install --frozen-lockfile && yarn build'}
  Plug 'fannheyward/coc-xml', {'do': 'yarn install --frozen-lockfile && yarn build'}
  Plug 'sheerun/vim-polyglot'
  Plug 'vimwiki/vimwiki'

call plug#end()

colorscheme nord
