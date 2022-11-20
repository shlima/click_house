# frozen_string_literal: true

module ClickHouse
  module Response
    autoload :Factory, 'click_house/response/factory'
    autoload :ResultSet, 'click_house/response/result_set'
    autoload :Execution, 'click_house/response/execution'
  end
end
