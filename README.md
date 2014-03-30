# Vim-spec-runner [![Build Status](https://travis-ci.org/gabebw/vim-spec-runner.svg?branch=master)](https://travis-ci.org/gabebw/vim-spec-runner)

A configurable spec runner for Vim.

Feature list:

* Automatically detects and uses preloaders ([zeus] and [spring])
* Can run the entire current file or a spec by line number
* Can re-run most recent spec
* If the current file is not a spec file, re-runs the most recent spec
* Saves the spec file before running it
* Simple to use with any test runner, including Tmux test runners like
  [vim-tmux-runner]

[zeus]: https://github.com/burke/zeus
[spring]: https://github.com/rails/spring
[vim-tmux-runner]: https://github.com/christoomey/vim-tmux-runner


## Installation

With [vundle](https://github.com/gmarik/Vundle.vim):

    Bundle 'gabebw/vim-spec-runner'

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

    let g:spec_runner_executor = '!echo "{command}" && {command}'

The `{command}` is replaced with the command to run. To use vim-tmux-runner.vim with this
plugin, you might change the variable to this in your vimrc:

    let g:spec_runner_executor = ':VtrSendCommandToRunner {command}'

This will run the command through tmux (but won't echo it).

By default, the plugin will `:write` the spec file before running it. To disable
that:

    let g:disable_write_on_spec_run = 1

## Running the plugin's tests

    rake

If you get errors on OSX about `Vimrunner`, try installing MacVim then re-running the specs:

    $ brew install macvim
