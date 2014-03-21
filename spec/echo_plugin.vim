function! s:EchoToOutputTxt(command)
  execute "!echo " . a:command . "> output.txt"
endfunction

command! -nargs=1 EchoToOutputTxt call s:EchoToOutputTxt(<f-args>)

let g:spec_runner_command='EchoToOutputTxt "{preloader} {runner} {path}{focus}"'
