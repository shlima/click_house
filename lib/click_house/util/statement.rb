# frozen_string_literal: true

module ClickHouse
  module Util
    module Statement
      END_OF_STATEMENT = ';'

      module_function

      def ensure(truthful, value, fallback = nil)
        truthful ? value : fallback
      end

      def format(sql, format)
        return sql if sql.match?(/FORMAT/i)

        "#{sql.sub(/#{END_OF_STATEMENT}(\s+|\Z)/, '')} FORMAT #{format};"
      end
    end
  end
end
