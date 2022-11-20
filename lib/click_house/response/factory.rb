# frozen_string_literal: true

module ClickHouse
  module Response
    class Factory
      # @return [String, ResultSet]
      # @params faraday [Faraday::Response]
      def self.[](faraday)
        body = faraday.body

        return body if !body.is_a?(Hash) || !(body.key?('meta') && body.key?('data'))

        ResultSet.new(
          meta: body.fetch('meta'),
          data: body.fetch('data'),
          totals: body['totals'],
          statistics: body['statistics'],
          rows_before_limit_at_least: body['rows_before_limit_at_least']
        )
      end

      # @return [Response::Execution]
      # @params faraday [Faraday::Response]
      def self.exec(faraday)
        Execution.new(headers: faraday.headers)
      end

      # @return [Response::Execution]
      def self.empty_exec
        Execution.new
      end
    end
  end
end
