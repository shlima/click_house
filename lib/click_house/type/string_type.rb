# frozen_string_literal: true

module ClickHouse
  module Type
    class StringType < BaseType
      def cast(value, *)
        value.to_s unless value.nil?
      end

      def serialize(value)
        value.to_s unless value.nil?
      end
    end
  end
end
