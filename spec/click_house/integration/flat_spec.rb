# frozen_string_literal: true

RSpec.describe ClickHouse::Type::IntegerType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a Float32,
          b Float64,        
          c Nullable(Float64)
       ) ENGINE Memory
    SQL

    subject.execute <<~SQL
      INSERT INTO rspec VALUES (
          1.1,
          2.2,
          NULL
      );
    SQL
  end

  it 'cast type' do
    got = subject.select_one('SELECT * FROM rspec')
    expect(got.fetch('a')).to eq(1.1)
    expect(got.fetch('b')).to eq(2.2)
    expect(got.fetch('c')).to eq(nil)
  end
end
