# frozen_string_literal: true

module ClickHouse
  module Type
    class IPType < BaseType
      def cast(value)
        IPAddr.new(value)
      end

      def serialize(value)
        value.to_s
      end
    end
  end
end
