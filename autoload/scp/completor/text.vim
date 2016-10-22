
func! scp#completor#text#rule(...)
	return {
	\ "*" : [
		\ { '=~': '\v\k{3}$', 'feedkeys': "\<C-x>\<C-n>"}
	\ ]
	\ }
endfunc

