# frozen_string_literal: true

module ClickHouse
  module Type
    class TupleType < BaseType
      def tuple?
        true
      end

      def ddl?
        false
      end
    end
  end
end
