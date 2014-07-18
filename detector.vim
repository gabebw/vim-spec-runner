
function! s:Hello()
  return 1
endfunction

function! s:Other()
  return 0
endfunction

function! s:Finally()
  return 1
endfunction

let g:runners = [
      \ { "detector": function('<sid>Hello'), "name": "Rspec", "description": 'You know, rspec' },
      \ { "detector": function('<sid>Other'), "name": "Teaspoon", "description": 'Nice JS runner' },
      \ { "detector": function('<sid>Hello'), "name": "Konacha", "description": 'Antoher JSer' }
      \ ]

function! s:Detect()
  for runner in g:runners
    if runner.detector()
      echo runner
      return runner
    endif
  endfor
endfunction

function! s:Select()
  let active_runners = []
  for runner in g:runners
    if runner.detector()
      call add(active_runners, runner)
    endif
  endfor
  echo active_runners
  return active_runners
endfunction

function! s:ListRunners()
  let names = map(copy(g:runners), "v:val.name . ' - ' . v:val.description")
  echo join(names, "\n")
endfunction

command! DetectFunctor call <sid>Detect()
command! SelectFunctors call <sid>Select()
command! ListRunners call <sid>ListRunners()
