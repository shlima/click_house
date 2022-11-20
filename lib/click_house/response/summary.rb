# frozen_string_literal: true

module ClickHouse
  module Response
    class Summary
      SUMMARY_HEADER = 'x-clickhouse-summary'
      KEY_TOTALS = 'totals'
      KEY_STATISTICS = 'statistics'
      KEY_ROWS_BEFORE_LIMIT_AT_LEAST = 'rows_before_limit_at_least'
      KEY_STAT_ELAPSED = 'elapsed'

      attr_reader :config,
                  :headers,
                  :summary,
                  # {:elapsed=>0.387287e-3, :rows_read=>0, :bytes_read=>0}}
                  :statistics,
                  :totals,
                  :rows_before_limit_at_least

      # @param config [Config]
      # @param headers [Faraday::Utils::Headers]
      # @param body [Hash]
      # TOTALS [Array|Hash|NilClass] Support for 'GROUP BY WITH TOTALS' modifier
      #   https://clickhouse.tech/docs/en/sql-reference/statements/select/group-by/#with-totals-modifier
      #   Hash in JSON format and Array in JSONCompact
      def initialize(config, headers: Faraday::Utils::Headers.new, body: {})
        @headers = headers
        @config = config
        @statistics = body.fetch(config.key(KEY_STATISTICS), {})
        @totals = body[config.key(KEY_TOTALS)]
        @rows_before_limit_at_least = body[config.key(KEY_ROWS_BEFORE_LIMIT_AT_LEAST)]
        @summary = parse_summary(headers[SUMMARY_HEADER])
      end

      # @return [Integer]
      def read_rows
        summary[config.key('read_rows')].to_i
      end

      # @return [Integer]
      def read_bytes
        summary[config.key('read_bytes')].to_i
      end

      # @return [String]
      def read_bytes_pretty
        Util::Pretty.size(read_bytes)
      end

      # @return [Integer]
      def written_rows
        summary[config.key('written_rows')].to_i
      end

      # @return [Integer]
      def written_bytes
        summary[config.key('written_bytes')].to_i
      end

      # @return [String]
      def written_bytes_pretty
        Util::Pretty.size(written_bytes)
      end

      # @return [Integer]
      def total_rows_to_read
        summary[config.key('total_rows_to_read')].to_i
      end

      # @return [Integer]
      def result_rows
        summary[config.key('result_rows')].to_i
      end

      # @return [Integer]
      def result_bytes
        summary[config.key('result_bytes')].to_i
      end

      # @return [Float]
      def elapsed
        statistics[config.key(KEY_STAT_ELAPSED)].to_f
      end

      # @return [String]
      def elapsed_pretty
        Util::Pretty.measure(elapsed * 1000)
      end

      private

      # @return [Hash]
      # {
      #   "read_rows" => "1",
      #   "read_bytes" => "23",
      #   "written_rows" => "1",
      #   "written_bytes" => "23",
      #   "total_rows_to_read" => "0",
      #   "result_rows" => "1",
      #   "result_bytes" => "23",
      # }
      def parse_summary(value)
        return {} if value.nil? || value.empty?

        JSON.parse(value)
      end
    end
  end
end
