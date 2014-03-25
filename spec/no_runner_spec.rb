require 'spec_helper'

describe 'No runner' do
  before do
    configure_to_echo_command_to('command.txt')
  end

  it 'should not run the spec command' do
    run_command_in_unknown_file

    expect(no_command_was_run).to be_true
  end

  it 'should alert the user that it could not run the command' do
    run_command_in_unknown_file

    expect(last_vim_error).to match /unable to determine correct spec runner/i
  end

  def run_command_in_unknown_file
    vim.edit 'random_file.rb'
    vim.command 'RunCurrentFile'
  end

  def last_vim_error
    vim.command 'echo v:errmsg'
  end

  def no_command_was_run
    !File.exists? 'command.txt'
  end

  def create_file_in_root(name, contents='')
    in_vim_root do
      open(name, 'w') { |f| f.write(contents) }
    end
  end

  def configure_to_echo_command_to(file_name)
    vim.command "let g:spec_runner_executor='#{spec_runner_executor(file_name)}'"
  end

  def spec_runner_executor(file_name)
    "!echo {command} > #{file_name}"
  end
end
