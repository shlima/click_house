# frozen_string_literal: true

RSpec.describe ClickHouse::Type::IPType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
         a Enum('foo' = 1, 'bar' = 2),
         b Nullable(Enum('foo' = 1, 'bar' = 2))
       ) ENGINE Memory
    SQL

    subject.execute <<~SQL
      INSERT INTO rspec VALUES (
        1, 
        NULL
      )
    SQL
  end

  it 'cast type' do
    got = subject.select_one('SELECT * FROM rspec')
    expect(got.fetch('a')).to eq('foo')
    expect(got.fetch('b')).to eq(nil)
  end
end
