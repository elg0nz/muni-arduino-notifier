require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'rspec/autorun'


RSpec.configure do |config|
    config.mock_with :rspec
    config.expect_with :rspec do |c|
        c.syntax = :expect
    end
end
