# frozen_string_literal: true

module ClickHouse
  module Type
    class DateType < BaseType
      FORMAT = '%Y-%m-%d'

      def cast(value)
        Date.strptime(value, FORMAT)
      end

      def serialize(value)
        value.strftime(FORMAT)
      end
    end
  end
end
