# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionInserting
      DEFAULT_JSON_EACH_ROW_FORMAT = 'JSONEachRow'
      DEFAULT_JSON_COMPACT_EACH_ROW_FORMAT = 'JSONCompactEachRow'

      # @return [Boolean]
      #
      # == Example with a block
      # insert('rspec', columns: %i[name id]) do |buffer|
      #   buffer << ['Sun', 1]
      #   buffer << ['Moon', 2]
      # end
      #
      # @return [Response::Execution]
      # @param body [Array, Hash]
      # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      def insert(table, body = [], **opts)
        # In Ruby < 3.0, if the last argument is a hash, and the method being called
        # accepts keyword arguments, then it is always converted to keyword arguments.
        columns = opts.fetch(:columns, [])
        values =  opts.fetch(:values, [])
        format = opts.fetch(:format, nil)

        yield(body) if block_given?

        # values: [{id: 1}]
        if values.any? && columns.empty?
          return insert_rows(table, values, format: format)
        end

        # body: [{id: 1}]
        if body.any? && columns.empty?
          return insert_rows(table, body, format: format)
        end

        # body: [1], columns: ["id"]
        if body.any? && columns.any?
          return insert_compact(table, columns: columns, values: body, format: format)
        end

        # columns: ["id"], values: [[1]]
        if columns.any? && values.any?
          return insert_compact(table, columns: columns, values: values, format: format)
        end

        Response::Factory.empty_exec(config)
      end
      # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

      # @param table [String]
      # @param body [Array, Hash]
      # @param format [String]
      # @return [Response::Execution]
      #
      # Sometimes it's needed to use other format than JSONEachRow
      # For example if you want to send BigDecimal's you could use
      # JSONStringsEachRow format so string representation of BigDecimal will be parsed
      def insert_rows(table, body, format: nil)
        format ||= DEFAULT_JSON_EACH_ROW_FORMAT

        case body
        when Hash
          Response::Factory.exec(execute("INSERT INTO #{table} FORMAT #{format}", config.json_serializer.dump(body)))
        when Array
          Response::Factory.exec(execute("INSERT INTO #{table} FORMAT #{format}", config.json_serializer.dump_each_row(body)))
        else
          raise ArgumentError, "unknown body class <#{body.class}>"
        end
      end

      # @return [Response::Execution]
      def insert_compact(table, columns: [], values: [], format: nil)
        format ||= DEFAULT_JSON_COMPACT_EACH_ROW_FORMAT

        yield(values) if block_given?

        response = execute("INSERT INTO #{table} (#{columns.join(',')}) FORMAT #{format}", config.json_serializer.dump_each_row(values))
        Response::Factory.exec(response)
      end
    end
  end
end
