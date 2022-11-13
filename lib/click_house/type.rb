# frozen_string_literal: true

module ClickHouse
  module Type
    autoload :BaseType, 'click_house/type/base_type'
    autoload :NullableType, 'click_house/type/nullable_type'
    autoload :UndefinedType, 'click_house/type/undefined_type'
    autoload :DateType, 'click_house/type/date_type'
    autoload :DateTimeType, 'click_house/type/date_time_type'
    autoload :DateTime64Type, 'click_house/type/date_time64_type'
    autoload :IntegerType, 'click_house/type/integer_type'
    autoload :FloatType, 'click_house/type/float_type'
    autoload :BooleanType, 'click_house/type/boolean_type'
    autoload :DecimalType, 'click_house/type/decimal_type'
    autoload :FixedStringType, 'click_house/type/fixed_string_type'
    autoload :ArrayType, 'click_house/type/array_type'
    autoload :StringType, 'click_house/type/string_type'
    autoload :IPType, 'click_house/type/ip_type'
    autoload :LowCardinalityType, 'click_house/type/low_cardinality_type'
  end
end
