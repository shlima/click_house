# frozen_string_literal: true

module ClickHouse
  module Type
    class BaseType
      def cast(_value, *)
        raise NotImplementedError, __method__
      end

      def cast_each(_value, *)
        raise NotImplementedError, __method__
      end

      def serialize_each(_value, *)
        raise NotImplementedError, __method__
      end

      # @return [Boolean]
      # true if type contains another type like Nullable(T) or Array(T)
      def container?
        false
      end

      # @return [Boolean]
      # true if type is a Map
      def map?
        false
      end

      # @return [Boolean]
      # true if type is a Tuple
      def tuple?
        false
      end

      # @return [Boolean]
      # skip type from DDL statements
      def ddl?
        true
      end
    end
  end
end
