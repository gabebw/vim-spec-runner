require 'rspec'
require 'vimrunner'
require 'vimrunner/rspec'

ROOT = File.expand_path('../..', __FILE__)

Vimrunner::RSpec.configure do |config|
  # Decide how to start a Vim instance. In this block, an instance should be
  # spawned and set up with anything project-specific.
  config.start_vim do
    vim = Vimrunner.start

    vim.add_plugin(File.join(ROOT, 'plugin'), 'spec-runner.vim')

    vim
  end
end
