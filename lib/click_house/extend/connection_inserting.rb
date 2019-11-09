# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionInserting
      def insert(table, columns:, values: [])
        yield(values) if block_given?
        body = "#{columns.to_csv}#{values.map(&:to_csv).join('')}"
        execute("INSERT INTO #{table} FORMAT CSVWithNames", body).success?
      end
    end
  end
end
