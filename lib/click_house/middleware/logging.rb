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

      # rubocop:disable Metrics/LineLength
      def on_complete(env)
        summary = extract_summary(env.response_headers)
        elapsed = duration
        query = CGI.parse(env.url.query.to_s).dig('query', 0) || '[NO QUERY]'

        logger.info("\e[1m[35mSQL (#{Util::Pretty.measure(elapsed)})\e[0m #{query};")
        logger.debug(body) if body
        logger.info("\e[1m[36mRead: #{summary.fetch(:read_rows)} rows, #{summary.fetch(:read_bytes)}. Written: #{summary.fetch(:written_rows)}, rows #{summary.fetch(:written_bytes)}\e[0m")
      end
      # rubocop:enable Metrics/LineLength

      def duration
        timestamp - starting
      end

      def timestamp
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
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
