# frozen_string_literal: true

module ClickHouse
  module Serializer
    class JsonOjSerializer < Base
      def dump(data)
        Oj.dump(data, config.oj_dump_options)
      end

      private

      def on_setup
        require 'oj' unless defined?(Oj)
      end
    end
  end
end
