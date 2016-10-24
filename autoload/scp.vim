
" let g:scp_rules_disabled = get(g:,'scp_rules_disabled',{})
let g:scp_debug = $DEBUG
let g:scp_enable = get(g:,'scp_enable',1)

func! scp#enable()
	let g:scp_enable = 1
endfunc

func! scp#disable()
	let g:scp_enable = 0
endfunc

func! scp#lock()
	let b:scp_lock = get(b:,'scp_lock',0)
	let b:scp_lock += 1
endfunction

func! scp#unlock()
	let b:scp_lock -= 1
	if b:scp_lock < 0
		let b:scp_lock = 0
		throw "AutoComplPop: not locked"
	endif
endfunction


" call this funciton to enable auto complete pop
func! scp#setup_buffer(options)

	if !exists("b:scp_options")

		" config for this buffer for the first time
		autocmd InsertEnter,CompleteDone <buffer> call s:on_complete_done()
		autocmd InsertEnter              <buffer> call s:reset()

		" vim's TextChangedI will be triggered even when <C-X><C-O> is pressed
		" use InsertCharPre to workaround this bug
		if has('nvim')
			autocmd TextChangedI         <buffer> call scp#feed_popup('')
		else
			autocmd InsertCharPre        <buffer> call scp#feed_popup(v:char)
		endif

		let b:scp_done = 1
		let b:scp_lock    = 0
		" when complete-functions return refresh always, there's no way to stay in
		" completion mode properly (even when returns -2), vim will exit
		" completion mode directly when a key typed after the popup menu gets
		" empty. But the text pattern will still match the pattern to trigger a
		" new completion mode, vim will get really slow when this hapens. I
		" invented this variable to solve this issue.
		let b:scp_smart_done = 1

	endif

	let b:scp_options                = copy(a:options)
	let b:scp_options['completeopt'] = get(b:scp_options,'completeopt','menu,menuone,noinsert,noselect')
	let b:scp_options['ignorecase']  = get(b:scp_options,'ignorecase','1')
	silent! execute "setlocal shortmess" . get(b:scp_options,'shortmess',"+=c")

	" Supress the anoying messages like '-- Keyword completion (^N^P)' when
	" press '<C-n>' key. This option is only supported after vim 7.4.314 
	" https://groups.google.com/forum/#!topic/vim_dev/WeBBjkXE8H8

endfunction

func! s:reset()
	let b:scp_smart_done=1
	let b:scp_done=1
endfunc

func! scp#log(line)
	if g:scp_debug
		call writefile(["[scp] [" . localtime() . "] ".  a:line],"scp.log","a")
	endif
endfunction 

""
" If this func is called when handling event InsertCharPre, 
" set the parameter to v:char, otherwise set it to empty stirng
func! scp#feed_popup(char)

	if g:scp_enable == 0
		return
	endif

	if b:scp_lock > 0
		return ''
	endif

	let l:text = s:current_text().a:char
	if (b:scp_done==1) && (b:scp_smart_done==0)
		if empty(s:check_match(l:text,b:scp_last_match))
			let b:scp_smart_done=1
		elseif len(b:scp_complete_done_text) > len(l:text)
			" when characters are deleted
			let b:scp_smart_done=1
		endif
	endif

	let l:need_force = pumvisible() || (b:scp_done==0) || (b:scp_smart_done==0)

	let l:synstk = map(synstack(line("."),col(".")),'synIDattr(v:val,"name")')
	call scp#log(join(l:synstk,','))
	let l:match = s:get_action(b:scp_options['route'],l:synstk,l:text,l:need_force,[])
	if empty(l:match)
		call s:refresh()
		return ''
	endif

	let b:scp_last_match = l:match

	let b:scp_done = 0
	let b:scp_smart_done = 0
	if empty(get(l:match,'completefunc',{}))
		call s:feedkeys(l:match['feedkeys'])
	else
		call scp#completefunc({'completefunc': l:match['completefunc'], 'autorefresh': get(l:match,'autorefresh',0)})
	endif

	return ''

endfunction

func! s:on_complete_done()

	call scp#log('on_complete_done')

	let b:scp_done=1
	let b:scp_complete_done_text = s:current_text()

	call s:completefunc_done()

	if get(b:,'scp_completefunc_cnt',0)==0
		if exists('b:completeopt_backup')
			let &l:completeopt = b:completeopt_backup 
			let &l:ignorecase = b:ignorecase_backup
			unlet b:completeopt_backup
			unlet b:ignorecase_backup
		endif
	endif

endfunc


func! s:feedkeys(keys,...)
	if !exists('b:completeopt_backup')
		let b:completeopt_backup = &l:completeopt
		let b:ignorecase_backup = &l:ignorecase
	endif
	let &l:completeopt = b:scp_options['completeopt']
	let &l:ignorecase = b:scp_options['ignorecase']
	call feedkeys(a:keys)
endfunc

func! scp#set_complete_done()
	let b:scp_done = 1
	let b:scp_smart_done = 1
endfunction

func! s:current_text()
	return strpart(getline('.'), 0, col('.') - 1)
endfunction

func! s:get_action(rule,synstk,text,need_force,path)

	if empty(a:rule)
		call scp#log("get_action empty rule: " . join(a:path,'->'))
		return {}
	endif

	if type(a:rule)==type({})

		let l:i = 0
		while l:i < len(a:synstk)
			let l:syn = a:synstk[l:i]
			if !empty(get(a:rule,l:syn,{}))
				" syntax matched
				return s:get_action(a:rule[l:syn],a:synstk[l:i+1:],a:text,a:need_force,a:path + [l:syn])
			else
				let l:i += 1
			endif
		endwhile

		if !empty(get(a:rule,'*',{}))
			return s:get_action(a:rule['*'],a:synstk,a:text,a:need_force, a:path + ['*'])
		else
			call scp#log("get_action no syntax match: " . join(a:path,'->'))
			return {}
		endif

	elseif type(a:rule)==type([])

		let l:i = 0
		while l:i < len(a:rule)
			let l:m = a:rule[l:i]

			if (a:need_force==1) && get(l:m,"force",0)==0
				let l:i+=1
				continue
			endif

			let l:ret = s:check_match(a:text,l:m)
			if !empty(l:ret)
				" if has direct route
				if !empty(get(l:ret,'route',{}))
					return s:get_action(l:ret['route'],a:synstk,a:text,a:need_force,a:path + [ l:i ])
				else
					call scp#log("get_action ret:" . join(a:path+ [l:i],'->'))
					return l:ret
				endif
			endif
			let l:i+=1
		endwhile

		call scp#log("get_action no match:" . join(a:path,'->'))
		return {}

	elseif type(a:rule)==type("")

		let l:rule = call(a:rule,[a:text,a:need_force,a:synstk])
		return s:get_action(l:rule,a:synstk,a:text,a:need_force,a:path + [ a:rule ])

	endif

	call scp#log("get_action error:" . join(a:path,'->'))
	return {}

endfunction

func! s:check_match(text,m)
	for [l:operator,l:pattern] in items(a:m)
		if l:operator =~ '^[=~=!#]\{1,}$' " is operator
			let l:r = eval("a:text ".l:operator." l:pattern")
			if l:r == 1
				return a:m
			endif
		endif
	endfo
	return {}
endfunction


" manage wrapped omni functions {

" parameters:
" {
"	'completefunc' :
"	'autorefresh' : " if the popup menu gets empty, auto refresh
"	'onfinish' :
" }
func! scp#completefunc(opt)

	if get(b:,"scp_completefunc_cnt",0)==0
		let b:scp_completefunc = &l:completefunc
	endif

	" If still in scp#TempOmni completion mode, call the onfinish for the
	" previous setting
	if exists('b:scp_completefunc_opt["onfinish"]')
		call b:scp_completefunc_opt["onfinish"]()
	endif

	let b:scp_completefunc_opt = a:opt
	let b:scp_completefunc_cnt = get(b:,"scp_completefunc_cnt",0)+1

	let &l:completefunc = a:opt["completefunc"]
	call s:feedkeys("\<C-X>\<C-U>",'t')

endfunction

func! s:refresh()
	if !exists('b:scp_completefunc_opt')
		return
	endif
	if get(b:scp_completefunc_opt,'autorefresh',0) == 0
		return
	endif
	let b:scp_completefunc_cnt += 1

	noautocmd call s:feedkeys("\<C-X>\<C-U>",'t')
endfunction

func! s:completefunc_done()

	if get(b:,"scp_completefunc_cnt",0)==0
		return
	endif

	let b:scp_completefunc_cnt-=1
	if b:scp_completefunc_cnt>0
		return
	endif

	if exists('b:scp_completefunc_opt["onfinish"]')
		call b:scp_completefunc_opt["onfinish"]()
		unlet b:scp_completefunc_opt
	endif

	" resume the origional omni func
	let &l:completefunc = b:scp_completefunc 
endfunction

" }




