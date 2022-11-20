# frozen_string_literal: true

module ClickHouse
  module Serializer
    class Base
      attr_reader :config

      # @param config [Config]
      def initialize(config)
        @config = config
        on_setup
      end

      def dump(data)
        raise NotImplementedError, __method__
      end

      # @return [String]
      # @param data [Array]
      def dump_each_row(data, sep = "\n")
        data.map(&method(:dump)).join(sep)
      end

      private

      # require external dependencies here
      def on_setup
        nil
      end
    end
  end
end
