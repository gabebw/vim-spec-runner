require 'rspec'
require 'vimrunner'
require 'vimrunner/rspec'

ROOT = File.expand_path('../..', __FILE__)

Vimrunner::RSpec.configure do |config|
  # Decide how to start a Vim instance. In this block, an instance should be
  # spawned and set up with anything project-specific.
  config.start_vim do
    vim = Vimrunner.start

    plugin_path = File.join(ROOT, 'spec', 'plugin')
    vim.add_plugin(plugin_path, 'echo_plugin.vim')
    vim.command 'let g:spec_runner_context=EchoToOutputTxt'

    vim
  end
end

RSpec.configure do |config|
end
