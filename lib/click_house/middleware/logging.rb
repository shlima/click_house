# frozen_string_literal: true

module ClickHouse
  module Middleware
    class Logging < Faraday::Middleware
      Faraday::Response.register_middleware self => self

      SUMMARY_HEADER = 'x-clickhouse-summary'

      attr_reader :logger, :starting

      def initialize(app = nil, logger:)
        @logger = logger
        super(app)
      end

      def call(environment)
        @starting = timestamp
        @app.call(environment).on_complete(&method(:on_complete))
      end

      private

      # rubocop:disable Metrics/LineLength
      def on_complete(env)
        status = env.status
        method = env.method
        body = env.body
        url = env.url
        # summary = extract_summary(env.response_headers)
        elapsed = duration
        query = CGI.parse(env.url.query.to_s).dig('query', 0) || '[NO QUERY]'
        rows = 0

        logger.info("\e[1m[35mSQL (#{elapsed})\e[0m #{query};")
        logger.info("\e[1m[36m#{rows}\e[0m")
        # logger.info("\n \e[1m[36m#{rows} #{"row".pluralize(rows)} in set. Elapsed: #{elapsed}. Processed: #{rows_read} rows, #{data_read} (#{rows_per_second} rows/s, #{data_per_second}/s)\e[0m")
      end
      # rubocop:enable Metrics/LineLength

      def duration
        timestamp - starting
      end

      def timestamp
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      # def extract_summary(headers)
      #   data = JSON.parse(headers['x-clickhouse-summary'])
      #   result = {}
      #
      #   if (read_rows = data['read_rows'])
      #     result[:read_rows] = read_rows
      #   end
      #
      #   result
      # rescue JSON::ParserError
      #   {}
      # end
    end
  end
end
