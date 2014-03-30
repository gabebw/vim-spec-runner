RSpec::Matchers.define :normal_map_to do |expected_command|
  match do |keys|
    mapped_command(keys) == expected_command
  end

  failure_message_for_should do |keys|
    if mapped_command(keys).empty?
      "No mapping for '#{keys}'"
    else
      "expected to map to '#{expected_command}' but actually mapped to '#{mapped_command(keys)}'"
    end
  end

  def mapped_command(keys)
    vim.command "echo maparg('#{keys}', 'n')"
  end
end
