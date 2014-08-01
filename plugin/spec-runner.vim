if ! exists('g:spec_runner_dispatcher')
  let g:spec_runner_dispatcher = '!echo "{command}" && {command}'
endif

command! RunCurrentSpecFile execute vsr#run_current_spec_file()
command! RunFocusedSpec execute vsr#run_focused_spec()
command! RunMostRecentSpec execute vsr#run_most_recent_spec()

" Define plug mappings (essentially place holders, not actually bound to keys)
nnoremap <silent> <Plug>RunCurrentSpecFile :RunCurrentSpecFile<CR>
nnoremap <silent> <Plug>RunFocusedSpec :RunFocusedSpec<CR>
nnoremap <silent> <Plug>RunMostRecentSpec :RunMostRecentSpec<CR>

function! s:MapIfUnmapped(key, mapping)
  if ! hasmapto(a:mapping)
    execute 'map <Leader>'.a:key.' '.a:mapping
  endif
endfunction

" Default key mappings
call s:MapIfUnmapped('a', '<Plug>RunCurrentSpecFile')
call s:MapIfUnmapped('l', '<Plug>RunFocusedSpec')
call s:MapIfUnmapped('r', '<Plug>RunMostRecentSpec')
