# frozen_string_literal: true

module ClickHouse
  module Type
    autoload :BaseType, 'click_house/type/base_type'
    autoload :UndefinedType, 'click_house/type/undefined_type'
    autoload :DateType, 'click_house/type/date_type'
  end
end
