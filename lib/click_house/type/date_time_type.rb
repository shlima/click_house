# frozen_string_literal: true

module ClickHouse
  module Type
    class DateTimeType < BaseType
      def cast(value, tz = nil)
        DateTime.parse("#{value} #{tz}")
      end

      def serialize(value)
        value.strftime('%Y-%m-%d %H:%m:%S %p %z')
      end
    end
  end
end
