![](./doc/logo.svg?sanitize=true)

# ClickHouse Ruby driver

[![pipeline status](https://travis-ci.com/shlima/click_house.svg?branch=master)](https://travis-ci.com/shlima/click_house)
[![Code Climate](https://codeclimate.com/github/shlima/click_house/badges/gpa.svg)](https://codeclimate.com/github/shlima/click_house)
[![Gem Version](https://badge.fury.io/rb/click_house.svg)](https://badge.fury.io/rb/click_house)

```bash
# Requires Ruby >= 2.5
gem install click_house
```

A modern Ruby database driver for ClickHouse. [ClickHouse](https://clickhouse.yandex) 
is a high-performance column-oriented database management system developed by 
[Yandex](https://yandex.com/company) which operates Russia's most popular search engine.

> This development was inspired by currently [unmaintainable alternative](https://github.com/archan937/clickhouse)
> but rewritten and well tested

### Why use the HTTP interface and not the TCP interface?

Well, the developers of ClickHouse themselves [discourage](https://github.com/yandex/ClickHouse/issues/45#issuecomment-231194134) using the TCP interface.

> TCP transport is more specific, we don't want to expose details.
Despite we have full compatibility of protocol of different versions of client and server, we want to keep the ability to "break" it for very old clients. And that protocol is not too clean to make a specification.

Yandex uses HTTP interface for working from Java and Perl, Python and Go as well as shell scripts. 

# TOC

* [Configuration](#configuration)
* [Usage](#usage)
* [Queries](#queries)
* [Insert](#insert)
* [Create a table](#create-a-table)
* [Alter table](#alter-table)
* [Type casting](#type-casting)
* [Using with a connection pool](#using-with-a-connection-pool)
* [Using with Rails](#using-with-rails)
* [Using with ActiveRecord](#using-with-activerecord)
* [Using with RSpec](#using-with-rspec)
* [Development](#development)

## Configuration

```ruby
ClickHouse.config do |config|
  config.logger = Logger.new(STDOUT)
  config.adapter = :net_http
  config.database = 'metrics'
  config.url = 'http://localhost:8123'
  config.timeout = 60
  config.open_timeout = 3
  config.ssl_verify = false
  config.headers = {}
  
  # or provide connection options separately
  config.scheme = 'http' 
  config.host = 'localhost' 
  config.port = 'port' 
  
  # if you use HTTP basic Auth
  config.username = 'user' 
  config.password = 'password' 
end
```

Alternative, you can assign configuration parameters via a hash

```ruby
ClickHouse.config.assign(logger: Logger.new(STDOUT))
```

Now you are able to communicate with ClickHouse:

```ruby
ClickHouse.connection.ping #=> true
```
You can easily build a new raw connection and override any configuration parameter 
(such as database name, connection address)

```ruby
@connection = ClickHouse::Connection.new(ClickHouse::Config.new(logger: Rails.logger))
@connection.ping
```

## Usage

```ruby
ClickHouse.connection.ping #=> true
ClickHouse.connection.replicas_status #=> true

ClickHouse.connection.databases #=> ["default", "system"]
ClickHouse.connection.create_database('metrics', if_not_exists: true, engine: nil, cluster: nil)
ClickHouse.connection.drop_database('metrics', if_exists: true, cluster: nil)

ClickHouse.connection.tables #=> ["visits"]
ClickHouse.connection.describe_table('visits') #=> [{"name"=>"id", "type"=>"FixedString(16)", "default_type"=>""}]
ClickHouse.connection.table_exists?('visits', temporary: nil) #=> true
ClickHouse.connection.drop_table('visits', if_exists: true, temporary: nil, cluster: nil)
ClickHouse.connection.create_table(*) # see <Create a table> section
ClickHouse.connection.truncate_table('name', if_exists: true, cluster: nil)
ClickHouse.connection.truncate_tables(['table_1', 'table_2'], if_exists: true, cluster: nil)
ClickHouse.connection.truncate_tables # will truncate all tables in database
ClickHouse.connection.rename_table('old_name', 'new_name', cluster: nil)
ClickHouse.connection.rename_table(%w[table_1 table_2], %w[new_1 new_2], cluster: nil)
```

## Queries
### Select All

Select all type-casted result set

```ruby
@result = ClickHouse.connection.select_all('SELECT * FROM visits')

# all enumerable methods are delegated like #each, #map, #select etc
@result.to_a #=> [{"date"=>#<Date: 2000-01-01>, "id"=>1}]

# you can access raw data
@result.meta #=> [{"name"=>"date", "type"=>"Date"}, {"name"=>"id", "type"=>"UInt32"}] 
@result.data #=> [{"date"=>"2000-01-01", "id"=>1}, {"date"=>"2000-01-02", "id"=>2}] 
@result.statistics #=> {"elapsed"=>0.0002271, "rows_read"=>2, "bytes_read"=>12}
```

### Select Value

Select value returns exactly one type-casted value

```ruby
ClickHouse.connection.select_value('SELECT COUNT(*) from visits') #=> 0
ClickHouse.connection.select_value("SELECT toDate('2019-01-01')") #=> #<Date: 2019-01-01>
ClickHouse.connection.select_value("SELECT toDateOrZero(NULL)") #=> nil
```

### Select One

Returns a record hash with the column names as keys and column values as values.

```ruby
ClickHouse.connection.select_one('SELECT date, SUM(id) AS sum FROM visits GROUP BY date')
#=> {"date"=>#<Date: 2000-01-01>, "sum"=>1}
```

### Execute Raw SQL

By default, gem provides parser for `JSON` and `CSV` response formats. Type conversion
available for the `JSON`.

```ruby
# format not specified
response = ClickHouse.connection.execute <<~SQL
  SELECT count(*) AS counter FROM rspec
SQL

response.body #=> "2\n"

# JSON
response = ClickHouse.connection.execute <<~SQL
  SELECT count(*) AS counter FROM rspec FORMAT JSON
SQL

response.body #=> {"meta"=>[{"name"=>"counter", "type"=>"UInt64"}], "data"=>[{"counter"=>"2"}], "rows"=>1, "statistics"=>{"elapsed"=>0.0002412, "rows_read"=>2, "bytes_read"=>4}}

# CSV
response = ClickHouse.connection.execute <<~SQL
  SELECT count(*) AS counter FROM rspec FORMAT CSV
SQL

response.body #=> [["2"]]

# You may use any format supported by ClickHouse
response = ClickHouse.connection.execute <<~SQL
  SELECT count(*) AS counter FROM rspec FORMAT RowBinary
SQL

response.body #=> "\u0002\u0000\u0000\u0000\u0000\u0000\u0000\u0000" 
```

## Insert

When column names and values are transferred separately

```ruby
ClickHouse.connection.insert('table', columns: %i[id name]) do |buffer|
  buffer << [1, 'Mercury']
  buffer << [2, 'Venus']
end 

ClickHouse.connection.insert('table', columns: %i[id name], values: [[1, 'Mercury'], [2, 'Venus']])
#=> true
```

When rows are passed as a hash


```ruby
ClickHouse.connection.insert('table', values: [{ name: 'Sun', id: 1 }, { name: 'Moon', id: 2 }])

ClickHouse.connection.insert('table') do |buffer|
  buffer << { name: 'Sun', id: 1 }
  buffer << { name: 'Moon', id: 2 }
end
#=> true
```

## Create a table
### Create table using DSL

```ruby
ClickHouse.connection.create_table('visits', if_not_exists: true, engine: 'MergeTree(date, (year, date), 8192)') do |t|
  t.FixedString :id, 16
  t.UInt16      :year
  t.Date        :date
  t.DateTime    :time, 'UTC'
  t.Decimal     :money, 5, 4
  t.String      :event
  t.UInt32      :user_id
  t.IPv4        :ipv4
  t.IPv6        :ipv6
end
```

### Create nullable columns

```ruby
ClickHouse.connection.create_table('visits', engine: 'TinyLog') do |t|
  t.UInt16 :id, 16, nullable: true
end
```

### Set column options

```ruby
ClickHouse.connection.create_table('visits', engine: 'MergeTree(date, (year, date), 8192)') do |t|
  t.UInt16  :year
  t.Date    :date
  t.UInt16  :id, 16, default: 0, ttl: 'date + INTERVAL 1 DAY'
end
```

### Define column with custom SQL

```ruby
ClickHouse.connection.create_table('visits', engine: 'TinyLog') do |t|
  t << "vendor Enum('microsoft' = 1, 'apple' = 2)"
  t << "tags Array(String)"
end
```

### Define nested structures

```ruby
ClickHouse.connection.create_table('visits', engine: 'TinyLog') do |t|
  t.UInt8 :id
  t.Nested :json do |n|
    n.UInt8 :cid
    n.Date  :created_at
    n.Date  :updated_at
  end
end
```

### Set table options

```ruby
ClickHouse.connection.create_table('visits', 
  order: 'year',
  ttl: 'date + INTERVAL 1 DAY',
  sample: 'year',
  settings: 'index_granularity=8192',
  primary_key: 'year',
  engine: 'MergeTree') do |t|
  t.UInt16  :year
  t.Date    :date
end
```

### Create table with raw SQL

```ruby
ClickHouse.connection.execute <<~SQL
  CREATE TABLE visits(int Nullable(Int8), date Nullable(Date)) ENGINE TinyLog
SQL
```

## Alter table
### Alter table with DSL
```ruby
ClickHouse.connection.add_column('table', 'column_name', :UInt64, default: nil, if_not_exists: nil, after: nil, cluster: nil)
ClickHouse.connection.drop_column('table', 'column_name', if_exists: nil, cluster: nil)
ClickHouse.connection.clear_column('table', 'column_name', partition: 'partition_name', if_exists: nil, cluster: nil)
ClickHouse.connection.modify_column('table', 'column_name', type: :UInt64, default: nil, if_exists: false, cluster: nil)
```

### Alter table with SQL

```ruby
# By SQL in argument
ClickHouse.connection.alter_table('table', 'DROP COLUMN user_id', cluster: nil)

# By SQL in a block
ClickHouse.connection.alter_table('table', cluster: nil) do 
  <<~SQL
    MOVE PART '20190301_14343_16206_438' TO VOLUME 'slow'
  SQL  
end
```

## Type casting

By default gem provides all necessary type casting, but you may overwrite or define
your own logic 

```ruby
class DateType
  def cast(value)
    Date.parse(value)
  end 
  
  def serialize(value)
    value.strftime('%Y-%m-%d')
  end
end

ClickHouse.add_type('Date', DateType.new)
```

Actually `serialize` function is not used for now, but you may use it manually:

```ruby
time_type = ClickHouse::Type::DateTimeType.new
string_type = ClickHouse::Type::FixedStringType.new 

ClickHouse.connection.insert('table', columns: %i[name time]) do |buffer|
  buffer << [string_type.serialize('a' * 1000, 20), time_type.serialize(Time.current, 'Europe/Moscow')]
end

## alternatively
data = @records.map do |record|
  {
    id: record.id,
    time: ClickHouse.types['DateTime(%s)'].serialize(Time.current)
  }
end
```

If native type supports arguments, define *String* type with `%s` 
argument and *Numeric* type with `%d` argument:

```ruby
class DateTimeType
  def cast(value, time_zone)
    Time.parse("#{value} #{time_zone}")
  end 
end

ClickHouse.add_type('DateTime(%s)', DateTimeType.new)
```

if you need to redefine all built-in types with your implementation, 
just clear the default type system:

```ruby
ClickHouse.types.clear
ClickHouse.types # => {}
ClickHouse.types.default #=> #<ClickHouse::Type::UndefinedType:0x00007fc1cfabd630>
```

## Using with a connection pool

```ruby
require 'connection_pool'

ClickHouse.connection = ConnectionPool.new(size: 2) do
  ClickHouse::Connection.new(ClickHouse::Config.new(url: 'http://replica.example.com'))
end

ClickHouse.connection.with do |conn|
  conn.tables
end
```

## Using with Rails

```yml
# config/click_house.yml

default: &default
  url: http://localhost:8123
  timeout: 60
  open_timeout: 3

development:
  database: ecliptic_development
  <<: *default

test:
  database: ecliptic_test
  <<: *default
  
production:
  <<: *default
  database: ecliptic_production
```

```ruby
# config/initializers/click_house.rb

ClickHouse.config do |config|
  config.logger = Rails.logger
  config.assign(Rails.application.config_for('click_house'))
end 
```

```ruby
# lib/tasks/click_house.rake
namespace :click_house do
  task prepare: :environment do
    @environments = Rails.env.development? ? %w[development test] : [Rails.env]
  end

  task drop: :prepare do
    @environments.each do |env|
      config = ClickHouse.config.clone.assign(Rails.application.config_for('click_house', env: env))
      connection = ClickHouse::Connection.new(config)
      connection.drop_database(config.database, if_exists: true)
    end
  end

  task create: :prepare do
    @environments.each do |env|
      config = ClickHouse.config.clone.assign(Rails.application.config_for('click_house', env: env))
      connection = ClickHouse::Connection.new(config)
      connection.create_database(config.database, if_not_exists: true)
    end
  end
end
```

Prepare the ClickHouse database:

```bash
rake click_house:drop click_house:create
```

If your are using SQL Database in Rails, you can manage ClickHouse migrations
using `ActiveRecord::Migration` mechanism

```ruby
class CreateAdvertVisits < ActiveRecord::Migration[6.0]
  def up
    ClickHouse.connection.create_table('visits', engine: 'MergeTree(date, (account_id, advert_id), 512)') do |t|
      t.UInt16   :account_id
      t.UInt16   :user_id
      t.Date     :date
    end
  end

  def down    
    ClickHouse.connection.drop_table('visits')
  end
end
```

## Using with ActiveRecord

if you use `ActiveRecord`, you can use the ORM query builder by using fake models
(empty tables must be present in the SQL database `create_table :visits`)

```ruby
class ClickHouseRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def agent
      ClickHouse.connection
    end

    def insert(*argv, &block)
      agent.insert(table_name, *argv, &block)
    end

    def select_one
      agent.select_one(current_scope.to_sql)
    end

    def select_value
      agent.select_value(current_scope.to_sql)
    end

    def select_all
      agent.select_all(current_scope.to_sql)
    end
  end
end
````

````ruby
# FAKE MODEL FOR ClickHouse 
class Visit < ClickHouseRecord
  scope :with_os, -> { where.not(os_family_id: nil) }
end

Visit.with_os.select('COUNT(*) as counter').group(:ipv4).select_all
#=> [{ 'ipv4' => 1455869, 'counter' => 104 }]

Visit.with_os.select('COUNT(*)').select_value 
#=> 20_345_678
 
Visit.where(user_id: 1).select_one 
#=> { 'ipv4' => 1455869, 'user_id' => 1 }  
```` 

## Using with RSpec

You can clear the data table before each test with RSpec

```ruby
RSpec.configure do |config|
  config.before(:each, truncate_click_house: true) do
    ClickHouse.connection.truncate_tables
  end
end
```

```ruby
RSpec.describe Api::MetricsCountroller, truncate_click_house: true do 
  it { }
  it { }
end
```

## Development

```bash
make dockerize
rspec
rubocop
```
