# frozen_string_literal: true

$ROOT_PATH = File.expand_path('../../', __FILE__).freeze

require 'bundler/setup'
require 'click_house'
require 'pry'
require 'webmock/rspec'

Dir[File.join($ROOT_PATH, 'spec', 'support', '*.rb')].each { |f| require f }

ClickHouse.config do |config|
  config.logger = Logger.new('log/test.log', level: Logger::DEBUG)
  config.database = 'click_house_rspec'
  config.url = 'http://localhost:8123?allow_suspicious_low_cardinality_types=1&output_format_arrow_low_cardinality_as_dictionary=1'
end

WebMock.disable_net_connect!(allow_localhost: true)

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
