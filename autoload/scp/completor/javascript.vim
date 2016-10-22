
let s:tern_exist = 0

if &rtp =~ 'tern_for_vim'
	let s:tern_exist = 1
endif

func! scp#completor#javascript#rule(...)

	if &filetype =~ "javascript" && s:tern_exist
		" tern_for_vim does not work well with markdown
		return {
			\ "*" : [
					\ { '=~': '\.$'       , 'completefunc': "tern#Complete", "force": 1},
					\ { '=~': '\v\k$'     , 'route': "scp#completor#text#rule"},
			\ ]
		\ }
	else
		return {
			\ "*" : [
					\ { '=~': '\v\k$'     , 'route': "scp#completor#text#rule"},
			\ ]
		\ }
	endif

endfunc

func! scp#completor#javascript#info(...)
	return s:tern_exist
endfunc
