augroup myvimrc
	autocmd!
augroup END

" check wsl "
let g:wsl = filereadable('/proc/sys/fs/binfmt_misc/WSLInterop')

" =====================================
" dein Script 
" =====================================
let s:dein_dir='~/.cache/dein'

let s:dein_repo = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if &runtimepath !~# '/dein.vim'
	if !isdirectory(expand(s:dein_repo))
		execute '!git clone --depth 1 https://github.com/Shougo/dein.vim' s:dein_repo
	endif
	execute 'set runtimepath^=' . substitute(
		\ fnamemodify(s:dein_repo, ':p'), '[/\\]$', '', '')
endif
if &compatible
	set nocompatible               " Be iMproved
endif

if dein#load_state(s:dein_dir)
	" let g:dein#inline_vimrcs = split(expand('~/.vim/rc/*'), '\n')

	call dein#begin(s:dein_dir)
	call dein#load_toml('~/.vim/pluginconfig/dein.toml', {'lazy':0})
	call dein#load_toml('~/.vim/pluginconfig/dein_lazy.toml', {'lazy':1})

	call dein#load_toml('~/.vim/pluginconfig/vim-lsp.toml', {'lazy':1})
	if executable("deno")
		call dein#load_toml('~/.vim/pluginconfig/denops.toml', {'lazy':0})
		call dein#load_toml('~/.vim/pluginconfig/ddc.toml', {'lazy':1})
	endif

	call dein#end()
	call dein#save_state()
else
endif

filetype plugin indent on
syntax on

" #auto install "
if dein#check_install()
	" g:dein#types#git#clone_depth = 1
	g:dein#types#git#enable_partial_clone = v:true
	call dein#install()
endif

" #update
" :call dein#update()"

" #auto remove
let s:removed_list = dein#check_clean()
if len(s:removed_list) > 0
	call map(s:removed_list, "delete(v:val, 'rf')")
	call dein#recache_runtimepath()
endif

" =====================================
"End dein Scripts 
" =====================================

set encoding=UTF-8
set fileencodings=UTF-8,ISO-2022-JP,euc-jp,sjis
scriptencoding utf-8

augroup myvimrc
	" start previous line
	autocmd BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
	\ exe "normal g`\"" | endif

	" filetype
	autocmd BufRead,BufNewFile *.snippets set filetype=snippets
	autocmd BufRead,BufNewFile */pluginconfig/*.toml call dein#toml#syntax()
	let g:tex_flavor = 'latex'

	" color
	autocmd VimEnter * colorscheme mycolor
augroup END


for s:f in split(glob('~/.vim/rc/*.vim'), '\n')
	execute 'source ' . s:f
endfor

" denops plugin test
" set runtimepath^=~/dps-work-dir
" let g:denops#debug=1
