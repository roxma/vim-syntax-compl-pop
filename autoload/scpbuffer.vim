
" scp enhanced buffer keyword complete

function! scpbuffer#begin()

	" call scp#writeLog('scpbuffer#begin') " debug

	silent! unlet b:scpbufferCompleteStartColumn
	silent! unlet b:scpbufferCompleteCache
	silent! unlet b:scpbufferInitialBase

	let l:autorefresh = 1
	if has('nvim')
		let l:autorefresh = 0
	endif
	call scp#completefunc({'completefunc': 'scpbuffer#complete', 'onfinish': function('s:done'), 'autorefresh': l:autorefresh})

	return ''

endfunction


function! s:done()

	" call scp#writeLog('scpbuffer#done') " debug

	silent! unlet b:scpbufferCompleteStartColumn
	silent! unlet b:scpbufferCompleteCache
	silent! unlet b:scpbufferInitialBase
	silent! unlet b:scpbufferRetList
	silent! unlet b:scpbufferLastBase

endfunction


function! scpbuffer#complete(findstart,base)

	" call scp#writeLog("scpbuffer#complete findsart:" . a:findstart .", base:[" . a:base ."]" ) " debug

	" first call
	if a:findstart == 1
		" return the old base if vim calls here again
		if exists('b:scpbufferCompleteStartColumn')
			return b:scpbufferCompleteStartColumn
		endif
		let b:scpbufferCompleteStartColumn = match(strpart(getline('.'), 0, col('.') - 1),'\k*$')
		if -1 == b:scpbufferCompleteStartColumn
			b:scpbufferCompleteStartColumn = col('.') - 1
		endif
		return b:scpbufferCompleteStartColumn
	endif

	" cache keywords for completion
	if !exists('b:scpbufferCompleteCache')
		let b:scpbufferInitialBase = a:base
		let b:scpbufferLastBase    = a:base
		let l:scope = 100
		let l:beginL = max([1,line('.')-l:scope])
		let l:endL = min([line('$'),line('.')+l:scope])
		" \%<23l	Matches above a specific line (lower line number).
		" \%>23l	Matches below a specific line (higher line number).
		" let l:matchId = matchadd('scpbuffer','\%<'.l:endL.'\%>'.l:beginL . '\k\{1,}')
		" let l:matches = getmatches()
		" let l:hls = &hlsearch
		" set nohlsearch
		let b:scpbufferCompleteCache = []
		let l:chars = split(a:base,'\ze')
		let l:i = 0
		while l:i<len(l:chars)
			if l:chars[l:i] ==# '/'
				let l:chars[l:i] = '\/'
			elseif  l:chars[l:i] ==# '\'
				let l:chars[l:i] = '\\'
			elseif  l:chars[l:i] ==# '?'
				let l:chars[l:i] = '\?'
			endif
			let l:i+=1
		endwhile
		if empty(a:base)
			let l:pattern = '\V\k\+'
		else
			let l:pattern = '\c\V\k\*'.join(l:chars,'\k\*').'\k\*'
		endif
		silent! execute l:beginL.','.l:endL.' s/'.l:pattern.'/\=add(b:scpbufferCompleteCache,{"word":submatch(0), "abbr":"", "menu":"", "info":"", "icase":1, "dup": 1, "empty": 1})/nge'
		" call scp#writeLog("pattern: " . l:pattern) " debug
		call uniq(sort(b:scpbufferCompleteCache))
	endif

	if len(a:base) > len(b:scpbufferLastBase)
		" The search would be narrowed down, use last returned result
		let l:loopList = b:scpbufferRetList
		" call scp#writeLog('narrow ,cache size: '. len(b:scpbufferCompleteCache) . ", narrowed Size:".len(l:loopList))
	else
		" call scp#writeLog('rebegin ,cache size: '. len(b:scpbufferCompleteCache))
		let l:loopList = b:scpbufferCompleteCache
	endif

	let b:scpbufferRetList = []
	let l:begin = len(b:scpbufferInitialBase)
	for l:w in l:loopList
		let l:m = s:WordMatchInfo(l:begin,a:base,l:w.word)
		if empty(l:m)
			" call scp#writeLog("[" . l:w.word . "] does not match base:".a:base) " debug
			continue
		endif
		" call scp#writeLog("[" . l:w.word . "] match base:".a:base) " debug
		let l:w.scpbuffer_match = l:m
		call add(b:scpbufferRetList,l:w)
	endfor

	call sort(b:scpbufferRetList,function('s:sortCandidate'))

	" " clear unneaded data ---
	" let l:i = 0
	" while l:i < len(b:scpbufferRetList)
	" 	unlet b:scpbufferRetList[l:i].scpbuffer_match
	" 	let l:i+=1
	" endwhile
	
	" call scp#writeLog('return size: '. len(b:scpbufferRetList))

	if empty(b:scpbufferRetList)
		if a:base=~'\V\k\+\$'
			return -2
		else
			" call s:done()
			" call scp#writeLog('return size: '. len(b:scpbufferRetList))
			return -1 " leave completion mode
		endif
	endif
	
	let b:scpbufferLastBase = a:base
	return { "words":b:scpbufferRetList, "refresh": "always"}

endfunction

function! s:sortCandidate(w1,w2)
	if (a:w1.scpbuffer_match.end-a:w1.scpbuffer_match.begin) < (a:w2.scpbuffer_match.end-a:w2.scpbuffer_match.begin)
		return -1
	endif
	if (a:w1.scpbuffer_match.end-a:w1.scpbuffer_match.begin) > (a:w2.scpbuffer_match.end-a:w2.scpbuffer_match.begin)
		return 1
	endif
	if (a:w1.scpbuffer_match.begin) < (a:w2.scpbuffer_match.begin)
		return -1
	endif
	if (a:w1.scpbuffer_match.begin) > (a:w2.scpbuffer_match.begin)
		return 1
	endif
	if len(a:w1) < len(a:w2)
		return -1
	endif
	if len(a:w1) > len(a:w2)
		return 1
	endif
	return 0
endfunction

" if doesnot match, return empty dict
" (2,'heol','helloworld') returns {4,8} 'ol' match 'oworl', 2 meas initial base is 'he', omitted for the match
function! s:WordMatchInfo(begin,base,word)
	let l:lb = len(a:base)
	let l:lw = len(a:word)
	let l:i = a:begin
	let l:j = l:i
	let l:begin = 0
	let l:end = -1

	if a:begin==l:lb
		return {"begin":a:begin,"end":a:begin}
	endif
	if a:base==?a:word
		" asumes world is not empty string here
		return {"begin":a:begin,"end":l:lw-1}
	endif

	while l:i<l:lb
		while l:j < l:lw
			if a:base[l:i]==?a:word[l:j]
				if l:i==a:begin
					let l:begin = l:j
				endif
				if l:i==l:lb-1
					let l:end = l:j
				endif
				let l:j+=1
				break
			endif
			let l:j+=1
		endwhile
		let l:i+=1
	endwhile

	" not match
	if l:end==-1
		return {}
	endif

	return {"begin":l:begin,"end":l:end}

endfunction

" call scp#writeLog('scpbuffer loaded') " debug

