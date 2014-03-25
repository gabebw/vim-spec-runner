require 'rspec'
require 'vimrunner'
require 'vimrunner/rspec'

ROOT = File.expand_path('../..', __FILE__)

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true
  config.start_vim do
    vim = Vimrunner.start

    vim.add_plugin(File.join(ROOT, 'plugin'), 'spec-runner.vim')

    vim
  end
end
