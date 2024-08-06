noremap l h
noremap ; l
noremap h ;

noremap <C-w>l <C-w>h
noremap <C-w>; <C-w>l

noremap <C-j> <C-f>
noremap <C-k> <C-b>

let mapleader = ","

" fuzzy find files in the working directory (where you launched Vim from)
nmap <leader>f :Files<cr>
" fuzzy find lines in the current file
nmap <leader>, :BLines<cr>
" fuzzy find an open buffer
nmap <leader>b :Buffers<cr>
" fuzzy find text in working directory
nmap <leader>r :Rg<cr>
" fuzzy find neo vim commands (like Ctrl-Shift-P in Sublime/Atom/VSC)
nmap <leader>c :Commands<cr>

nmap <C-e> :Lexplore<CR>

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction

nmap <leader>tt :lua require('toggle-checkbox').toggle()<CR>
