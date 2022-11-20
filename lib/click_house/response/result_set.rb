# frozen_string_literal: true

module ClickHouse
  module Response
    class ResultSet
      extend Forwardable
      include Enumerable

      def_delegators :to_a,
                     :inspect, :each, :fetch, :length, :count, :size,
                     :first, :last, :[], :to_h

      attr_reader :config, :meta, :data, :totals, :statistics, :rows_before_limit_at_least

      # @param config [Config]
      # @param meta [Array]
      # @param data [Array]
      # @param totals [Array|Hash|NilClass] Support for 'GROUP BY WITH TOTALS' modifier
      #   https://clickhouse.tech/docs/en/sql-reference/statements/select/group-by/#with-totals-modifier
      #   Hash in JSON format and Array in JSONCompact
      # rubocop:disable Metrics/ParameterLists
      def initialize(config:, meta:, data:, totals: nil, statistics: nil, rows_before_limit_at_least: nil)
        @config = config
        @meta = meta
        @data = data
        @totals = totals
        @rows_before_limit_at_least = rows_before_limit_at_least
        @statistics = Hash(statistics)
      end
      # rubocop:enable Metrics/ParameterLists

      # @return [Array, Hash]
      # @param data [Array, Hash]
      def serialize(data)
        case data
        when Hash
          serialize_one(data)
        when Array
          data.map(&method(:serialize_one))
        else
          raise ArgumentError, "expect Hash or Array, got: #{data.class}"
        end
      end

      # @return [Hash]
      # @param row [Hash]
      def serialize_one(row)
        row.each_with_object({}) do |(key, value), object|
          object[key] = serialize_column(key, value)
        rescue KeyError => e
          raise SerializeError, "field <#{key}> does not exists in table schema: #{types.keys.join(', ')}", e.backtrace
        rescue StandardError => e
          raise SerializeError, "failed to serialize <#{key}> with #{stmt}, #{e.class}, #{e.message}", e.backtrace
        end
      end

      # @param name [String] column name
      # @param value [Any]
      def serialize_column(name, value)
        stmt = types.fetch(name)
        serialize_type(stmt, value)
      rescue KeyError => e
        raise SerializeError, "field <#{name}> does not exists in table schema: #{types.keys.join(', ')}", e.backtrace
      end

      def to_a
        @to_a ||= data.each do |row|
          row.each do |name, value|
            row[name] = cast_type(types.fetch(name), value)
          end
        end
      end

      # @return [Hash<String, Ast::Statement>]
      def types
        @types ||= meta.each_with_object({}) do |row, object|
          column = row.fetch(config.key('name'))
          # make symbol keys, if config.symbolize_keys is true,
          # to be able to cast and serialize properly
          object[config.key(column)] = begin
            current = Ast::Parser.new(row.fetch(config.key('type'))).parse
            assign_type(current)
            current
          end
        end
      end

      private

      # @param stmt [Ast::Statement]
      def assign_type(stmt)
        stmt.caster = ClickHouse.types[stmt.name]

        if stmt.caster.is_a?(Type::UndefinedType)
          placeholders = stmt.arguments.map(&:placeholder)
          stmt.caster = ClickHouse.types["#{stmt.name}(#{placeholders.join(', ')})"]
        end

        stmt.arguments.each(&method(:assign_type))
      end

      # @param stmt [Ast::Statement]
      def cast_type(stmt, value)
        return cast_container(stmt, value) if stmt.caster.container?
        return cast_map(stmt, Hash(value)) if stmt.caster.map?
        return cast_tuple(stmt, Array(value)) if stmt.caster.tuple?

        stmt.caster.cast(value, *stmt.arguments.map(&:value))
      end

      # @return [Hash]
      # @param stmt [Ast::Statement]
      # @param hash [Hash]
      def cast_map(stmt, hash)
        raise ArgumentError, "expect hash got #{hash.class}" unless hash.is_a?(Hash)

        key_type, value_type = stmt.arguments
        hash.each_with_object({}) do |(key, value), object|
          object[cast_type(key_type, key)] = cast_type(value_type, value)
        end
      end

      # @param stmt [Ast::Statement]
      def cast_container(stmt, value)
        stmt.caster.cast_each(value) do |item|
          # TODO: raise an error if multiple arguments
          cast_type(stmt.arguments.first, item)
        end
      end

      # @param stmt [Ast::Statement]
      def cast_tuple(stmt, value)
        value.map.with_index do |item, ix|
          cast_type(stmt.arguments.fetch(ix), item)
        end
      end

      # @param stmt [Ast::Statement]
      def serialize_type(stmt, value)
        return serialize_container(stmt, value) if stmt.caster.container?
        return serialize_map(stmt, value) if stmt.caster.map?
        return serialize_tuple(stmt, Array(value)) if stmt.caster.tuple?

        stmt.caster.serialize(value, *stmt.arguments.map(&:value))
      end

      # @param stmt [Ast::Statement]
      def serialize_container(stmt, value)
        stmt.caster.cast_each(value) do |item|
          # TODO: raise an error if multiple arguments
          serialize_type(stmt.arguments.first, item)
        end
      end

      # @return [Hash]
      # @param stmt [Ast::Statement]
      # @param hash [Hash]
      def serialize_map(stmt, hash)
        raise ArgumentError, "expect hash got #{hash.class}" unless hash.is_a?(Hash)

        key_type, value_type = stmt.arguments
        hash.each_with_object({}) do |(key, value), object|
          object[serialize_type(key_type, key)] = serialize_type(value_type, value)
        end
      end

      # @param stmt [Ast::Statement]
      def serialize_tuple(stmt, value)
        value.map.with_index do |item, ix|
          serialize_type(stmt.arguments.fetch(ix), item)
        end
      end
    end
  end
end
