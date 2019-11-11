# frozen_string_literal: true

module ClickHouse
  module Type
    class UndefinedType < BaseType
      def cast(value, *)
        value
      end

      def serialize(value, *)
        value
      end
    end
  end
end
