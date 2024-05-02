" < check highlight list >
" :so $VIMRUNTIME/syntax/hitest.vim
"

" transparent test (tabstop=4)

let g:colors_name = 'mycolor'

highlight PreProc	ctermfg=214	guifg=#ffaf00
hi Statement		ctermfg=226	guifg=#ffff00
hi Identifier		ctermfg=212	guifg=#ff87d7
hi Constant			ctermfg=222	guifg=#ffd787
hi Type				ctermfg=77	guifg=#5fd75f
hi SpecialKey		ctermfg=240	guifg=#585858
hi NonText			ctermfg=240	guifg=#585858
hi Comment			ctermfg=81	guifg=#5fd7ff
hi Special			ctermfg=154	guifg=#afff00
hi Title			ctermfg=82 	guifg=#5fff00
hi Pmenu 			ctermfg=252	ctermbg=NONE	guifg=#d0d0d0	guibg=NONE
hi PmenuSel 		ctermfg=238	ctermbg=254		guifg=#444444	guibg=#e4e4e4
hi DiffAdd			ctermfg=112	ctermbg=236		guifg=#87d700	guibg=#303030
hi DiffChange		ctermfg=227	ctermbg=236		guifg=#ffff5f	guibg=#303030
hi DiffDelete		ctermfg=124	ctermbg=236		guifg=#af0000	guibg=#303030


" === "
" transparent"
" === "
hi Normal			ctermbg=NONE	guibg=NONE
hi NonText			ctermbg=NONE	guibg=NONE
hi Folded			ctermbg=NONE	guibg=NONE
hi EndOfBuffer		ctermbg=NONE	guibg=NONE
hi LineNr			ctermfg=241		ctermbg=NONE	guifg=#626262	guibg=NONE
hi SignColumn		ctermfg=20		ctermbg=NONE	guifg=#0000d7	guibg=NONE
hi TabLine			cterm=bold		ctermfg=238		ctermbg=NONE	gui=bold	guifg=#444444	guibg=NONE
hi TabLineFill		cterm=bold		ctermfg=250		ctermbg=NONE	gui=bold	guifg=#bcbcbc	guibg=NONE
hi TabLineSel		ctermfg=252		ctermbg=NONE	guifg=#d0d0d0	guibg=NONE
