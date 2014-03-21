# Vim-spec-runner

A configurable spec runner for Vim.

## Running the specs

    rake

## Vim problems on OSX

If you get errors about `Vimrunner`, try this:

    # Uninstall Vim if you have it
    $ brew uninstall vim
    # Install Macvim
    $ brew install macvim

For some reason, the Homebrew-installed vim sometimes won't work with Vimrunner.
