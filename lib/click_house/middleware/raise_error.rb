# frozen_string_literal: true

module ClickHouse
  module Middleware
    class RaiseError < Faraday::Middleware
      SUCCEED_STATUSES = (200..299).freeze

      Faraday::Response.register_middleware self => self

      def call(environment)
        @app.call(environment).on_complete(&method(:on_complete))
      rescue Faraday::ConnectionFailed => e
        raise NetworkException, e.message, e.backtrace
      end

      private

      def on_complete(env)
        return if SUCCEED_STATUSES.include?(env.status)

        raise DbException, <<~MSG
          [#{env.status}] #{env.body}
        MSG
      end
    end
  end
end
