# frozen_string_literal: true

module ClickHouse
  module Response
    class Factory
      KEY_META = 'meta'
      KEY_DATA = 'data'

      # @return [ResultSet]
      # @params faraday [Faraday::Response]
      # @params config [Config]
      def self.response(faraday, config)
        body = faraday.body

        # wrap to be able to use connection#select_one, connection#select_value
        # with other formats like binary
        return raw(faraday, config) unless body.is_a?(Hash)
        return raw(faraday, config) unless body.key?(config.key(KEY_META)) && body.key?(config.key(KEY_DATA))

        ResultSet.new(
          config: config,
          meta: body.fetch(config.key(KEY_META)),
          data: body.fetch(config.key(KEY_DATA)),
          summary: Middleware::SummaryMiddleware.extract(faraday.env)
        )
      end

      # @return [ResultSet]
      # Rae ResultSet (without type casting)
      def self.raw(faraday, config)
        ResultSet.raw(
          config: config,
          data: Util.array(faraday.body),
          summary: Middleware::SummaryMiddleware.extract(faraday.env)
        )
      end

      # Result of execution
      # @return [Response::Summary]
      # @params faraday [Faraday::Response]
      def self.exec(faraday)
        Middleware::SummaryMiddleware.extract(faraday.env)
      end

      # @return [Response::Summary]
      def self.empty_exec(config)
        Summary.new(config)
      end
    end
  end
end
