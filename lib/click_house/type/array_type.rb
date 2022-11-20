# frozen_string_literal: true

module ClickHouse
  module Type
    class ArrayType < BaseType
      def cast_each(value, *_argv, &block)
        value.map(&block)
      end

      def serialize_each(value, *_argv, &block)
        value.map(&block)
      end

      def container?
        true
      end

      def ddl?
        false
      end
    end
  end
end
