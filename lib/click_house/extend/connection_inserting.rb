# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionInserting
      EMPTY_INSERT = true

      # @return [Boolean]
      def insert(table, columns: [], values: [])
        yield(values) if block_given?

        body = if columns.empty?
          values.map(&:to_json)
        else
          values.map { |value_row| columns.zip(value_row).to_h.to_json }
        end

        return EMPTY_INSERT if values.empty?

        execute("INSERT INTO #{table} FORMAT JSONEachRow", body.join("\n")).success?
      end
    end
  end
end
