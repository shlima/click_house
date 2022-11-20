# frozen_string_literal: true

module ClickHouse
  module Response
    class Factory
      KEY_META = 'meta'
      KEY_DATA = 'data'
      KEY_TOTALS = 'totals'
      KEY_STATISTICS = 'statistics'
      KEY_ROWS_BEFORE_LIMIT_AT_LEAST = 'rows_before_limit_at_least'

      # @return [Nil], ResultSet]
      # @params faraday [Faraday::Response]
      # @params config [Config]
      def self.response(faraday, config)
        body = faraday.body

        return body unless body.is_a?(Hash)
        return body unless body.key?(config.key(KEY_META)) && body.key?(config.key(KEY_DATA))

        ResultSet.new(
          config: config,
          meta: body.fetch(config.key(KEY_META)),
          data: body.fetch(config.key(KEY_DATA)),
          totals: body[config.key(KEY_TOTALS)],
          statistics: body[config.key(KEY_STATISTICS)],
          rows_before_limit_at_least: body[config.key(KEY_ROWS_BEFORE_LIMIT_AT_LEAST)]
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
