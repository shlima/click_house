# frozen_string_literal: true

module ClickHouse
  module Middleware
    class Logging < Faraday::Middleware
      Faraday::Response.register_middleware self => self

      SUMMARY_HEADER = 'x-clickhouse-summary'

      attr_reader :logger, :starting, :body

      def initialize(app = nil, logger:)
        @logger = logger
        super(app)
      end

      def call(environment)
        @starting = timestamp
        @body = environment.body if log_body?
        @app.call(environment).on_complete(&method(:on_complete))
      end

      private

      def log_body?
        logger.level == Logger::DEBUG
      end


      def on_complete(env)
        elapsed = duration

        logger.info("\e[1m[35mSQL (#{Util::Pretty.measure(elapsed * 1000)})\e[0m #{query(env)};")
        logger.debug(body) if body && !query_in_body?(env)
        log_clickhouse_stats(env.body)
      end

      def duration
        timestamp - starting
      end

      def timestamp
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def query_in_body?(env)
        env.method == :get
      end

      def query(env)
        if query_in_body?(env)
          body
        else
          CGI.parse(env.url.query.to_s).dig('query', 0) || '[NO QUERY]'
        end
      end

      def log_clickhouse_stats(body) # rubocop:disable Layout/LineLength
        return unless body.is_a?(Hash) && body.key?('statistics') && body.key?('rows')

        stats = body['statistics']
        logger.info("\e[1m[36m#{body['rows']} rows in set. Elapsed: #{Util::Pretty.measure(stats.fetch('elapsed') * 1000)}. Processed #{stats.fetch('rows_read')} rows, #{Util::Pretty.size(stats.fetch('bytes_read'))}\e[0m")
      end
    end
  end
end
