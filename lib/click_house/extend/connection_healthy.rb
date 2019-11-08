# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionHealthy
      def ping
        get(database: nil).success?
      end

      def replicas_status
        get('/replicas_status', database: nil).success?
      end
    end
  end
end
