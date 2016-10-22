
func! scp#completor#javascript#rule(...)
	return {
		\ "*" : [
				\ { '=~': '\v\k{3}$'      , 'feedkeys': "\<C-x>\<C-N>"},
				\ { '=~': '\.$'           , 'completefunc': "tern#Complete", "force": 1},
		\ ]
	\ }

endfunc

