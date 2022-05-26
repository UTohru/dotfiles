
function s:h_upper(str)
	let col = col('.')
	let head = matchstr(getline('.'), '\c^\s*\%(ONBUILD\s\+\)\?)')
	let col -= len(head)
	if col - 2 < len(a:str)
		return toupper(a:str)
	endif
	return a:str
endfunction

for s:instruction in [
\	'from',
\	'run',
\	'cmd',
\	'label',
\	'maintainer',
\	'expose',
\	'env',
\	'add',
\	'copy',
\	'entrypoint',
\	'volume',
\	'user',
\	'workdir',
\	'arg',
\	'onbuild',
\	'stopsignal',
\	'halthcheck',
\	'shell',
\]
	execute 'inoreabbrev <buffer> <expr>'
	\ s:instruction
	\ printf('<SID>h_upper(%s)', string(s:instruction))
endfor
