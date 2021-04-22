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

      # rubocop:disable Layout/LineLength
      def on_complete(env)
        summary = extract_summary(env.response_headers)
        logger.info("\e[1m[35mSQL (#{duration_stats_log(env.body)})\e[0m #{query(env)};")
        logger.debug(body) if body && !query_in_body?(env)
        logger.info("\e[1m[36mRead: #{summary.fetch(:read_rows)} rows, #{summary.fetch(:read_bytes)}. Written: #{summary.fetch(:written_rows)} rows, #{summary.fetch(:written_bytes)}\e[0m")
      end
      # rubocop:enable Layout/LineLength

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

      def duration_stats_log(body)
        elapsed = duration
        clickhouse_elapsed = body['statistics'].fetch('elapsed') if body.is_a?(Hash) && body.key?('statistics')

        [
          "Total: #{Util::Pretty.measure(elapsed * 1000)}",
          ("CH: #{Util::Pretty.measure(clickhouse_elapsed * 1000)}" if clickhouse_elapsed)
        ].compact.join(', ')
      end

      def extract_summary(headers)
        JSON.parse(headers.fetch('x-clickhouse-summary', '{}')).tap do |summary|
          summary[:read_rows] = summary['read_rows']
          summary[:read_bytes] = Util::Pretty.size(summary['read_bytes'].to_i)
          summary[:written_rows] = summary['written_rows']
          summary[:written_bytes] = Util::Pretty.size(summary['written_bytes'].to_i)
        end
      rescue JSON::ParserError
        {}
      end
    end
  end
end
