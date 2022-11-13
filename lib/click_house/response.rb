# frozen_string_literal: true

module ClickHouse
  module Response
    autoload :Factory, 'click_house/response/factory'
    autoload :ResultSet, 'click_house/response/result_set'
    autoload :Tokenize, 'click_house/response/tokenize'
  end
end
