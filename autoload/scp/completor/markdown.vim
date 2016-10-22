
func! scp#completor#markdown#rule(...)
	return {
		\ "mkdSnippetPHP" : "scp#completor#php#rule",
		\ "*" : "scp#completor#txt#rule"
	\ }

	" TODO: route html complete

endfunc

