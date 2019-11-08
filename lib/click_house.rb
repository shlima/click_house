# frozen_string_literal: true

require 'date'
require 'json'
require 'csv'
require 'uri'
require 'logger'
require 'faraday'
require 'forwardable'
require 'faraday_middleware'
require 'click_house/version'
require 'click_house/errors'
require 'click_house/response'
require 'click_house/type'
require 'click_house/middleware'
require 'click_house/extend'
require 'click_house/util'

module ClickHouse
  extend Extend::TypeDefinition
  extend Extend::Configurable
  extend Extend::Connectible

  autoload :Config, 'click_house/config'
  autoload :Connection, 'click_house/connection'

  %w[Date].each do |column|
    add_type column, Type::DateType.new
    add_type "Nullable(#{column})", Type::NullableType.new(Type::DateType.new)
  end

  %w[UInt8 UInt16 UInt32 UInt64 Int8 Int16 Int32 Int64].each do |column|
    add_type column, Type::IntegerType.new
    add_type "Nullable(#{column})", Type::NullableType.new(Type::IntegerType.new)
  end

  %w[Float32 Float64].each do |column|
    add_type column, Type::FloatType.new
    add_type "Nullable(#{column})", Type::NullableType.new(Type::IntegerType.new)
  end
end
