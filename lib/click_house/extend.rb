# frozen_string_literal: true

module ClickHouse
  module Extend
    autoload :TypeDefinition, 'click_house/extend/type_definition'
    autoload :Configurable, 'click_house/extend/configurable'
    autoload :Connectible, 'click_house/extend/connectible'
    autoload :ConnectionHealthy, 'click_house/extend/connection_healthy'
    autoload :ConnectionDatabase, 'click_house/extend/connection_database'
    autoload :ConnectionTable, 'click_house/extend/connection_table'
    autoload :ConnectionSelective, 'click_house/extend/connection_selective'
    autoload :ConnectionInserting, 'click_house/extend/connection_inserting'
    autoload :ConnectionAltering, 'click_house/extend/connection_altering'
  end
end
