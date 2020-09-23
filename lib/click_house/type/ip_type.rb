# frozen_string_literal: true

module ClickHouse
  module Type
    class IPType < BaseType
      def cast(value)
        IPAddr.new(value) unless value.nil?
      end

      def serialize(value)
        value.to_s unless value.nil?
      end
    end
  end
end
