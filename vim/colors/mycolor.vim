" < check highlight list >
" :so $VIMRUNTIME/syntax/hitest.vim
"

" transparent test

let g:colors_name = 'mycolor'

highlight PreProc ctermfg=226
hi Statement ctermfg=220
hi Identifier ctermfg=212
hi Constant ctermfg=208
hi Special ctermfg=133
hi Comment ctermfg=75
hi Type ctermfg=77
hi SpecialKey ctermfg=68
hi Title ctermfg=133
" hi LineNr ctermfg=241 ctermbg=234
" hi SignColumn ctermfg=20 ctermbg=235


" === "
" transparent"
" === "
hi Normal ctermbg=none
hi NonText ctermbg=none
hi Folded ctermbg=none
hi EndOfBuffer ctermbg=none
hi LineNr ctermfg=241 ctermbg=none
hi SignColumn ctermfg=20 ctermbg=none
hi TabLine cterm=bold ctermfg=238 ctermbg=none
hi TabLineFill cterm=bold ctermfg=250 ctermbg=none
hi TabLineSel ctermfg=252 ctermbg=none
