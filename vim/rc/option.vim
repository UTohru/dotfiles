
set backspace=indent,eol,start

if exists('+belloff')
	set belloff=all
else 
	set visualbell
	set t_vb=
endif


" coc fault"
set hidden
set nobackup
set nowritebackup
set updatetime=2000
set shortmess+=c
"set signcolumn=yes


set laststatus=2
set tabstop=4
set shiftwidth=4
set whichwrap=b,s,h,l,<,>,[,],~ "行を跨ぐ移動
set nowrap "折り返しなし"
set number
""set ambiwidth=double

set list
if v:version >= 802
	set listchars=tab:»-,multispace:...\|,nbsp:%,trail:~ "非表示文字の可視化"
else
	set listchars=tab:»-,nbsp:%,trail:~ "非表示文字の可視化"
endif
"set listchars=tab:--\|,nbsp:%,trail:~ "非表示文字の可視化"

set tags=./tags;$HOME

