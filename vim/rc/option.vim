
set backspace=indent,eol,start

if exists('+belloff')
	set belloff=all
else 
	set visualbell
	set t_vb=
endif

set tabstop=4
set shiftwidth=4
set whichwrap=b,s,h,l,<,>,[,],~ "行を跨ぐ移動
set nowrap "折り返しなし"
set number
""set ambiwidth=double

set list
set shortmess-=S

" 非表示文字
if v:version < 802 && !has("nvim")
	set listchars=tab:--\|,nbsp:%,trail:~
else
	set listchars=tab:»-,multispace:...\|,nbsp:%,trail:~
endif

set tags=./tags;$HOME

set mouse=

if g:wsl && executable("win32yank.exe")
	let g:clipboard = {
    \   'name': 'wslClipboard',
    \   'copy': {
    \      '+': 'win32yank.exe -i',
    \      '*': 'win32yank.exe -i',
    \    },
    \   'paste': {
    \      '+': 'win32yank.exe -o',
    \      '*': 'win32yank.exe -o',
    \   },
    \   'cache_enabled': 1,
    \ }
endif


if !has('nvim')
	set laststatus=2
	set termwinkey=<C-g>
else
	set laststatus=3
	autocmd myvimrc TermOpen * setl nonumber | startinsert
endif

