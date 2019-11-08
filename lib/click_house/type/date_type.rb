# frozen_string_literal: true

module ClickHouse
  module Type
    class DateType < BaseType
      def cast(value)
        Date.parse(value)
      end

      def serialize(value)
        value.strftime('%Y-%m-%d')
      end
    end
  end
end
