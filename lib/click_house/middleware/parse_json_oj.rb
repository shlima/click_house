# frozen_string_literal: true

module ClickHouse
  module Middleware
    class ParseJsonOj < ResponseBase
      Faraday::Response.register_middleware self => self

      # @param env [Faraday::Env]
      def on_complete(env)
        return unless content_type?(env, content_type)

        env.body = Oj.load(env.body, config.oj_load_options) unless env.body.strip.empty?
      end

      private

      def on_setup
        require 'oj' unless defined?(Oj)
      end
    end
  end
end
