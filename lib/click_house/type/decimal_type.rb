# frozen_string_literal: true

module ClickHouse
  module Type
    class DecimalType < BaseType
      def cast(value, precision = Float::DIG, _scale = nil)
        BigDecimal(value, precision.to_f)
      end

      def serialize(value, precision = Float::DIG, _scale = nil)
        BigDecimal(value, precision.to_f) unless value.nil?
      end
    end
  end
end
