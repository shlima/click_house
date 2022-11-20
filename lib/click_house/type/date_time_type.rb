# frozen_string_literal: true

module ClickHouse
  module Type
    class DateTimeType < BaseType
      def cast(value, tz = nil)
        if tz
          Time.find_zone(tz).parse(value)
        else
          Time.parse(value)
        end
      end

      def serialize(value, *)
        value.strftime('%Y-%m-%d %H:%M:%S')
      end
    end
  end
end
