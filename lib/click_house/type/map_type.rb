# frozen_string_literal: true

module ClickHouse
  module Type
    class MapType < BaseType
      def map?
        true
      end

      def ddl?
        false
      end
    end
  end
end
