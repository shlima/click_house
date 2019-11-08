# frozen_string_literal: true

module ClickHouse
  module Type
    autoload :BaseType, 'click_house/type/base_type'
    autoload :UndefinedType, 'click_house/type/undefined_type'
    autoload :DateType, 'click_house/type/date_type'
    autoload :IntegerType, 'click_house/type/integer_type'
    autoload :FloatType, 'click_house/type/float_type'
    autoload :BooleanType, 'click_house/type/boolean_type'
  end
end
