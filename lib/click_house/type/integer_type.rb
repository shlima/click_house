# frozen_string_literal: true

module ClickHouse
  module Type
    class IntegerType < BaseType
      def cast(value)
        Integer(value)
      end

      def serialize(value)
        value.to_i unless value.nil?
      end
    end
  end
end
