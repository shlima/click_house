# frozen_string_literal: true

module ClickHouse
  module Util
    module Statement
      module_function

      def ensure(truthful, value, fallback = nil)
        truthful ? value : fallback
      end

      def format(sql, format)
        return sql if sql =~ /FORMAT/i

        "#{sql.sub(/;/, '')} FORMAT #{format};"
      end
    end
  end
end
