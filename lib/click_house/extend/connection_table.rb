# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionTable
      # @return [Array<String>]
      def tables
        Array(execute('SHOW TABLES FORMAT CSV').body).tap(&:flatten!)
      end

      # @return [ResultSet]
      def describe_table(name)
        Response::Factory[execute("DESCRIBE TABLE #{name} FORMAT JSON")]
      end

      # @return [Boolean]
      def table_exists?(name, temporary: false)
        sql = 'EXISTS %<temporary>s TABLE  %<name>s FORMAT CSV'

        pattern = {
          name: name,
          temporary: Util::Statement.ensure(temporary, 'TEMPORARY')
        }

        Type::BooleanType.new.cast(execute(format(sql, pattern)).body.dig(0, 0))
      end

      def drop_table(name, temporary: false, if_exists: false, cluster: nil)
        sql = 'DROP %<temporary>s TABLE %<exists>s %<name>s %<cluster>s'

        pattern = {
          name: name,
          temporary: Util::Statement.ensure(temporary, 'TEMPORARY'),
          exists: Util::Statement.ensure(if_exists, 'IF EXISTS'),
          cluster: Util::Statement.ensure(cluster, "ON CLUSTER #{cluster}"),
        }

        execute(format(sql, pattern)).success?
      end
    end
  end
end
