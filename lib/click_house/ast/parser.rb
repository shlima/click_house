# frozen_string_literal: true

require 'stringio'

module ClickHouse
  module Ast
    class Parser
      OPEN = '('
      CLOSED = ')'
      COMMA = ','
      SPACE = ' '

      attr_reader :input

      # @param input [String]
      def initialize(input)
        @input = input
      end

      # @refs https://clickhouse.com/docs/en/sql-reference/data-types/
      # Map(String, Decimal(10, 5))
      # Array(Array(Array(Array(Nullable(Int, String)))))
      def parse
        ticker = Ticker.new
        control = false

        input.each_char do |char|
          # cases like (1,<space after comma> 3)
          next if control && char == SPACE

          case char
          when OPEN
            control = true
            ticker.open
          when CLOSED
            control = true
            ticker.close
          when COMMA
            control = true
            ticker.comma
          else
            control = false
            ticker.char(char)
          end
        end

        # if a single type like "Int"
        ticker.current.name! unless control
        ticker.current
      end
    end
  end
end
