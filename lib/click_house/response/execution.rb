# frozen_string_literal: true

module ClickHouse
  module Response
    class Execution
      SUMMARY_HEADER = 'x-clickhouse-summary'

      attr_reader :headers, :summary

      # @param headers [Faraday::Utils::Headers]
      def initialize(headers: Faraday::Utils::Headers.new)
        @headers = headers
        @summary = parse_summary(headers[SUMMARY_HEADER])
      end

      # @return [Integer]
      def read_rows
        summary['read_rows'].to_i
      end

      # @return [Integer]
      def read_bytes
        summary['read_bytes'].to_i
      end

      # @return [Integer]
      def written_rows
        summary['written_rows'].to_i
      end

      # @return [Integer]
      def written_bytes
        summary['written_bytes'].to_i
      end

      # @return [Integer]
      def total_rows_to_read
        summary['total_rows_to_read'].to_i
      end

      # @return [Integer]
      def result_rows
        summary['result_rows'].to_i
      end

      # @return [Integer]
      def result_bytes
        summary['result_bytes'].to_i
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
