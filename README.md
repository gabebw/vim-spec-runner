# Vim-spec-runner [![Build Status](https://travis-ci.org/gabebw/vim-spec-runner.svg?branch=master)](https://travis-ci.org/gabebw/vim-spec-runner)

An efficient and intelligent spec runner for Vim.

vim-spec-runner automatically detects the needed runner and will compose and
execute a spec run command in any context you specify. The primary goal of
vim-spec-runner is that it should Just Work (TM) for most of the workflows,
configurations, and apps you use each day.

* Efficient commands to run either a single spec, or a spec file
* Explicit command allowing for re-running the last-run spec command
* If the current file is not a spec file, re-runs the most recent spec
* Simple to use with any test executor, including Tmux oneslike
  [vim-tmux-runner] or [tslime]
* Automatically detects and uses preloaders ([zeus] and [spring])
* Saves the current file before running specs

[zeus]: https://github.com/burke/zeus
[spring]: https://github.com/rails/spring
[vim-tmux-runner]: https://github.com/christoomey/vim-tmux-runner
[tslime]: https://github.com/jgdavey/tslime.vim

## Installation

With [vundle](https://github.com/gmarik/Vundle.vim):

```vim
Bundle 'gabebw/vim-spec-runner'
```

## Usage

There are three commands in the public API:

* `:RunCurrentSpecFile` runs the entire current spec file, or if not in a spec
  file, re-runs the most recent command
* `:RunFocusedSpec` runs the current line in a spec, or if not in a spec file,
  re-runs the most recent command
* `:RunMostRecentSpec` re-runs the most recent command

All three commands use the `g:spec_runner_executor` variable, which is explained
in the "Configuration" section below.

## Configuration

The `g:spec_runner_executor` variable is used by all three public commands to
run specs. By default, it echoes the command and then runs it:

```vim
let g:spec_runner_executor = '!echo "{command}" && {command}'
```

The `{command}` is replaced with the command to run. To use vim-tmux-runner.vim with this
plugin, you might change the variable to this in your vimrc:

```vim
let g:spec_runner_executor = "call VtrSendCommand('{command}')".
```

This will run the command through tmux (but won't echo it).

By default, the plugin will `:write` the spec file before running it. To disable
that:

```vim
let g:disable_write_on_spec_run = 1
```

## Running the plugin's tests

    rake

If you get errors on OSX about `Vimrunner`, try installing MacVim then re-running the specs:

    $ brew install macvim
