# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionSelective
      # @return [ResultSet]
      def select_all(sql)
        Response::Factory[execute(Util::Statement.format(sql, 'JSON'))]
      end
    end
  end
end
