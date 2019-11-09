# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionHealthy
      def ping
        # without +send_progress_in_http_headers: nil+ DB::Exception: Empty query returns
        get(database: nil, query: { send_progress_in_http_headers: nil }).success?
      end

      def replicas_status
        get('/replicas_status', database: nil).success?
      end
    end
  end
end
