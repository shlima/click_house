# frozen_string_literal: true

RSpec.describe ClickHouse::Type::IntegerType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a UInt8,
          b UInt16,
          c UInt32, 
          d UInt64,
          e Int8,
          f Int16,
          g Int32,
          h Int64,
          k Nullable(Int64)
       ) ENGINE Memory
    SQL

    subject.execute <<~SQL
      INSERT INTO rspec VALUES (
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          NULL
      );
    SQL
  end

  it 'cast type' do
    got = subject.select_one('SELECT * FROM rspec')
    expect(got.fetch('a')).to eq(1)
    expect(got.fetch('b')).to eq(2)
    expect(got.fetch('c')).to eq(3)
    expect(got.fetch('d')).to eq(4)
    expect(got.fetch('e')).to eq(5)
    expect(got.fetch('f')).to eq(6)
    expect(got.fetch('g')).to eq(7)
    expect(got.fetch('h')).to eq(8)
    expect(got.fetch('k')).to eq(nil)
  end
end
