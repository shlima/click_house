# frozen_string_literal: true

require 'stringio'

module ClickHouse
  module Ast
    class Ticker
      attr_reader :root, :current

      def initialize
        @current = Statement.new
      end

      def open
        current.name!
        opened.push(current)
        @current = Statement.new
      end

      def comma
        current.argument! if current.buffer?
        opened.last.merge(current)
        @current = Statement.new
      end

      def close
        current.argument! unless current.named?
        opened.last.merge(current)
        @current = opened.pop
      end

      # @param char [String]
      def char(char)
        current.print(char)
      end

      def opened
        @opened ||= []
      end
    end
  end
end
