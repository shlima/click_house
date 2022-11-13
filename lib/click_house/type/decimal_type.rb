# frozen_string_literal: true

module ClickHouse
  module Type
    class DecimalType < BaseType
      MAXIMUM = Float::DIG

      # clickhouse:
      # P - precision. Valid range: [ 1 : 76 ]. Determines how many decimal digits number can have (including fraction).
      # S - scale. Valid range: [ 0 : P ]. Determines how many decimal digits fraction can have.
      #
      # when Oj parser @refs https://stackoverflow.com/questions/47885304/deserialise-json-numbers-as-bigdecimal
      def cast(value, precision = Float::DIG, _scale = nil)
        case value
        when BigDecimal
          value
        when String
          BigDecimal(value)
        else
          BigDecimal(value, precision > MAXIMUM ? MAXIMUM : precision)
        end
      end

      def serialize(value, precision = Float::DIG, _scale = nil)
        BigDecimal(value, precision.to_i).to_f unless value.nil?
      end
    end
  end
end
