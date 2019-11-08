# frozen_string_literal: true

module ClickHouse
  module Type
    class NullableType < BaseType
      attr_reader :subtype

      def initialize(subtype)
        @subtype = subtype
      end

      def cast(value)
        subtype.cast(value) unless value.nil?
      end

      def serialize(value)
        value.nil ? 'NULL' : subtype.serialize(value)
      end
    end
  end
end
