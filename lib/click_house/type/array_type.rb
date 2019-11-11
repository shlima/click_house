# frozen_string_literal: true

module ClickHouse
  module Type
    class ArrayType < BaseType
      attr_reader :subtype

      def initialize(subtype)
        @subtype = subtype
      end

      def cast(value, *)
        value
      end

      def serialize(array, *argv)
        return unless array.is_a?(Array)

        array.map do |value|
          subtype.serialize(value, *argv)
        end
      end
    end
  end
end
