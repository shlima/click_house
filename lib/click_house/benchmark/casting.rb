# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'
require 'pry'
require_relative '../../click_house'


ClickHouse.config.json_serializer = ClickHouse::Serializer::JsonOjSerializer
ClickHouse.config.json_parser = ClickHouse::Middleware::ParseJsonOj
ClickHouse.connection.drop_table('benchmark', if_exists: true)
ClickHouse.connection.execute <<~SQL
CREATE TABLE benchmark(
  int   Nullable(Int8),
  date  Nullable(Date),
  array Array(String),
  map   Map(String, IPv4)
) ENGINE Memory
SQL

INPUT = Array.new(200_000, {
  'int' => 21341234,
  'date' => Date.new(2022, 1, 1),
  'array' => ['foo'],
  'map' => {'ip' => IPAddr.new('127.0.0.1')}
})

Benchmark.bm do |x|
  x.report('insert: no casting') do
    ClickHouse.connection.insert('benchmark', INPUT)
  end

  x.report('insert: with casting') do
    schema = ClickHouse.connection.table_schema('benchmark')
    ClickHouse.connection.insert('benchmark', schema.serialize(INPUT))
  end

  x.report('select: no casting') do
    ClickHouse.connection.select_all('SELECT * FROM benchmark').data
  end

  x.report('select: with casting') do
    ClickHouse.connection.select_all('SELECT * FROM benchmark').to_a
  end
end
