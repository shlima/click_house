# frozen_string_literal: true

module ClickHouse
  module Response
    class ResultSet
      extend Forwardable
      include Enumerable

      TYPE_ARGV_DELIM = ','
      NULLABLE = 'Nullable'
      NULLABLE_TYPE_RE = /#{NULLABLE}\((.+)\)/i.freeze

      def_delegators :to_a,
                     :inspect, :each, :fetch, :length, :count, :size,
                     :first, :last, :[], :to_h

      attr_reader :meta, :data, :totals, :statistics

      class << self
        # @return [Array<String, Array>]
        # * first element is name of "ClickHouse.types.keys"
        # * second element is extra arguments that should to be passed to <cast> function
        #
        # @input "DateTime('Europe/Moscow')"
        # @output "DateTime(%s)"
        #
        # @input "Nullable(Decimal(10, 5))"
        # @output "Nullable(Decimal(%s, %s))"
        #
        # @input "Decimal(10, 5)"
        # @output "Decimal(%s, %s)"
        def extract_type_info(type)
          type = type.gsub(NULLABLE_TYPE_RE, '\1')
          nullable = Regexp.last_match(1)
          argv = []

          type = type.gsub(/\((.+)\)/, '')

          if (match = Regexp.last_match(1))
            counter = Array.new(match.count(TYPE_ARGV_DELIM).next) { '%s' }
            type = "#{type}(#{counter.join("#{TYPE_ARGV_DELIM} ")})"
            argv = match.split("#{TYPE_ARGV_DELIM} ")
          end

          [nullable ? "#{NULLABLE}(#{type})" : type, argv]
        end
      end

      # @param meta [Array]
      # @param data [Array]
      # @param totals [Array, Hash, NilClass] Support for 'GROUP BY WITH TOTALS' modifier
      #   https://clickhouse.tech/docs/en/sql-reference/statements/select/group-by/#with-totals-modifier
      #   Hash in JSON format and Array in JSONCompact
      # @param statistics [Hash, NilClass] Stats about duration of query and number of rows
      #   {"elapsed"=>0.0524, "rows_read"=>10, "bytes_read"=>80}
      def initialize(meta:, data:, totals: nil, statistics: nil)
        @meta = meta
        @data = data
        @totals = totals
        @statistics = Hash(statistics)
      end

      def to_a
        @to_a ||= data.each { |row| array_rows? ? type_cast_array_row(row) : type_cast_hash_row(row) }
      end

      def types
        @types ||= meta.each_with_object({}).with_index do |(row, object), index|
          type_name, argv = self.class.extract_type_info(row.fetch('type'))
          object_key = array_rows? ? index : row.fetch('name')

          object[object_key] = {
            caster:    ClickHouse.types[type_name],
            arguments: argv
          }
        end
      end

      private

      def type_cast_hash_row(row)
        row.each do |name, value|
          casting = types.fetch(name)
          row[name] = casting.fetch(:caster).cast(value, *casting.fetch(:arguments))
        end
      end

      def type_cast_array_row(row)
        row.each.with_index do |value, index|
          casting = types.fetch(index)
          row[index] = casting.fetch(:caster).cast(value, *casting.fetch(:arguments))
        end
      end

      def array_rows?
        return @array_rows if instance_variable_defined?(:@array_rows)

        @array_rows = data.first.is_a?(Array)
      end
    end
  end
end
