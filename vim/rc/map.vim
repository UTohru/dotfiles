let mapleader="\<Space>"

" tmux
noremap <C-b> <NOP>

" move pagewise
nnoremap <Leader>j <C-f>
nnoremap <Leader>k <C-b>

" ^  $
noremap <Leader>h ^
noremap <Leader>l $
onoremap h ^
onoremap l $

" tab , window
nnoremap - :<C-u>split<Space>
nnoremap <Bar> :<C-u>vsplit<Space>
nnoremap <Leader>t :<C-u>tabnew<Space>
nnoremap t gt
nnoremap T gT

nmap <Leader>w <C-w>

set termwinkey=<C-g>
nnoremap <silent> <Leader>T :<C-u>tab terminal<CR>
tnoremap <ESC> <C-\><C-n>


nnoremap <C-i> <C-l>
"nnoremap <C-l> i<Space><ESC>

nnoremap <silent> ZZ :<C-u>bd<CR>

" redo
nnoremap U <C-r>
" toggle number
nnoremap <silent> <C-n> :<C-u>set number!<CR>
" paste full filepath"
nnoremap <Leader>p a<C-r>=expand('%:p')<CR>
" basic replace
nnoremap <C-f> :<C-u>%s<Space>/



" inc dec (-: conflict)
"nnoremap + <C-a>
"nnoremap - <C-x>

" leave insert
inoremap jk <ESC>
inoremap kj <ESC>


" tags / jump"
nnoremap <C-]> g<C-]>
inoremap <C-]> <ESC>g<C-]>
nnoremap <Leader>o <C-o>


"code"
inoremap <C-l> <Right>
inoremap <C-h> <Left>

" command"
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

vnoremap J <NOP>

onoremap a" 2i"
onoremap a' 2i'
onoremap a` 2i`

