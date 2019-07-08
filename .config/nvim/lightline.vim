let g:lightline = { 
\ 'active': {
\   'left': [
\             [ 'mode', 'paste' ],
\             [ 'gitbranch', 'filename', 'readonly', 'modified' ],
\             [ 'cocstatus' ]
\           ],
\   'right': [
\              [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ],
\              ['lineinfo' ],
\              [ 'percent' ],
\              [ 'filetype' ]
\            ]
\ },
\ 'component_function': {
\   'gitbranch': 'fugitive#head',
\   'cocstatus': 'coc#status'
\ },
\ 'component_expand': {
\   'linter_checking': 'lightline#ale#checking',
\   'linter_warnings': 'lightline#ale#warnings',
\   'linter_errors': 'lightline#ale#errors',
\   'linter_ok': 'lightline#ale#ok',
\ },
\ 'component_type': {
\   'linter_checking': 'left',
\   'linter_warnings': 'warning',
\   'linter_errors': 'error',
\   'linter_ok': 'ok',
\ },
\ 'separator': {
\   'left': "\uE0B0",
\   'right': "\uE0B2"
\ },
\ 'subseparator': {
\   'left': "|",
\   'right': "|"
\ },
\ 'colorscheme': 'nord'
\ }

let g:lightline#ale#indicator_checking = "\uf110"
let g:lightline#ale#indicator_warnings = "\uf071"
let g:lightline#ale#indicator_errors = "\uf05e"
let g:lightline#ale#indicator_ok = "\uf00c"
