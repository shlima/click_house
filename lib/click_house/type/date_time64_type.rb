# frozen_string_literal: true

module ClickHouse
  module Type
    class DateTime64Type < BaseType
      def cast(value, _precision = nil, tz = nil)
        if tz
          Time.find_zone(tz).parse(value)
        else
          Time.parse(value)
        end
      end

      def serialize(value, precision = 3, _tz = nil)
        value.strftime("%Y-%m-%d %H:%M:%S.%#{precision}N")
      end
    end
  end
end
