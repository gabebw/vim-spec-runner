require 'spec_helper'

describe 'Vim Spec Runner' do
  before do
    configure_to_echo_command_to('command.txt')
  end

  context ':RunCurrentSpecFile' do
    it_should_behave_like 'a command with fallbacks', 'RunCurrentSpecFile'
  end

  context ':RunMostRecentSpec' do
    context 'with a previous spec run command' do
      it 're-runs if the last command was run spec file' do
        run_spec_file

        original_command = purge_previous_command

        vim.command 'RunMostRecentSpec'

        expect(command).to eq original_command
      end

      it 're-runs RunFocusedSpec if that was the last call' do
        vim.edit 'thing_spec.rb'
        vim.command 'RunFocusedSpec'

        original_command = purge_previous_command

        vim.command 'RunMostRecentSpec'

        expect(command).to eq original_command
      end
    end

    context 'without a previous spec command' do
      it 'runs nothing and warns the user' do
        with_clean_vim do |clean_vim|
          clean_vim.edit 'thing_spec.rb'
          clean_vim.command 'RunMostRecentSpec'

          expect(no_command_was_run).to be_true
          expect(last_vim_error(clean_vim)).to match /no previous spec command/i
        end
      end
    end
  end

  context ':RunFocusedSpec' do
    context 'in a spec file' do
      it 'runs the nearest spec' do
        vim.edit 'sample_spec.rb'
        vim.command 'RunFocusedSpec'

        expect(command).to include 'sample_spec.rb:1'
      end
    end

    it_should_behave_like 'a command with fallbacks', 'RunFocusedSpec'
  end

  context 'configuration' do
    it 'uses the command executor override if present' do
      executor_command = '!echo "{command}" > specific_file.txt'
      vim.command "let g:spec_runner_executor='#{executor_command}'"

      run_spec_file

      expect(File.exists?('command.txt')).to be_false
      expect(command('specific_file.txt')).to include 'rspec'
    end
  end

  context 'runner' do
    context 'with an rspec file' do
      it 'uses rspec as the runner' do
        run_spec_file 'a_sample_spec.rb'

        expect(command).to start_with 'rspec'
      end
    end
  end

  context 'preloader' do
    it 'is blank by default' do
      run_spec_file

      expect(command).to start_with 'rspec'
    end

    it 'uses "zeus" when a zeus.json file is present' do
      create_file_in_root 'zeus.json'

      run_spec_file

      expect(command).to start_with 'zeus'
    end

    it 'is "zeus" even when Vim is not in the same directory as zeus.json' do
      subdirectory = 'sub/directory'
      create_file_in_root 'zeus.json'
      in_vim_root do
        create_git_repo
        FileUtils.mkdir_p subdirectory
      end

      vim.command "cd #{subdirectory}"
      run_spec_file

      expect(command(File.join(subdirectory, 'command.txt'))).to start_with 'zeus'
    end

    it 'is "spring" when spring-commands-rspec is in the Gemfile.lock' do
      create_file_in_root 'Gemfile.lock', <<-GEMFILE
        GEM
          remote: https://rubygems.org/
          specs:
            spring-commands-rspec (1.2.5)
      GEMFILE

      run_spec_file

      expect(command).to start_with 'spring'
    end
  end

  context 'path' do
    it 'is the path to the spec file' do
      spec_file = 'spec/features/user_navigates_spec.rb'

      run_spec_file spec_file

      expect(command).to include spec_file
    end
  end

  def run_spec_file(spec_file = 'my_spec.rb', vim_instance = vim)
    vim_instance.edit spec_file
    vim_instance.command 'RunCurrentSpecFile'
  end

  def run_nearest_spec(spec_file = 'my_spec.rb', vim_instance = vim)
    vim_instance.edit spec_file
    vim_instance.command 'RunFocusedSpec'
  end

  def command(command_file = 'command.txt')
    IO.read(command_file).chomp
  end

  def configure_to_echo_command_to(file_name)
    vim.command "let g:spec_runner_executor='#{spec_runner_executor(file_name)}'"
  end

  def spec_runner_executor(file_name)
    "!echo {command} > #{file_name}"
  end

  def no_command_was_run
    ! File.exists?('command.txt')
  end

  def last_vim_error(vim_instance = vim)
    vim_instance.command 'echo v:errmsg'
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

  def with_clean_vim
    clean_vim = Vimrunner.start
    clean_vim.add_plugin(File.join(ROOT, 'plugin'), 'spec-runner.vim')
    yield(clean_vim)
  ensure
    clean_vim.kill
  end

  def vim_directory
    vim.command('pwd')
  end

  def purge_previous_command(command_file = 'command.txt')
    previous_command = command(command_file)
    FileUtils.remove command_file
    previous_command
  end

  def create_git_repo
    system 'git init >/dev/null'
  end
end
