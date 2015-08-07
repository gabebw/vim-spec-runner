require 'spec_helper'

describe 'Vim Spec Runner' do
  before do
    configure_to_echo_command_to('command.txt')
  end

  context ':RunCurrentSpecFile' do
    it 'is mapped to <Leader>a' do
      plug_map = '<Plug>RunCurrentSpecFile'

      vim.edit 'my_spec.rb'

      expect('<Leader>a').to normal_map_to(plug_map)

      execute_plug_mapping(plug_map)
      expect(command_was_run).to be_true
    end

    it 'does not create a mapping if one already exists' do
      using_vim_without_plugin do |clean_vim|
        clean_vim.edit 'my_spec.rb'
        clean_vim.command 'nnoremap <Leader>x <Plug>RunCurrentSpecFile'
        load_plugin(clean_vim)

        expect(clean_vim).to have_no_normal_map_from('<Leader>a')
      end
    end

    context 'with an RSpec file' do
      it 'runs the entire spec' do
        vim.edit 'my_spec.rb'

        vim.command 'RunCurrentSpecFile'

        expect(command).to end_with 'my_spec.rb'
      end
    end

    context 'with the teaspoon gem installed' do
      before do
        create_gemfile_with('teaspoon')
      end

      %w(.coffee .js.coffee .js).each do |extension|
        context "with a JS spec ending in #{extension}" do
          it 'runs teaspoon directly' do
            spec = "person_spec#{extension}"
            vim.edit spec

            vim.command 'RunCurrentSpecFile'

            expect(command).to eq "teaspoon #{spec}"
          end
        end
      end

      context 'and zeus installed' do
        it 'uses zeus rake teaspoon' do
          set_up_zeus

          vim.edit "person_spec.coffee"
          vim.command 'RunCurrentSpecFile'

          expect(command).to start_with 'zeus rake teaspoon'
        end

        it 'correctly runs a single file' do
          set_up_zeus

          vim.edit "person_spec.coffee"
          vim.command 'RunCurrentSpecFile'

          expect(command).to end_with ' files=person_spec.coffee'
        end

      end

      context 'and the spring-commands-teaspoon gem installed' do
        it 'uses spring' do
          set_up_spring_for('teaspoon')

          vim.edit "person_spec.coffee"
          vim.command 'RunCurrentSpecFile'

          expect(command).to start_with 'spring teaspoon'
        end
      end
    end

    context 'without the teaspoon gem installed' do
      it 'does not run any command for JS' do
        with_clean_vim do |clean_vim|
          clean_vim.edit "person_spec.coffee"

          clean_vim.command 'RunCurrentSpecFile'

          expect(no_command_was_run).to be_true
        end
      end
    end

    it_should_behave_like 'a command with fallbacks', 'RunCurrentSpecFile'
  end

  context ':RunMostRecentSpec' do
    it 'is mapped to <Leader>r' do
      plug_map = '<Plug>RunMostRecentSpec'

      run_spec_file
      purge_previous_command

      expect('<Leader>r').to normal_map_to(plug_map)
      execute_plug_mapping(plug_map)
      expect(command_was_run).to be_true
    end

    it 'does not create a mapping if one already exists' do
      using_vim_without_plugin do |clean_vim|
        clean_vim.edit 'my_spec.rb'
        clean_vim.command 'nnoremap <Leader>x <Plug>RunMostRecentSpec'
        load_plugin(clean_vim)

        expect(clean_vim).to have_no_normal_map_from('<Leader>r')
      end
    end

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
    it 'is mapped to <Leader>l' do
      plug_map = '<Plug>RunFocusedSpec'

      vim.edit 'my_spec.rb'

      expect('<Leader>l').to normal_map_to(plug_map)
      execute_plug_mapping(plug_map)
      expect(command_was_run).to be_true
    end

    it 'does not create a mapping if one already exists' do
      using_vim_without_plugin do |clean_vim|
        clean_vim.edit 'my_spec.rb'
        clean_vim.command 'nnoremap <Leader>x <Plug>RunFocusedSpec'
        load_plugin(clean_vim)

        expect(clean_vim).to have_no_normal_map_from('<Leader>l')
      end
    end

    context 'in a spec file' do
      it 'runs the nearest spec' do
        vim.edit 'sample_spec.rb'
        vim.command 'RunFocusedSpec'

        expect(command).to include 'sample_spec.rb:1'
      end
    end

    context 'with the teaspoon gem installed' do
      before do
        create_gemfile_with('teaspoon')
      end

      context 'with a .coffee spec file' do
        it 'runs teaspoon, unfocused' do
          vim.edit 'person_spec.coffee'

          vim.command 'RunFocusedSpec'

          expect(command).to end_with 'person_spec.coffee'
        end
      end
    end

    it_should_behave_like 'a command with fallbacks', 'RunFocusedSpec'
  end

  context 'configuration' do
    it 'uses the command dispatcher override if present' do
      dispatcher_command = '!echo "{command}" > specific_file.txt'
      vim.command "let g:spec_runner_dispatcher='#{dispatcher_command}'"

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
      set_up_zeus

      run_spec_file

      expect(command).to start_with 'zeus'
    end

    it 'uses "zeus" when a .zeus.sock file is present' do
      set_up_zeus(using_socket: true)

      run_spec_file

      expect(command).to start_with 'zeus'
    end

    it 'is "zeus" even when Vim is not in the same directory as zeus.json' do
      subdirectory = 'sub/directory'
      set_up_zeus
      create_git_repo
      FileUtils.mkdir_p subdirectory

      vim.command "cd #{subdirectory}"
      run_spec_file

      expect(command(File.join(subdirectory, 'command.txt'))).to start_with 'zeus'
    end

    it 'is "spring" when spring-commands-rspec is in the Gemfile.lock' do
      set_up_spring_for('rspec')

      run_spec_file

      expect(command).to start_with 'spring'
    end
  end

  context 'autowrite' do
    it 'writes the file before running it' do
      spec_file = 'my_spec.rb'
      vim.edit spec_file

      vim.command 'RunCurrentSpecFile'

      expect(file_was_written(spec_file)).to be_true
    end

    it 'does not write the file if g:disable_write_on_spec_run is truthy' do
      spec_file = 'my_spec.rb'
      with_clean_vim do |clean_vim|
        clean_vim.edit spec_file
        clean_vim.command 'let g:disable_write_on_spec_run = 1'

        clean_vim.command 'RunCurrentSpecFile'
      end

      expect(file_was_written(spec_file)).to be_false
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
    vim.command "let g:spec_runner_dispatcher='#{spec_runner_dispatcher(file_name)}'"
  end

  def spec_runner_dispatcher(file_name)
    "!echo {command} > #{file_name}"
  end

  def no_command_was_run
    ! command_was_run
  end

  def command_was_run
    File.exists?('command.txt')
  end

  def file_was_written(file_name)
    File.exist?(file_name)
  end

  def last_vim_error(vim_instance = vim)
    vim_instance.command 'echo v:errmsg'
  end

  def create_file_in_root(name, contents='')
    open(name, 'w') { |f| f.write(contents) }
  end

  def with_clean_vim
    clean_vim = Vimrunner.start
    clean_vim.add_plugin(File.join(ROOT, 'plugin'), 'spec-runner.vim')
    yield(clean_vim)
  ensure
    clean_vim.kill
  end

  def using_vim_without_plugin
    cleanest_vim = Vimrunner.start
    yield(cleanest_vim)
  ensure
    cleanest_vim.kill
  end

  def load_plugin(vim_instance)
    vim_instance.add_plugin(File.join(ROOT, 'plugin'), 'spec-runner.vim')
  end

  def vim_directory
    vim.command('pwd')
  end

  def purge_previous_command(command_file = 'command.txt')
    previous_command = command(command_file)
    FileUtils.remove command_file
    previous_command
  end

  def set_up_zeus(using_socket: false)
    if using_socket
      create_file_in_root('.zeus.sock')
    else
      create_file_in_root('zeus.json')
    end
  end

  def set_up_spring_for(runner)
    create_gemfile_with("spring-commands-#{runner}")
  end

  def execute_plug_mapping(plug_mapping)
    vim.command %{execute "normal \\#{plug_mapping}"}
  end

  def create_gemfile_with(gem_name)
    create_file_in_root 'Gemfile.lock', <<-GEMFILE
      GEM
        remote: https://rubygems.org/
        specs:
          #{gem_name} (1.2.5)
    GEMFILE
  end

  def create_git_repo
    system 'git init >/dev/null'
  end
end
