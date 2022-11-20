# frozen_string_literal: true

module ClickHouse
  module Util
    autoload :Statement, 'click_house/util/statement'
    autoload :Pretty, 'click_house/util/pretty'

    module_function

    # wraps
    def array(input)
      input.is_a?(Array) ? input : [input]
    end
  end
end
