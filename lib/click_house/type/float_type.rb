# frozen_string_literal: true

module ClickHouse
  module Type
    class FloatType < BaseType
      def cast(value)
        Float(value) unless value.nil?
      end

      def serialize(value)
        value.to_f unless value.nil?
      end
    end
  end
end
