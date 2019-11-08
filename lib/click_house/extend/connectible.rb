# frozen_string_literal: true

module ClickHouse
  module Extend
    module Connectible
      def connection=(connection)
        @connection = connection
      end

      def connection
        @connection ||= Connection.new(config.clone)
      end
    end
  end
end
