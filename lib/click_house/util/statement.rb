# frozen_string_literal: true

module ClickHouse
  module Util
    module Statement
      module_function

      def ensure(truthful, value, fallback = nil)
        truthful ? value : fallback
      end
    end
  end
end
