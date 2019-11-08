SYSTEM_DATABASES = %w[default system]

RSpec.configure do |config|
  config.around(:each) do |example|
    ClickHouse.connection = nil
    example.run
  end
end
