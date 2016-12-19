
let s:jedi_exist = 0

if &rtp =~ 'jedi-vim'
	let s:jedi_exist = 1
endif


func! scp#completor#python#rule(...)

	if s:jedi_exist
		return {
			\ "*" : [
					\ { '=~': '\v\k{2}$' , 'feedkeys': "\<C-x>\<C-n>"} ,
					\ { '=~': '\.$'      , 'completefunc': "jedi#completions", "force": 1} ,
			\ ],
		\ }
	else
		return {
			\ "*" : [
					\ { '=~': '\v\k{2}$' , 'feedkeys': "\<C-x>\<C-n>"} ,
			\ ],
		\ }
	endif

endfunc

