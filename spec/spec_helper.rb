# frozen_string_literal: true

$ROOT_PATH = File.expand_path('../../', __FILE__).freeze

require 'bundler/setup'
require 'click_house'
require 'pry'

Dir[File.join($ROOT_PATH, 'spec', 'support', '*.rb')].each { |f| require f }

ClickHouse.config do |config|
  config.logger = Logger.new('log/test.log')
  config.database = 'click_house_rspec'
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
