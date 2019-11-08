# frozen_string_literal: true

module ClickHouse
  module Extend
    module Configurable
      def config
        @config ||= Config.new
        @config.tap { |c| yield(c) } if block_given?
        @config
      end
    end
  end
end
