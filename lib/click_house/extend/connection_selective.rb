# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionSelective
      # @param sql [String]
      # @param array [Boolean] Response rows as arrays, can be helpful for performance reasons on big amounts of data
      # @param settings [Hash] Passed as query params to CH
      # @return [ResultSet]
      def select_all(sql, array: false, **settings)
        format = array ? 'JSONCompact' : 'JSON'
        response = get(body: Util::Statement.format(sql, format), query: settings)

        Response::Factory[response]
      end

      def select_value(sql)
        response = get(body: Util::Statement.format(sql, 'JSON'))
        Array(Response::Factory[response].first).dig(0, -1)
      end

      def select_one(sql)
        response = get(body: Util::Statement.format(sql, 'JSON'))
        Response::Factory[response].first
      end
    end
  end
end
