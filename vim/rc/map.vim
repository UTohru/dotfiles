let mapleader="\<Space>"

inoremap <Esc> <Esc>:set iminsert=0<CR>

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

tnoremap <ESC> <C-\><C-n>

nnoremap > >>
nnoremap < <<
xnoremap < <gv
xnoremap > >gv


nnoremap <C-i> <C-l>
"nnoremap <C-l> i<Space><ESC>

nnoremap <silent> ZZ :<C-u>bd<CR>

" redo
nnoremap U <C-r>


" leave insert
inoremap jk <ESC>
inoremap kj <ESC>


" tags / jump"
nnoremap <C-]> g<C-]>
inoremap <C-]> <ESC>g<C-]>
nnoremap <Leader>o <C-o>


" insert move
inoremap <C-l> <Right>
inoremap <C-h> <Left>

" command hist"
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

vnoremap J <NOP>
vnoremap K <NOP>
vnoremap <Leader>y "+y

onoremap a" 2i"
onoremap a' 2i'
onoremap a` 2i`

"
" SHORTCUT
"

" url open in vim
nnoremap <Leader>O :<C-u>r!curl -s ''<Left>
" toggle view option
nnoremap <silent> <C-n> :<C-u>set number!<CR>:set wrap!<CR>
" paste full filepath"
nnoremap <Leader>p a<C-r>=expand('%:p')<CR>
" basic replace
nnoremap <C-f> :<C-u>%s<Space>/
" terminal
if has('nvim')
	nnoremap <silent> <Leader>T :<C-u>tabnew<CR>:terminal<CR>
else
	nnoremap <silent> <Leader>T :<C-u>tab terminal<CR>
endif

