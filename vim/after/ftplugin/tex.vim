nnoremap <Space>[ :<C-u>?section{<CR>
nnoremap <Space>] :<C-u>/section{<CR>

if empty(v:servername) && exists('*remote_startserver')
	call remote_startserver('VIM')
endif

function! SyncTexForward()
	let cmd = "silent !zathura --synctex-forward " . line(".") . ":" . col(".") . ":" . expand("%:p") . " " . expand("%:p:h") . "/output/" . expand("%:r") . ".pdf &"

	exec cmd
	redraw!
endfunction
nnoremap <Space><CR> :<C-u>call SyncTexForward()<CR>
