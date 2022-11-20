# frozen_string_literal: true

module ClickHouse
  module Middleware
    class SummaryMiddleware < ResponseBase
      Faraday::Response.register_middleware self => self

      KEY = :summary

      # @param env [Faraday::Env]
      # @return [Response::Summary]
      def self.extract(env)
        env.custom_members.fetch(KEY)
      end

      # @param env [Faraday::Env]
      def on_complete(env)
        env.custom_members[KEY] = Response::Summary.new(
          config,
          headers: env.response_headers,
          body: env.body.is_a?(Hash) ? env.body : {}
        )
      end
    end
  end
end
