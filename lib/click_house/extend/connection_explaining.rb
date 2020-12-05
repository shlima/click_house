# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionExplaining
      EXPLAIN = 'EXPLAIN'
      EXPLAIN_RE = /\A(\s*#{EXPLAIN})/io.freeze

      def explain(sql, io: $stdout)
        res = execute("#{EXPLAIN} #{sql.gsub(EXPLAIN_RE, '')}")
        io << res.body
      end
    end
  end
end
