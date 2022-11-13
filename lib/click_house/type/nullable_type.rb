# frozen_string_literal: true

module ClickHouse
  module Type
    class NullableType < BaseType
      def cast_each(value, *_argv)
        yield(value) unless value.nil?
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
