# frozen_string_literal: true

module ClickHouse
  module Type
    class IntegerType < BaseType
      def cast(value)
        Integer(value)
      end

      def serialize(value)
        value.to_i
      end
    end
  end
end
