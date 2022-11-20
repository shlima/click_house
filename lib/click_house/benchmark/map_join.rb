# frozen_string_literal: true

require 'benchmark'
require 'stringio'

INPUT = Array.new(5_000_000, 'foo bar')

Benchmark.bm do |x|
  x.report('map.join') do
    INPUT.map(&:to_s).join("\n")
  end

  x.report('StringIO') do
    out = StringIO.new
    INPUT.each do |value|
      out << "#{value}\n"
    end
    out.string
  end
end
