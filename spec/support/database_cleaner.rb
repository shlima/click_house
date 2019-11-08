SYSTEM_DATABASES = %w[default system]

RSpec.configure do |config|
  config.around(:each) do |example|
    ClickHouse.connection.create_database(ClickHouse.config.database, if_not_exists: true)

    example.run

    ClickHouse.connection.databases.each do |database|
      next if SYSTEM_DATABASES.include?(database)

      ClickHouse.connection.drop_database(database, if_exists: true)
    end
  end
end
