# frozen_string_literal: true

module ClickHouse
  module Type
    class BaseType
      def cast(_value, *)
        raise NotImplementedError, __method__
      end

      def serialize(_value, *)
        raise NotImplementedError, __method__
      end
    end
  end
end
