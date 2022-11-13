# frozen_string_literal: true

module ClickHouse
  module Middleware
    class ResponseBase < Faraday::Middleware
      CONTENT_TYPE_HEADER = 'content-type'

      attr_reader :parser_options
      attr_reader :content_type

      def initialize(app = nil, parser_options: {}, content_type: nil, preserve_raw: false)
        super(app)
        @parser_options = parser_options
        @content_type = content_type
        @preserve_raw = preserve_raw
        on_setup
      end

      # @return [Boolean]
      # @param env [Faraday::Env]
      # @param regexp [NilClass, Regexp]
      def content_type?(env, regexp)
        case regexp
        when NilClass
          false
        when Regexp
          regexp.match?(String(env[:response_headers][CONTENT_TYPE_HEADER]))
        else
          raise ArgumentError, "expected regexp got #{regexp.class}"
        end
      end

      # @return [Config]
      def config
        parser_options.fetch(:config)
      end

      private

      def on_setup
        # require external dependencies here
      end
    end
  end
end
