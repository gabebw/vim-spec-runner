RSpec::Matchers.define :have_no_normal_map_from do |expected_keys|
  match do |vim_instance|
    mapping_output(vim_instance, expected_keys) == 'No mapping found'
  end

  failure_message_for_should do |vim_instance|
    "expected no map for '#{expected_keys}' but it maps to something"
  end

  def mapping_output(vim_instance, expected_keys)
    vim_instance.command "nmap #{expected_keys}"
  end
end
