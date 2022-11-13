# frozen_string_literal: true

module ClickHouse
  module Ast
    autoload :Statement, 'click_house/ast/statement'
    autoload :Ticker, 'click_house/ast/ticker'
    autoload :Parser, 'click_house/ast/parser'
  end
end
