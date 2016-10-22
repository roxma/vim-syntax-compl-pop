
func! scp#completor#markdown#rule(...)
	return {
		\ "mkdSnippetPHP"    : "scp#completor#php#rule",
		\ "mkdSnippetHTML"   : "scp#completor#html#rule",
		\ "mkdSnippetJAVASCRIPT" : "scp#completor#javascript#rule",
		\ "*"                : "scp#completor#text#rule"
	\ }

	" cannot work with tern_for_vim

endfunc

