let s:spec_runner_command = '{preloader} {runner} {path}{focus}'

let s:FOCUSED = 1
let s:UNFOCUSED = 0
let s:COMMAND_FAILED = -1
let s:NOT_IN_SPEC_FILE = -2
let s:WARNING_UNABLE_TO_DETERMINE_RUNNER = 'Unable to determine correct spec runner'

function! vsr#run_current_spec_file()
  call s:RunIfInSpecFile(s:UNFOCUSED)
endfunction

function! vsr#run_focused_spec()
  call s:RunIfInSpecFile(s:FOCUSED)
endfunction

function! vsr#run_most_recent_spec()
  call s:RunMostRecentSpecOrWarn('No previous spec command')
endfunction

function! s:RunIfInSpecFile(focused)
  if s:InSpecFile()
    call s:RunSpecCommand(s:SpecCommand(a:focused))
  else
    call s:RunMostRecentSpecOrWarn(s:WARNING_UNABLE_TO_DETERMINE_RUNNER)
  endif
endfunction

function! s:RunMostRecentSpecOrWarn(warning_message)
  if exists('s:most_recent_command')
    call s:RunSpecCommand(s:most_recent_command)
  else
    call s:warn(a:warning_message)
  endif
endfunction

function! s:RunSpecCommand(command)
  let s:most_recent_command = a:command
  let executable_command = substitute(g:spec_runner_dispatcher, '{command}', a:command, 'g')
  call s:WriteIfEnabled()
  execute executable_command
endfunction

function! s:WriteIfEnabled()
  if exists('g:disable_write_on_spec_run') && g:disable_write_on_spec_run
    " Don't write.
  else
    write
  endif
endfunction

function! s:SpecCommand(is_focused)
  let runner = s:Runner()
  let preloader = s:Preloader()
  let path = s:Path()
  let focus = s:Focus(runner, a:is_focused)

  return s:InterpolateCommand(runner, preloader, path, focus)
endfunction

function! s:InSpecFile()
  return s:Runner() !=# s:NOT_IN_SPEC_FILE
endfunction

function! s:Runner()
  if s:InRspecFile()
    return 'rspec'
  elseif s:InJavascriptFile() && s:InGemfile('teaspoon')
    if s:Preloader() ==# 'zeus'
      return 'rake teaspoon'
    else
      return 'teaspoon'
    endif
  else
    return s:NOT_IN_SPEC_FILE
  endif
endfunction

function! s:InRspecFile()
  return match(@%, '_spec\.rb$') != -1
endfunction

function! s:InJavascriptFile()
  return match(@%, '_spec\.\(js\.coffee\|js\|coffee\)$') != -1
endfunction

function! s:Preloader()
  if filereadable('zeus.json') || s:FileInProjectRoot('zeus.json')
    return 'zeus'
  elseif s:InRspecFile() && s:InGemfile('spring-commands-rspec')
    return 'spring'
  elseif s:InJavascriptFile() && s:InGemfile('spring-commands-teaspoon')
    return 'spring'
  else
    return ''
  endif
endfunction

function! s:Path()
  if s:Runner() ==# 'rake teaspoon'
    return ' files=' . @%
  else
    return @%
  end
endfunction

function! s:Focus(runner, focused)
  if a:focused && s:RunnerSupportsFocusedSpecs(a:runner)
    return ':'.line('.')
  else
    return ''
  endif
endfunction

function! s:RunnerSupportsFocusedSpecs(runner)
  return a:runner ==# 'rspec'
endfunction

function! s:FileContains(filename, text)
  return filereadable(a:filename) && match(readfile(a:filename), a:text) != -1
endfunction

function! s:InGemfile(gem)
  return s:FileContains('Gemfile.lock', a:gem)
endfunction

function! s:FileInProjectRoot(filename)
  return filereadable(s:ProjectRoot() . '/' . a:filename)
endfunction

function! s:ProjectRoot()
  let git_root = s:GitRoot()
  if git_root !=# s:COMMAND_FAILED
    return git_root
  else
    return '.'
  endif
endfunction

function! s:GitRoot()
  let git_root = s:StripNewline(system('git rev-parse --show-toplevel'))
  if v:shell_error ==# 0
    return git_root
  else
    return s:COMMAND_FAILED
  endif
endfunction

function! s:StripNewline(string)
  return substitute(a:string, "\n", '', '')
endfunction

function! s:warn(warning_message)
  let full_error_message = 'vim-spec-runner: ' . a:warning_message
  echohl Error
  echom full_error_message
  echohl None
  let v:errmsg = full_error_message
endfunction

function! s:InterpolateCommand(runner, preloader, path, focus)
  let result = s:spec_runner_command
  let map = {
        \ '{runner}' : a:runner,
        \ '{preloader}' : a:preloader,
        \ '{path}' : a:path,
        \ '{focus}' : a:focus,
        \ }
  for [placeholder, value] in items(map)
    let result = substitute(result, placeholder, value, 'g')
  endfor

  return substitute(result, '^\s', '', '')
endfunction
