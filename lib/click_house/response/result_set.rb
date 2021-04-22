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
      # @param totals [Array|Hash|NilClass] Support for 'GROUP BY WITH TOTALS' modifier
      #   https://clickhouse.tech/docs/en/sql-reference/statements/select/group-by/#with-totals-modifier
      #   Hash in JSON format and Array in JSONCompact
      def initialize(meta:, data:, totals: nil, statistics: nil)
        @meta = meta
        @data = data
        @totals = totals
        @statistics = Hash(statistics)
      end

      def to_a
        @to_a ||= data.each do |row|
          row.each do |name, value|
            casting = types.fetch(name)
            row[name] = casting.fetch(:caster).cast(value, *casting.fetch(:arguments))
          end
        end
      end

      def types
        @types ||= meta.each_with_object({}) do |row, object|
          type_name, argv = self.class.extract_type_info(row.fetch('type'))

          object[row.fetch('name')] = {
            caster: ClickHouse.types[type_name],
            arguments: argv
          }
        end
      end
    end
  end
end
