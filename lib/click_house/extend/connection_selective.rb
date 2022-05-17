# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionSelective
      # @return [ResultSet]
      def select_all(sql)
        response = get(body: sql, query: { default_format: 'JSON' })
        Response::Factory[response]
      end

      def select_value(sql)
        response = get(body: sql, query: { default_format: 'JSON' })
        Array(Response::Factory[response].first).dig(0, -1)
      end

      def select_one(sql)
        response = get(body: sql, query: { default_format: 'JSON' })
        Response::Factory[response].first
      end
    end
  end
end
