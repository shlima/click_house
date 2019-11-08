# frozen_string_literal: true

module ClickHouse
  module Extend
    module ConnectionDatabase
      # @return [Array<String>]
      def databases
        Array(execute('SHOW DATABASES FORMAT CSV', database: nil).body).tap(&:flatten!)
      end

      def create_database(name, if_not_exists: false, cluster: nil, engine: nil)
        sql = 'CREATE DATABASE %<exists>s %<name>s %<cluster>s %<engine>s'

        pattern = {
          name: name,
          exists: Util::Statement.ensure(if_not_exists, 'IF NOT EXISTS'),
          cluster: Util::Statement.ensure(cluster, "ON CLUSTER #{cluster}"),
          engine: Util::Statement.ensure(engine, "ENGINE = #{engine}")
        }

        execute(format(sql, pattern), database: nil).success?
      end

      def drop_database(name, if_exists: false, cluster: nil)
        sql = 'DROP DATABASE %<exists>s %<name>s %<cluster>s'

        pattern = {
          name: name,
          exists: Util::Statement.ensure(if_exists, 'IF EXISTS'),
          cluster: Util::Statement.ensure(cluster, "ON CLUSTER #{cluster}"),
        }

        execute(format(sql, pattern), database: nil).success?
      end
    end
  end
end
