# frozen_string_literal: true

module ClickHouse
  module Type
    class DateTimeType < BaseType
      FORMAT = '%Y-%m-%d %H:%M:%S'

      def cast(value, tz = nil)
        if tz
          Time.find_zone(tz).strptime(value, FORMAT)
        else
          Time.strptime(value, FORMAT)
        end
      end

      def serialize(value, tz = nil)
        if tz
          value.in_time_zone(Time.find_zone(tz)).strftime(FORMAT)
        else
          value.strftime(FORMAT)
        end
      end
    end
  end
end
