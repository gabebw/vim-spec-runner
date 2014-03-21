require 'spec_helper'

describe 'An RSpec file' do
  it 'has the correct runner' do
    vim.edit 'my_spec.rb'
    vim.normal 'RunCurrentFile'
  end
end
