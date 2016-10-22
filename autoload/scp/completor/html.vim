
func! scp#completor#html#rule(...)
	return {
		\ "*" : [
				\ { '=~': '\v\<\/{0,1}\k$'  , 'completefunc': "htmlcomplete#CompleteTags"},
				\ { '=~': '\v\k{3}$'        , 'feedkeys': "\<C-x>\<C-N>"}
		\ ]
	\ }

endfunc

