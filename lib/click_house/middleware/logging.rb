# frozen_string_literal: true

module ClickHouse
  module Middleware
    class Logging < Faraday::Middleware
      Faraday::Response.register_middleware self => self

      EMPTY = ''
      GET = :get

      attr_reader :logger, :starting

      def initialize(app = nil, logger:)
        @logger = logger
        super(app)
      end

      def call(env)
        @starting = timestamp
        super
      end

      # rubocop:disable Layout/LineLength
      def on_complete(env)
        summary = SummaryMiddleware.extract(env)
        logger.info("\e[1m[35mSQL (#{duration_stats_log(summary)})\e[0m #{query(env)};")
        logger.debug(env.request_body) if log_body?(env)
        logger.info("\e[1m[36mRead: #{summary.read_rows} rows, #{summary.read_bytes_pretty}. Written: #{summary.written_rows} rows, #{summary.written_bytes_pretty}\e[0m")
      end
      # rubocop:enable Layout/LineLength

      private

      def duration
        timestamp - starting
      end

      def timestamp
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      # @return [Boolean]
      def log_body?(env)
        return unless logger.debug?
        return if env.method == GET # GET queries logs body as a statement
        return if env.request_body.nil? || env.request_body == EMPTY

        true
      end

      def query(env)
        if env.method == GET
          env.request_body
        else
          String(CGI.parse(env.url.query.to_s).dig('query', 0) || '[NO QUERY]').chomp
        end
      end

      def duration_stats_log(summary)
        "Total: #{Util::Pretty.measure(duration * 1000)}, CH: #{summary.elapsed_pretty}"
      end
    end
  end
end
