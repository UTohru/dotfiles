augroup myvimrc
	autocmd!
augroup END

" wslのチェック　"
let g:wsl = filereadable('/proc/sys/fs/binfmt_misc/WSLInterop')

" =====================================
" dein Script 
" =====================================
let s:dein_dir='~/.vim/dein'
if isdirectory(resolve(expand(s:dein_dir)))
	if &compatible
		set nocompatible               " Be iMproved
	endif

	" Required: "
	set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim

	if dein#load_state(s:dein_dir)
		call dein#begin(s:dein_dir)

		call dein#load_toml('~/.vim/pluginconfig/dein.toml', {'lazy':0})
		call dein#load_toml('~/.vim/pluginconfig/dein_lazy.toml', {'lazy':1})


		
		if v:version >= 802
			" vim-lsp + ddc
			call dein#load_toml('~/.vim/pluginconfig/ddc.toml', {'lazy':1})
		elseif v:version >= 800
			call dein#load_toml('~/.vim/pluginconfig/coc.toml', {'lazy':1})
		endif

		
		call dein#end()
		call dein#save_state()
	endif

	filetype plugin indent on
	syntax on

	"# auto install "
	"if dein#check_install()
	"	call dein#install()
	"endif
	"
	" #update
	" :call dein#update()"
	
	call map(dein#check_clean(), "delete(v:val, 'rf')")
	"  -> call dein#recache_runtimepath()
endif


" =====================================
"End dein Scripts 
" =====================================


set encoding=UTF-8
set fileencodings=UTF-8,ISO-2022-JP,euc-jp,sjis
scriptencoding utf-8


augroup myvimrc

	"前回中断した行から
	autocmd BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
	\ exe "normal g`\"" | endif

	" ファイルタイプの付与
	"autocmd BufRead,BufNewFile *.toml setfiletype vim
	autocmd BufRead,BufNewFile */pluginconfig/*.toml call dein#toml#syntax()
	let g:tex_flavor = 'latex'

	" color
	autocmd VimEnter * colorscheme mycolor
augroup END

if exists('g:loaded_myvimrc')
	finish
endif
let g:loaded_myvimrc  = 1


for s:f in split(glob('~/.vim/rc/*.vim'), '\n')
	execute 'source ' . s:f
endfor

" denops plugin test
"set runtimepath^=~/program/tutorial/dps-plugins
"let g:denops#debug=1
