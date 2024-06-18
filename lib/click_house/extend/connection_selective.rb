# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionSelective
      # @return [ResultSet]
      def select_all(sql)
        response = get(body: sql, query: query_defaults)
        Response::Factory.response(response, config)
      end

      def select_value(sql)
        response = get(body: sql, query: query_defaults)
        got = Response::Factory.response(response, config).first

        case got
        when Hash
          Array(got).dig(0, -1) # get a value of a first key for JSON format
        when Array
          got[0] # for CSV format
        else
          got # for RowBinary format
        end
      end

      def select_one(sql)
        response = get(body: sql, query: query_defaults)
        Response::Factory.response(response, config).first
      end

      def query_defaults
        config.global_params.merge({default_format: 'JSON'})
      end
    end
  end
end
