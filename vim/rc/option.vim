
set backspace=indent,eol,start

if exists('+belloff')
	set belloff=all
else 
	set visualbell
	set t_vb=
endif

set laststatus=2
set tabstop=4
set shiftwidth=4
set whichwrap=b,s,h,l,<,>,[,],~ "行を跨ぐ移動
set nowrap "折り返しなし"
set number
""set ambiwidth=double

set list
set shortmess-=S

" 非表示文字
if v:version < 802
	set listchars=tab:--\|,nbsp:%,trail:~
else
	set listchars=tab:»-,multispace:...\|,nbsp:%,trail:~
endif

set tags=./tags;$HOME

set mouse=

