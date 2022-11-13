# frozen_string_literal: true

module ClickHouse
  module Type
    class LowCardinalityType < BaseType
      attr_reader :subtype

      def initialize(subtype)
        @subtype = subtype
      end

      def cast(*argv)
        subtype.cast(*argv)
      end

      def serialize(*argv)
        subtype.serialize(*argv)
      end
    end
  end
end
