# frozen_string_literal: true

module ClickHouse
  module Extend
    module TypeDefinition
      def types
        @types ||= Hash.new(Type::UndefinedType.new)
      end

      def add_type(type, klass)
        types[type] = klass
      end
    end
  end
end
