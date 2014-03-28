shared_examples 'a command with fallbacks' do |vim_command|
  context 'when not in a spec file' do
    context 'with a previous command' do
      it 'falls back to most recent behavior' do
        vim.edit 'sample_spec.rb'
        vim.command(vim_command)

        original_command = purge_previous_command
        vim.edit 'implementation_file.rb'
        vim.command(vim_command)

        expect(command).to eq original_command
      end
    end

    context 'with no previous command' do
      it 'does not run the spec command and alerts the user' do
        with_clean_vim do |clean_vim|
          clean_vim.edit 'random_file.rb'
          clean_vim.command(vim_command)

          expect(no_command_was_run).to be_true
          expect(last_vim_error(clean_vim)).to match /unable to determine correct spec runner/i
        end
      end
    end
  end
end
