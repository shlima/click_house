# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionInserting
      def insert(table, columns:, values: [])
        yield(values) if block_given?

        body = values.map do |value_row|
          columns.zip(value_row).to_h.to_json
        end

        execute("INSERT INTO #{table} FORMAT JSONEachRow", body.join("\n")).success?
      end
    end
  end
end
