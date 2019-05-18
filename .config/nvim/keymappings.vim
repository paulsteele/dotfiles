noremap l h
noremap ; l
noremap h ;

let mapleader = ","

" fuzzy find files in the working directory (where you launched Vim from)
nmap <leader>f :Files<cr> 
" fuzzy find lines in the current file
nmap <leader>, :BLines<cr>
" fuzzy find an open buffer
nmap <leader>b :Buffers<cr>
" fuzzy find text in working directory
nmap <leader>r :Rg
" fuzzy find neo vim commands (like Ctrl-Shift-P in Sublime/Atom/VSC)
nmap <leader>c :Commands<cr>

nmap <C-e> :NERDTreeToggle<CR>