# frozen_string_literal: true

module ClickHouse
  module Type
    class DateTime64Type < BaseType
      def cast(value, _precision = nil, tz = nil)
        DateTime.parse("#{value} #{tz}")
      end

      def serialize(value, precision = 3)
        value.strftime("%Y-%m-%d %H:%M:%S.%#{precision}N")
      end
    end
  end
end
