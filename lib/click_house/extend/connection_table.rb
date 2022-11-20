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

      # @return [ResultSet]
      def table_schema(name)
        Response::Factory[execute("SELECT * FROM #{name} WHERE 1=0 FORMAT JSON")]
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

      # rubocop:disable Metrics/ParameterLists
      def create_table(
        name,
        if_not_exists: false, cluster: nil,
        partition: nil, order: nil, primary_key: nil, sample: nil, ttl: nil, settings: nil,
        engine:,
        &block
      )
        sql = <<~SQL
          CREATE TABLE %<exists>s %<name>s %<cluster>s %<definition>s %<engine>s
            %<partition>s
            %<order>s
            %<primary_key>s
            %<sample>s
            %<ttl>s
            %<settings>s
        SQL
        definition = ClickHouse::Definition::ColumnSet.new(&block)

        pattern = {
          name: name,
          exists: Util::Statement.ensure(if_not_exists, 'IF NOT EXISTS'),
          definition: definition.to_s,
          cluster: Util::Statement.ensure(cluster, "ON CLUSTER #{cluster}"),
          partition: Util::Statement.ensure(partition, "PARTITION BY #{partition}"),
          order: Util::Statement.ensure(order, "ORDER BY #{order}"),
          primary_key: Util::Statement.ensure(primary_key, "PRIMARY KEY #{primary_key}"),
          sample: Util::Statement.ensure(sample, "SAMPLE BY  #{sample}"),
          ttl: Util::Statement.ensure(ttl, "TTL #{ttl}"),
          settings: Util::Statement.ensure(settings, "SETTINGS #{settings}"),
          engine: Util::Statement.ensure(engine, "ENGINE = #{engine}")
        }

        execute(format(sql, pattern)).success?
      end
      # rubocop:enable Metrics/ParameterLists

      def truncate_table(name, if_exists: false, cluster: nil)
        sql = 'TRUNCATE TABLE %<exists>s %<name>s %<cluster>s'

        pattern = {
          name: name,
          exists: Util::Statement.ensure(if_exists, 'IF EXISTS'),
          cluster: Util::Statement.ensure(cluster, "ON CLUSTER #{cluster}")
        }

        execute(format(sql, pattern)).success?
      end

      def truncate_tables(names = tables, *argv)
        Array(names).each { |name| truncate_table(name, *argv) }
      end

      def rename_table(from, to, cluster: nil)
        from = Array(from)
        to = Array(to)

        unless from.length == to.length
          raise StatementException, '<from> tables length should equal <to> length'
        end

        sql = <<~SQL
          RENAME TABLE %<names>s %<cluster>s
        SQL

        pattern = {
          names: from.zip(to).map { |a| a.join(' TO ') }.join(', '),
          cluster: Util::Statement.ensure(cluster, "ON CLUSTER #{cluster}")
        }

        execute(format(sql, pattern)).success?
      end
    end
  end
end
