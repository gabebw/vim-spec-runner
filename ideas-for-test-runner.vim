" *** You always need {runner} {path} ***
" If you don't use a preloader, leave out {preloader}
" If you don't want to run individual specs, leave out {focus} too
let g:spec_command = 'VtrSendCommandToRunner {preloader} {runner} {options} {path}{focus}'

" Maybe always check Gemfile.lock instead of Gemfile?

" Known preloaders
"   zeus (based on zeus.json file in root)
"   spring (based on Gemfile && spring-commands-rspec in Gemfile)

" Known runners
" rspec assumed for _spec.rb?
" For _spec.{js,coffee}
"   jasmine assumed if Gemfile.lock && jasmine-core in Gemfile.lock
"   teaspoon assumed if Gemfile.lock && teaspoon in Gemfile.lock
"   konacha assumed if Gemfile.lock && konacha in Gemfile.lock

" Options are passed to runner, ie '-f d' for spec doc format in rspec

" Focus is line number for RSpec and (currently) nothing for JS runners

" Allow overrides? ie preloader => 'spring', 'runner' =>
"

" rspec =>
"  preloader: spring, zeus
"  focus: 'line'
"  options: 'g:rspec_options'
"
" konacha =>

" Public API is (commands not functions):
" :RunNearestSpec } RunMostRecentSpec is implicit in both
" :RunCurrentFile }
" - add default maps for these with overrides (hasmapto etc)
" Public variable API: Just one, `g:spec_runner_executor`
  " Default: let g:spec_runner_executor='!echo {command} && {command}'
  " let g:spec_runner_executor=":call Send_to_Tslime('{command}')<CR>"
  " let g:spec_runner_executor=":VtrCommand '{command}'"
  " Not public:
  " let s:spec_runner_command='{preloader} {runner} {path}{focus}'

" :RunMostRecentSpec (not public, because we automatically do this for " you!)
