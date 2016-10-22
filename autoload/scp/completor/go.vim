
func! scp#completor#go#rule(...)

	return {
		\ "*" : [
 				\ { '=~': '\v\k{2}$' , 'feedkeys': "\<C-x>\<C-n>"} ,
 				\ { '=~': '\.$'      , 'feedkeys': "\<C-x>\<C-o>", "force":1} ,
		\ ],
	\ }

endfunc

