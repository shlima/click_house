# frozen_string_literal: true

module ClickHouse
  module Type
    class BooleanType < BaseType
      TRUE_VALUE = 1
      FALSE_VALUE = 0
      TRUE_VALUES = Set[1, '1', true].freeze

      def cast(value)
        TRUE_VALUES.include?(value)
      end

      def serialize(value)
        TRUE_VALUES.include?(value) ? TRUE_VALUE : FALSE_VALUE
      end
    end
  end
end
