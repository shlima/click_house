# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionInserting
      EMPTY_INSERT = true

      # @return [Boolean]
      #
      # == Example with a block
      # insert('rspec', columns: %i[name id]) do |buffer|
      #   buffer << ['Sun', 1]
      #   buffer << ['Moon', 2]
      # end
      #
      # == Example with a param
      # subject.insert('rspec', values: [{ name: 'Sun', id: 1 }, { name: 'Moon', id: 2 }], format: 'JSONStringsEachRow')
      def insert(table, columns: [], values: [], format: 'JSONEachRow')
        yield(values) if block_given?

        body = if columns.empty?
          values.map(&:to_json)
        else
          values.map { |value_row| columns.zip(value_row).to_h.to_json }
        end

        return EMPTY_INSERT if values.empty?

        execute("INSERT INTO #{table} FORMAT #{format}", body.join("\n")).success?
      end
    end
  end
end
