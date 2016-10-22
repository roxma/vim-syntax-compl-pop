
let g:scp_disable = get(g:,'scp_disable',{})

command! ScpEnable  call scp#enable()
command! ScpDisable call scp#disable()


if get(g:scp_disable,'php',0)==0
	autocmd FileType php call scp#setup_buffer({ 'route': 'scp#completor#php#rule' })
endif

if get(g:scp_disable,'markdown',0)==0
	autocmd FileType markdown call scp#setup_buffer({ 'route': 'scp#completor#markdown#rule' })
endif

if get(g:scp_disable,'javascript',0)==0
	autocmd FileType javascript.jsx,javascript call scp#setup_buffer({ 'route': 'scp#completor#javascript#rule' })
endif

if get(g:scp_disable,'html',0)==0
	autocmd FileType html call scp#setup_buffer({ 'route': 'scp#completor#html#rule' })
endif

 
" some enhancements
inoremap <expr> <silent> <Plug>(scp_omni_complete)      scpomni#begin()
inoremap <expr> <silent> <Plug>(scp_keyword_complete)  scpbuffer#begin()

