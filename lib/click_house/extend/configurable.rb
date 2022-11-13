# frozen_string_literal: true

module ClickHouse
  module Extend
    module Configurable
      def config(&block)
        yield(@config) if defined?(@config) && block

        @config ||= Config.new(&block)
      end
    end
  end
end
