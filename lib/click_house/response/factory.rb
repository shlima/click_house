# frozen_string_literal: true

module ClickHouse
  module Response
    class Factory
      KEY_META = 'meta'
      KEY_DATA = 'data'

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
          summary: Middleware::SummaryMiddleware.extract(faraday.env)
        )
      end

      # @return [Response::Execution]
      # @params faraday [Faraday::Response]
      def self.exec(faraday)
        Middleware::SummaryMiddleware.extract(faraday.env)
      end

      # @return [Response::Execution]
      def self.empty_exec(config)
        Summary.new(config)
      end
    end
  end
end
