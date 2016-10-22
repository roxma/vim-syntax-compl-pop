
func! scp#completor#html#rule(...)
	return {
		\ "javaScript": 'scp#completor#javascript#rule',
		\ "*" : [
				\ { '=~': '\v\<\/{0,1}\k$'  , 'completefunc': "htmlcomplete#CompleteTags"},
				\ { '=~': '\v\k$'           , 'route': "scp#completor#text#rule"}
		\ ]
	\ }

endfunc

