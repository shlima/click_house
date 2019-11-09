# frozen_string_literal: true

module ClickHouse
  module Util
    module Pretty
      SIZE_UNITS = %w[B KiB MiB GiB TiB Pib EiB].freeze

      module_function

      # rubocop:disable all
      def size(bytes)
        return '0B' if bytes == 0

        exp = (Math.log(bytes) / Math.log(1024)).to_i
        exp = 6 if exp > 6

        format('%.1f%s', bytes.to_f / 1024**exp, SIZE_UNITS[exp])
      end
      # rubocop:enable all

      def measure(ms)
        "#{ms.round}MS"
      end

      def squish(string)
        string.gsub(/[[:space:]]+/, ' ').strip
      end
    end
  end
end
