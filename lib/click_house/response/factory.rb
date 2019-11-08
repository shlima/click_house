# frozen_string_literal: true

module ClickHouse
  module Response
    class Factory
      # @return [String, ResultSet]
      # @params env [Faraday::Response]
      def self.[](faraday)
        body = faraday.body

        return body if !body.is_a?(Hash) || !(body.key?('meta') && body.key?('data'))

        ResultSet.new(meta: body.fetch('meta'), data: body.fetch('data'), statistics: body['statistics'])
      end
    end
  end
end
