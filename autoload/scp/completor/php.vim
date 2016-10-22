
func! scp#completor#php#rule(...)
	return {
		\ "phpRegion" : {
			\ "phpComment" : "scp#completor#text#rule",
			\ "phpStringSingle" : [
				\ { '=~': '\vrequire|include' , 'feedkeys': "\<C-x>\<C-N>"},
				\ { '=~': ''                  , 'route': "scp#completor#text#rule" },
			\ ],
			\ "phpStringDouble" : [
				\ { '=~': '\vrequire|include' , 'feedkeys': "\<C-x>\<C-N>"},
				\ { '=~': ''                  , 'route': "scp#completor#text#rule" },
			\ ],
			\ "*" : [
				\ { '=~': '\v\k{3}$'      , 'feedkeys': "\<C-x>\<C-N>"},
				\ { '=~': '::$'           , 'completefunc': "phpcomplete#CompletePHP", "force": 1},
				\ { '=~': '->$'           , 'completefunc': "phpcomplete#CompletePHP", "force": 1},
			\ ]
		\ },
		\ "*" : "scp#completor#text#rule"
	\ }

	" TODO: route html complete

	" NOTE: phpcomplete#CompletePHP sucks, but it's the best option for now

endfunc

