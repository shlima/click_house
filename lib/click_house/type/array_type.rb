# frozen_string_literal: true

module ClickHouse
  module Type
    class ArrayType < BaseType
      attr_reader :subtype

      STRING_QUOTE = "'"

      def initialize(subtype)
        @subtype = subtype
      end

      def cast(value, *)
        value
      end

      def serialize(array, *argv)
        return array unless string?

        serialized = array.map do |value|
          escaped = subtype.serialize(value, *argv).tr(STRING_QUOTE, '\\\\' + STRING_QUOTE)
          format("%<quote>s#{escaped}%<quote>s", quote: STRING_QUOTE)
        end

        "[#{serialized.join(',')}]"
      end

      private

      def string?
        return @is_string if defined?(@is_string)

        @is_string = subtype.is_a?(StringType) || subtype.is_a?(FixedStringType)
      end
    end
  end
end
