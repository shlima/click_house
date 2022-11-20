# frozen_string_literal: true

module ClickHouse
  module Serializer
    autoload :Base, 'click_house/serializer/base'
    autoload :JsonSerializer, 'click_house/serializer/json_serializer'
    autoload :JsonOjSerializer, 'click_house/serializer/json_oj_serializer'
  end
end
