# frozen_string_literal: true

module ClickHouse
  module Definition
    class ColumnSet
      TYPES = ClickHouse.types.each_with_object([]) do |(name, type), object|
        object << name.sub('%s', "'%s'") if type.ddl?
      end

      class << self
        # @input "DateTime('%s')"
        # @output "DateTime"
        def method_name_for_type(type)
          type.sub(/\(.+/, '')
        end
      end

      TYPES.each do |type|
        method_name = method_name_for_type(type)
        # t.Decimal :customer_id, nullable: true, default: ''
        # t.Decimal :money, 1, 2, nullable: true, default: ''
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def #{method_name}(*definition)
            name = definition[0]
            extensions = []
            options = {}
            Array(definition[1..-1]).each do |el|
              el.is_a?(Hash) ? options.merge!(el) : extensions.push(el)
            end

            columns << Column.new(type: "#{type}", name: name, extensions: extensions, **options)
          end
        METHODS
      end

      def initialize
        yield(self) if block_given?
      end

      def columns
        @columns ||= []
      end

      def to_s
        <<~SQL
          ( #{columns.map(&:to_s).join(', ')} )
        SQL
      end

      # @example
      #   t.Nested :json do |n|
      #     n.UInt8 :city_id
      #   end
      def nested(name, &block)
        columns << "#{name} Nested #{ColumnSet.new(&block)}"
      end

      alias_method :Nested, :nested

      def push(sql)
        columns << sql
      end

      alias_method :<<, :push
    end
  end
end

__END__

data = ClickHouse::Definition::ColumnSet.new do |t|
  t << "words Enum('hello' = 1, 'world' = 2)"
end

puts data.to_s

data = ClickHouse::Definition::ColumnSet.new do |t|
  t.Decimal :money
  t.Float32 :client_id, default: 0
  t.Float32 :city_id, default: 0, nullable: true
  t.Nested :json do |n|
    n.Date :created_at
    n.Date :updated_at
  end

  t << "CUSTOM SQL"
end
