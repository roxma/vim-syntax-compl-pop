
" TODO ultisnips integration

let g:scp_disable = get(g:,'scp_disable',{})

command! ScpEnable  call scp#enable()
command! ScpDisable call scp#disable()


func! s:on_filetype()

	let s:builtin = {
				\ "php"            : { 'route' : 'scp#completor#php#rule' },
				\ "python"         : { 'route' : 'scp#completor#python#rule' },
				\ "markdown"       : { 'route' : 'scp#completor#markdown#rule' },
				\ "javascript"     : { 'route' : 'scp#completor#javascript#rule' },
				\ "javascript.jsx" : { 'route' : 'scp#completor#javascript#rule' },
				\ "html"           : { 'route' : 'scp#completor#html#rule' },
				\ "go"             : { 'route' : 'scp#completor#go#rule' },
				\ "text"           : { 'route' : 'scp#completor#text#rule' },
				\ }

	let l:ft = &ft
	if empty(l:ft)
		let l:ft = "*"
	endif

	if get(g:scp_disable,l:ft,0)==0
		call scp#setup_buffer(get(s:builtin,&ft,{ 'route': 'scp#completor#text#rule' }))
	endif

endfunc

autocmd FileType * call <SID>on_filetype()

 
" some enhancements
inoremap <expr> <silent> <Plug>(scp_omni_complete)      scpomni#begin()
inoremap <expr> <silent> <Plug>(scp_keyword_complete)  scpbuffer#begin()

