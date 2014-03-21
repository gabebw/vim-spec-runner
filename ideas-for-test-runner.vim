" Testing
"
" https://github.com/AndrewRadev/vimrunner
" Set context to a custom command that does `:!echo string > my-file.txt`


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
" :RunNearestSpec
" :RunCurrentFile
" :RunSuite
" - add default maps for these with overrides (hasmapto etc)

" :RunMostRecentSpec (not public, because we automatically do this for " you!)
