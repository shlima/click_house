# frozen_string_literal: true

module ClickHouse
  module Serializer
    class JsonSerializer < Base
      def dump(data)
        JSON.dump(data)
      end
    end
  end
end
