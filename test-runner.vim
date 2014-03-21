function! s:RunCurrentFile()
  call s:RunSpecCommand(SpecCommand('unfocused'))
endfunction

function! s:RunNearestSpec()
  call s:RunSpecCommand(SpecCommand('focused'))
endfunction

function! s:RunSpecCommand(command)
  call s:SetLastSpecCommand(a:command)
  execute a:command
endfunction

function! s:RunSuite()
  " just run 'rake'
endfunction

function! s:SpecCommand(is_focused)
  let runner = s:Runner()
  let preloader = s:Preloader(runner)
  let options = s:Options(runner)
  let path = s:Path()
  let focus = s:Focus(runner, a:is_focused)

  return s:Interpolate(runner, preloader, options, path, focus)
endfunction

function! s:Interpolate(runner, preloader, options, path, focus)
  let map={
        \ '{runner}' : a:runner,
        \ '{preloader}' : a:preloader,
        \ '{options}' : a:options,
        \ '{path}' : a:path,
        \ '{focus}' : a:focus,
        \ }
  for pair in keys(map)
    let placeholder=pair[0]
    let value=pair[1]
    execute substitute(result, placeholder, value, "g")
  endfor

  return result
endfunction

" cache command as the last command run
function! s:SetLastSpecCommand(command)
  let s:last_spec_command = a:command
endfunction
