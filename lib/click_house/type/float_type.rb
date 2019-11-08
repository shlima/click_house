# frozen_string_literal: true

module ClickHouse
  module Type
    class FloatType < BaseType
      def cast(value)
        Float(value)
      end

      def serialize(value)
        value.to_f
      end
    end
  end
end
