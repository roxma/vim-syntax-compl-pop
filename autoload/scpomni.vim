
" scp enhanced omni complete
" cache omni list && fuzzy search complete menu

function! scpomni#begin()

	if &l:omnifunc==""
		call scp#set_complete_done()
		return ''
	endif

	silent! unlet b:scpomniCompleteStartColumn
	silent! unlet b:scpomniCompleteCache
	silent! unlet b:scpomniInitialBase

	let l:autorefresh = 1
	if has('nvim')
		let l:autorefresh = 0
	endif
	call scp#completefunc({'completefunc': 'scpomni#complete', 'onfinish': function('s:done'), 'autorefresh': l:autorefresh})

	return ''

endfunction


function! s:done()

	" call scp#writeLog('scpomnir#done') " debug

	silent! unlet b:scpomniCompleteStartColumn
	silent! unlet b:scpomniCompleteCache
	silent! unlet b:scpomniInitialBase

endfunction


" wrapped omni func
function! scpomni#complete(findstart,base)

	" call scp#writeLog("scpomni#complete") " debug

	" first call
	if a:findstart == 1
		" return the old base if vim calls here again
		if exists('b:scpomniCompleteStartColumn')
			return b:scpomniCompleteStartColumn
		endif
		let b:scpomniCompleteStartColumn = call(&l:omnifunc,[a:findstart,a:base])
		return b:scpomniCompleteStartColumn
	endif

	" catche the first list return by user's omni func for fuzzy completion
	if !exists('b:scpomniCompleteCache')
		let b:scpomniInitialBase = a:base
		let l:ret = call(&l:omnifunc,[a:findstart,a:base])
		if type(l:ret)==3  " list
			let b:scpomniCompleteCache = l:ret
		elseif type(l:ret)==4 " dict
			let b:scpomniCompleteCache = l:ret.words
		else
			return l:ret
		endif
	endif

	let l:retlist = []
	let l:begin = len(b:scpomniInitialBase)
	" TODO: b:scpomniCompleteCache maybe a list of strings
	for l:w in b:scpomniCompleteCache
		let l:m = s:WordMatchInfo(l:begin,a:base,l:w.word)
		if empty(l:m)
			" call scp#writeLog("[" . l:w.word . "] does not match base:".a:base . ", begin:".l:begin.", word:".l:w.word) " debug
			continue
		endif
		" call scp#writeLog("[" . l:w.word . "] match base:".a:base) " debug
		let l:w.scpomni_match = l:m
		let l:retlist += [l:w]
	endfor

	call sort(l:retlist,function('s:sortCandidate'))

	" " clear unneaded data ---
	" let l:i = 0
	" while l:i < len(l:retlist)
	" 	unlet l:retlist[l:i].scpomni_match
	" 	let l:i+=1
	" endwhile

	return { "words":l:retlist, "refresh": "always"}

endfunction

function! s:sortCandidate(w1,w2)
	if (a:w1.scpomni_match.end-a:w1.scpomni_match.begin) < (a:w2.scpomni_match.end-a:w2.scpomni_match.begin)
		return -1
	endif
	if (a:w1.scpomni_match.end-a:w1.scpomni_match.begin) > (a:w2.scpomni_match.end-a:w2.scpomni_match.begin)
		return 1
	endif
	if (a:w1.scpomni_match.begin) < (a:w2.scpomni_match.begin)
		return -1
	endif
	if (a:w1.scpomni_match.begin) > (a:w2.scpomni_match.begin)
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

" call scp#writeLog('scpomni loaded') " debug

