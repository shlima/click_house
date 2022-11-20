# frozen_string_literal: true

module ClickHouse
  module Type
    class DecimalType < BaseType
      MAXIMUM = Float::DIG.next

      # clickhouse:
      # P - precision. Valid range: [ 1 : 76 ]. Determines how many decimal digits number can have (including fraction).
      # S - scale. Valid range: [ 0 : P ]. Determines how many decimal digits fraction can have.
      #
      # when Oj parser @refs https://stackoverflow.com/questions/47885304/deserialise-json-numbers-as-bigdecimal
      def cast(value, precision = MAXIMUM, _scale = nil)
        case value
        when BigDecimal
          value
        when String
          BigDecimal(value)
        else
          BigDecimal(value, precision > MAXIMUM ? MAXIMUM : precision)
        end
      end

      # @return [BigDecimal]
      def serialize(value, precision = MAXIMUM, _scale = nil)
        cast(value, precision)
      end
    end
  end
end
