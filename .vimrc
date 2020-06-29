set backspace=indent,eol,start

noremap l h
noremap ; l
noremap h ;

noremap <C-w>l <C-w>h
noremap <C-w>; <C-w>l

noremap <C-j> <C-f>
noremap <C-k> <C-b>

set noexpandtab

let mapleader = ","
nmap <leader>f :vsc MonoDevelop.Ide.Commands.SearchCommands.GotoFile <CR>
nmap <leader>, :vsc MonoDevelop.Ide.Commands.SearchCommands.Find <CR>
nmap <leader>r :vsc MonoDevelop.Ide.Commands.SearchCommands.FindInFiles <CR>
nmap <leader>d :vsc MonoDevelop.Refactoring.RefactoryCommands.GotoDeclaration <CR>
nmap <leader>i :vsc MonoDevelop.Refactoring.RefactoryCommands.GotoImplementation <CR>
nmap gcc :vsc MonoDevelop.Ide.Commands.EditCommands.ToggleCodeComment <CR>
