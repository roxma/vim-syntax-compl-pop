
func! scp#completor#php#rule(...)
	return {
		\ "phpRegion" : {
			\ "phpComment" : "scp#completor#txt#rule",
			\ "phpStringSingle" : [
				\ { '=~': '\vrequire|include' , 'feedkeys': "\<C-x>\<C-N>"},
				\ { '=~': ''                  , 'route': "scp#completor#txt#rule" },
			\ ],
			\ "phpStringDouble" : [
				\ { '=~': '\vrequire|include' , 'feedkeys': "\<C-x>\<C-N>"},
				\ { '=~': ''                  , 'route': "scp#completor#txt#rule" },
			\ ],
			\ "*" : [
				\ { '=~': '\v\k{3}$'      , 'feedkeys': "\<C-x>\<C-N>"},
				\ { '=~': '::$'           , 'completefunc': "phpcomplete#CompletePHP", "force": 1},
				\ { '=~': '->$'           , 'completefunc': "phpcomplete#CompletePHP", "force": 1},
			\ ]
		\ },
		\ "*" : "scp#completor#txt#rule"
	\ }

	" TODO: route html complete

	" NOTE: phpcomplete#CompletePHP sucks, but it's the best option for now

endfunc

