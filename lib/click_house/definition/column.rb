# frozen_string_literal: true

module ClickHouse
  module Definition
    class Column
      attr_accessor :name
      attr_accessor :type
      attr_accessor :nullable
      attr_accessor :low_cardinality
      attr_accessor :extensions
      attr_accessor :default
      attr_accessor :materialized
      attr_accessor :ttl

      def initialize(params = {})
        params.each { |k, v| public_send("#{k}=", v) }
        yield(self) if block_given?
      end

      def to_s
        type = extension_type
        type = "Nullable(#{type})" if nullable
        type = "LowCardinality(#{type})" if low_cardinality

        "#{name} #{type} #{opts}"
      end

      def opts
        options = {
          DEFAULT: Util::Statement.ensure(default, default),
          MATERIALIZED: Util::Statement.ensure(materialized, materialized),
          TTL: Util::Statement.ensure(ttl, ttl)
        }.compact

        result = options.each_with_object([]) do |(key, value), object|
          object << "#{key} #{value}"
        end

        result.join(' ')
      end

      def extension_type
        extensions.nil? ? type : format(type, *extensions)
      rescue TypeError, ArgumentError
        raise StandardError, "please provide extensions for <#{type}>"
      end
    end
  end
end
