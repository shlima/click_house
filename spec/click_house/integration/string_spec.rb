# frozen_string_literal: true

RSpec.describe ClickHouse::Type::StringType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a String,
          b FixedString(2),
          c UUID, 
          d Nullable(UUID)
       ) ENGINE Memory
    SQL

    subject.execute <<~SQL
      INSERT INTO rspec VALUES (
          'x',
          'y',
          'da70495b-1ff7-49e5-8feb-d657bd4ea1ea',
          NULL
      );
    SQL
  end

  it 'cast type' do
    got = subject.select_one('SELECT * FROM rspec')
    expect(got.fetch('a')).to eq("x")
    expect(got.fetch('b')).to eq("y\u0000")
    expect(got.fetch('c')).to eq("da70495b-1ff7-49e5-8feb-d657bd4ea1ea")
    expect(got.fetch('d')).to eq(nil)
  end
end
