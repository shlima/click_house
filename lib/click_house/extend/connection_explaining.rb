# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionExplaining
      EXPLAIN = 'EXPLAIN'
      EXPLAIN_RE = /\A(\s*#{EXPLAIN})/io.freeze

      # @return String
      def explain(sql, io: StringIO.new)
        res = execute("#{EXPLAIN} #{sql.gsub(EXPLAIN_RE, '')}")
        io.puts(res.body)
        io.string
      end
    end
  end
end
