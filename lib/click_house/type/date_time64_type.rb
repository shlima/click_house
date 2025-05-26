# frozen_string_literal: true

module ClickHouse
  module Type
    class DateTime64Type < BaseType
      BASE_FORMAT = '%Y-%m-%d %H:%M:%S'
      CAST_FORMAT = "#{BASE_FORMAT}.%N"
      SERIALIZE_FORMATS = {
        0 => BASE_FORMAT,
        1 => "#{BASE_FORMAT}.%1N",
        2 => "#{BASE_FORMAT}.%2N",
        3 => "#{BASE_FORMAT}.%3N",
        4 => "#{BASE_FORMAT}.%4N",
        5 => "#{BASE_FORMAT}.%5N",
        6 => "#{BASE_FORMAT}.%6N",
        7 => "#{BASE_FORMAT}.%7N",
        8 => "#{BASE_FORMAT}.%8N",
        9 => "#{BASE_FORMAT}.%9N",
      }.freeze

      # Tick size (precision):
      #   10-precision seconds.
      #   Valid range: [ 0 : 9 ].
      #   Typically are used - 3 (milliseconds), 6 (microseconds), 9 (nanoseconds).
      def cast(value, precision = 0, tz = nil)
        format = precision.zero? ? BASE_FORMAT : CAST_FORMAT

        if tz
          Time.find_zone(tz).strptime(value, format)
        else
          Time.strptime(value, format)
        end
      end

      def serialize(value, precision = 3, tz = nil)
        if tz
          value.in_time_zone(Time.find_zone(tz)).strftime(SERIALIZE_FORMATS.fetch(precision))
        else
          value.strftime(SERIALIZE_FORMATS.fetch(precision))
        end
      end
    end
  end
end
