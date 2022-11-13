# frozen_string_literal: true

module ClickHouse
  module Type
    class LowCardinalityType < BaseType
      def cast_each(value, *_argv)
        yield(value) unless value.nil?
      end

      def container?
        true
      end
    end
  end
end
