
function! s:tabpage_label(n) abort
	let title = gettabvar(a:n, 'title')
	if title !=# ''
		" using t:title
		return title
	endif

	let buffnr = tabpagebuflist(a:n)
	" highlight (current tab)
	let hi = a:n is tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'

	" buf num
	let no = len(buffnr)
	if no is 1
		let no = ''
	endif

	" modified symbol
	let mod = len(filter(copy(buffnr), 'getbufvar(v:val, "&modified")')) ? '+' :''
	let sp = (no . mod) ==# '' ? '' : ' '

	" current buf
	let curbufnr = buffnr[tabpagewinnr(a:n) - 1]
	let fname = pathshorten(bufname(curbufnr))

	let label = ' ' . no . mod . sp . fname . ' '
	return '%' . a:n . 'T' . hi . label . '%T%#TabLineFill#'
endfunction

function! MakeTabLine() abort
	let titles = map(range(1, tabpagenr('$')), 's:tabpage_label(v:val)')
	let sep = '|'
	let tabpages = join(titles, sep) . sep . '%#TabLineFill#%T'
	let info = ''
	return tabpages . '%=' . info
endfunction

" default
set showtabline=2
set tabline=%!MakeTabLine()
