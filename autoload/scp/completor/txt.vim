
func! scp#completor#txt#rule(...)
	return {
	\ "*" : [
		\ { '=~': '\v\k{3}$', 'feedkeys': "\<C-n>\<C-n>"}
	\ ]
	\ }
endfunc

