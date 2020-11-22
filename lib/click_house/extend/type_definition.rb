# frozen_string_literal: true

module ClickHouse
  module Extend
    module TypeDefinition
      NULLABLE = 'Nullable'
      NULLABLE_RE = /#{NULLABLE}/i.freeze

      def types
        @types ||= Hash.new(Type::UndefinedType.new)
      end

      def add_type(type, klass, nullable: true)
        types[type] = klass
        types["#{NULLABLE}(#{type})"] = Type::NullableType.new(klass) if nullable
      end

      # @return [Enum<String>]
      def type_names(nullable:)
        nullable ? types.keys : types.keys.grep_v(NULLABLE_RE)
      end
    end
  end
end
