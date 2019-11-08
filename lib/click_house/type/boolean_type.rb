# frozen_string_literal: true

module ClickHouse
  module Type
    class BooleanType < BaseType
      TRUE_VALUE = 1
      FALSE_VALUE = 0

      def cast(value)
        value.to_i == TRUE_VALUE
      end

      def serialize(value)
        value ? TRUE_VALUE : FALSE_VALUE
      end
    end
  end
end
