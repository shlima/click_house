# frozen_string_literal: true

module ClickHouse
  module Type
    class FixedStringType < BaseType
      def cast(value, _limit = nil)
        value.to_s
      end

      def serialize(value, limit = nil)
        value[0..(limit ? limit.pred : -1)] unless value.nil?
      end
    end
  end
end
