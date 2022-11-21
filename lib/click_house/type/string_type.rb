# frozen_string_literal: true

module ClickHouse
  module Type
    class StringType < BaseType
      def cast(value, *)
        value.to_s
      end

      def serialize(value, *)
        value.to_s
      end
    end
  end
end
