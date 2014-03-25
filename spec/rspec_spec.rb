require 'spec_helper'

describe 'An RSpec file' do
  before do
    configure_to_echo_command_to('command.txt')
  end

  context 'configuration' do
    it 'uses the command executor override if present' do
      executor_command = '!echo "{command}" > specific_file.txt'
      vim.command "let g:spec_runner_executor='#{executor_command}'"

      vim.edit 'sample_spec.rb'
      vim.command 'RunCurrentFile'

      expect(File.exists?('command.txt')).to be_false
      expect(command('specific_file.txt')).to include 'rspec'
    end
  end

  context 'preloader' do
    it 'is blank by default' do
      run_all_specs

      expect(command).to start_with 'rspec'
    end

    it 'is "zeus" when a zeus.json file is present' do
      create_file_in_root 'zeus.json'

      run_all_specs

      expect(command).to start_with 'zeus'
    end

    it 'is "spring" when spring-commands-rspec is in the Gemfile.lock' do
      create_file_in_root 'Gemfile.lock', <<-GEMFILE
        GEM
          remote: https://rubygems.org/
          specs:
            spring-commands-rspec (1.2.5)
      GEMFILE

      run_all_specs

      expect(command).to start_with 'spring'
    end
  end

  context 'runner' do
    it 'is "rspec" when in an rspec file' do
      vim.edit 'my_spec.rb'

      vim.command 'RunCurrentFile'

      expect(command).to start_with 'rspec'
    end
  end

  context 'path' do
    it 'is the path to the spec file' do
      spec_file = 'spec/features/user_navigates_spec.rb'
      vim.edit spec_file
      vim.command 'RunCurrentFile'

      expect(command).to include spec_file
    end
  end

  context 'focus' do
    it 'includes the line number' do
      vim.edit 'spec/user_spec.rb'
      vim.command 'RunNearestSpec'

      expect(command).to include ':1'
    end
  end

  def command(command_file = 'command.txt')
    IO.read(command_file).chomp
  end

  def create_file_in_root(name, contents='')
    in_vim_root do
      open(name, 'w') { |f| f.write(contents) }
    end
  end

  def in_vim_root
    Dir.chdir(vim_directory) do
      yield
    end
  end

  def vim_directory
    vim.command('pwd')
  end

  def configure_to_echo_command_to(file_name)
    vim.command "let g:spec_runner_executor='#{spec_runner_executor(file_name)}'"
  end

  def run_all_specs
    vim.edit 'my_spec.rb'
    vim.command 'RunCurrentFile'
  end

  def spec_runner_executor(file_name)
    "!echo {command} > #{file_name}"
  end
end
