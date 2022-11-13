# frozen_string_literal: true

RSpec.describe ClickHouse::Type::TupleType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a Tuple(IPv4, Nullable(Date), Nullable(String))
       ) ENGINE Memory
    SQL

    subject.execute <<~SQL
      INSERT INTO rspec VALUES (
        ('127.0.0.1', '2022-01-01', NULL)
      );
    SQL
  end

  let(:expectation) do
    [
      IPAddr.new('127.0.0.1'),
      Date.new(2022, 1, 1),
      nil
    ]
  end

  it 'cast type' do
    got = subject.select_one('SELECT * FROM rspec')
    expect(got.fetch('a')).to eq(expectation)
  end
end
