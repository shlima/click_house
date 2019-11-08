# frozen_string_literal: true

module ClickHouse
  module Response
    class ResultSet
      extend Forwardable
      include Enumerable

      def_delegators :to_a, :each, :fetch

      attr_reader :meta, :data

      # @param meta [Array]
      # @param data [Array]
      def initialize(meta:, data:)
        @meta = meta
        @data = data
      end

      def to_a
        @to_a ||= data.each do |row|
          row.each { |name, value| row[name] = types.fetch(name).cast(value) }
        end
      end

      def types
        @types ||= meta.each_with_object({}) do |row, object|
          object[row.fetch('name')] = ClickHouse.types[row.fetch('type')]
        end
      end

      def inspect
        to_a
      end
    end
  end
end
