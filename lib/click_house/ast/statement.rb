# frozen_string_literal: true

require 'stringio'

module ClickHouse
  module Ast
    class Statement
      PLACEHOLDER_S = '%s'
      PLACEHOLDER_D = '%d'
      DIGIT_RE = /\A\d+\Z/.freeze

      attr_reader :name
      attr_accessor :caster

      def initialize(name: '')
        @buffer = ''
        @name = name
      end

      # @param value [String]
      def print(value)
        @buffer = "#{@buffer}#{value}"
      end

      def name!
        @name = @buffer
        @buffer = ''
      end

      def argument!
        add_argument(Statement.new(name: @buffer))
        @buffer = ''
      end

      # @param st [Statement]
      def add_argument(st)
        arguments.push(st)
      end

      # @param other [Statement]
      def merge(other)
        if other.named?
          add_argument(other)
        else
          @arguments = arguments.concat(other.arguments)
        end
      end

      def named?
        !@name.empty?
      end

      def buffer?
        !@buffer.empty?
      end

      # @return [Array<Statement>]
      def arguments
        @arguments ||= []
      end

      # @return [Array]
      # cached argument values to increase the casting perfomance
      def argument_values
        @argument_values ||= arguments.map(&:value)
      end

      def argument_first!
        # TODO: raise an error if multiple arguments
        @argument_first ||= arguments.first
      end

      def placeholder
        return @placeholder if defined?(@placeholder)

        @placeholder = digit? ? PLACEHOLDER_D : PLACEHOLDER_S
      end

      def digit?
        name.match?(DIGIT_RE)
      end

      def value
        @value ||=
          case placeholder
          when PLACEHOLDER_D
            Integer(name)
          when PLACEHOLDER_S
            # remove leading and trailing quotes
            name[1..-2]
          else
            raise "unknown value extractor for <#{placeholder}>"
          end
      end

      def to_s
        out = StringIO.new
        out.print(name.empty? ? 'NO_NAME' : name)
        out.print("<#{@buffer}>") unless @buffer.empty?

        if arguments.any?
          out.print("(#{arguments.join(',')})")
        end

        out.string
      end
    end
  end
end
