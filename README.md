Vim-spec-runner [![Build Status](https://travis-ci.org/gabebw/vim-spec-runner.svg?branch=master)](https://travis-ci.org/gabebw/vim-spec-runner)
============================================================

An efficient and intelligent spec runner for Vim.

`vim-spec-runner` automatically detects the test type. It can run tests using
any external command dispatcher (like `vim-dispatch`). It should Just Work (TM)
for most of the workflows and configurations you use each day.

It can run RSpec files or JavaScript files (with [Teaspoon]).

[Teaspoon]: https://github.com/modeset/teaspoon

Benefits
--------

* Has commands to run a single test case, run a whole spec file, or re-run the
  last spec command
* If you're editing a non-spec file and you run `vim-spec-runner`, it
  automatically falls back to running the most recent spec
* Simple to use with any external command dispatcher, including Tmux ones like
  [vim-tmux-runner] or [tslime]
* Automatically detects and uses preloaders ([zeus] and [spring])
* Saves the current file before running specs

[zeus]: https://github.com/burke/zeus
[spring]: https://github.com/rails/spring
[vim-tmux-runner]: https://github.com/christoomey/vim-tmux-runner
[tslime]: https://github.com/jgdavey/tslime.vim

Installation
------------

With [vundle](https://github.com/gmarik/Vundle.vim):

```vim
Plugin 'gabebw/vim-spec-runner'
```

Usage
-----

### Commands

There are three commands in the public API:

* `:RunCurrentSpecFile` runs the entire current spec file, or if not in a spec
  file, re-runs the most recent command
* `:RunFocusedSpec` runs the current line in a spec, or if not in a spec file,
  re-runs the most recent command
* `:RunMostRecentSpec` re-runs the most recent command

All three commands use the `g:spec_runner_dispatcher` variable, which is explained
in the ["Configuration" section](#configuration).

### Custom mappings

To create your own custom mappings, we've defined mapping placeholders ([`<Plug>`
maps][plug]) for each of the commands to make mapping easy.

```vim
" Use <Leader>t to run the current spec file.
map <Leader>t <Plug>RunCurrentSpecFile

" Use <Leader>u to run the current line in a spec.
map <Leader>u <Plug>RunFocusedSpec

" Use <Leader>v to explicitly run the most recent spec.
map <Leader>v <Plug>RunMostRecentSpec
```

You *must* use `map` when you define your mappings. Note that for Magical Vim
Reasons, even though you're typing `map`, it's a normal-mode mapping.

[plug]: http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_3)#Use_of_.3CPlug.3E

Configuration
-------------

The `g:spec_runner_dispatcher` variable is used by all three public commands to
run specs. By default, it echoes the command and then runs it:

```vim
" Default mapping. Echo the commmand then run it:
let g:spec_runner_dispatcher = '!echo "{command}" && {command}'
```

The `{command}` is replaced with the command to run.

It's simple to configure it to run the spec command with your executor of
choice:

```vim
" Using vim-tmux-runner:
let g:spec_runner_dispatcher = 'call VtrSendCommand("{command}")'

" Using tslime.vim:
let g:spec_runner_dispatcher = 'call Send_to_Tmux("clear\n{command}\n")'

" Using vim-dispatch
let g:spec_runner_dispatcher = 'Dispatch {command}'
```

By default, the plugin will `:write` the spec file before running it. To disable
that:

```vim
let g:disable_write_on_spec_run = 1
```

Running the plugin's tests
--------------------------

    rake

If you get errors on OSX about `Vimrunner`, try installing MacVim then re-running the specs:

    $ brew install macvim
