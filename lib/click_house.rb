# frozen_string_literal: true

require 'date'
require 'json'
require 'csv'
require 'uri'
require 'logger'
require 'faraday'
require 'forwardable'
require 'bigdecimal'
require 'active_support/core_ext/time/calculations'
require 'click_house/version'
require 'click_house/errors'
require 'click_house/response'
require 'click_house/type'
require 'click_house/middleware'
require 'click_house/extend'
require 'click_house/ast'
require 'click_house/util'
require 'click_house/definition'

module ClickHouse
  extend Extend::TypeDefinition
  extend Extend::Configurable
  extend Extend::Connectible

  autoload :Config, 'click_house/config'
  autoload :Connection, 'click_house/connection'

  add_type 'Array', Type::ArrayType.new
  add_type 'Nullable', Type::NullableType.new
  add_type 'Map', Type::MapType.new
  add_type 'LowCardinality', Type::LowCardinalityType.new
  add_type 'Tuple', Type::TupleType.new

  %w[Date].each do |column|
    add_type column, Type::DateType.new
  end

  %w[String FixedString(%d) UUID].each do |column|
    add_type column, Type::StringType.new
  end

  %w[DateTime DateTime(%s)].each do |column|
    add_type column, Type::DateTimeType.new
  end

  ['DateTime64(%d)', 'DateTime64(%d, %s)'].each do |column|
    add_type column, Type::DateTime64Type.new
  end

  ['Decimal(%d, %d)', 'Decimal32(%d)', 'Decimal64(%d)', 'Decimal128(%d)', 'Decimal256(%d)'].each do |column|
    add_type column, Type::DecimalType.new
  end

  %w[UInt8 UInt16 UInt32 UInt64 Int8 Int16 Int32 Int64].each do |column|
    add_type column, Type::IntegerType.new
  end

  %w[Float32 Float64].each do |column|
    add_type column, Type::FloatType.new
  end

  %w[IPv4 IPv6].each do |column|
    add_type column, Type::IPType.new
  end
end
