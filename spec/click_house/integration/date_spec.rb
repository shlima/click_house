# frozen_string_literal: true

RSpec.describe ClickHouse::Type::IPType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a Date,
          b Nullable(Date)
       ) ENGINE Memory
    SQL

    subject.execute <<~SQL
      INSERT INTO rspec VALUES (
        '2022-01-02',
        NULL
      );
    SQL
  end

  it 'cast type' do
    got = subject.select_one('SELECT * FROM rspec')
    expect(got.fetch('a')).to eq(Date.new(2022, 1, 2))
    expect(got.fetch('b')).to eq(nil)
  end
end
