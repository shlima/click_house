# frozen_string_literal: true

module ClickHouse
  module Type
    class LowCardinalityType < BaseType
      def cast_each(value, *_argv)
        yield(value)
      end

      def serialize_each(value, *_argv)
        yield(value)
      end

      def container?
        true
      end
    end
  end
end
