# frozen_string_literal: true

RSpec.describe ClickHouse::Type::MapType do
  subject do
    ClickHouse.connection
  end

  before do
    subject.execute <<~SQL
      CREATE TABLE rspec(
          a Map(LowCardinality(String), Array(DateTime('Europe/Kyiv'))),
          b Map(Int8, IPv4)
       ) ENGINE Memory
    SQL
  end

  describe 'cast' do
    before do
      subject.execute <<~SQL
        INSERT INTO rspec VALUES (
          {'foo': ['2019-01-01']}, 
          {1: '127.0.0.1'}
        )
      SQL
    end

    it 'works' do
      got = subject.select_one('SELECT * FROM rspec')
      expect(got.dig('a', 'foo')).to eq([Time.find_zone('Europe/Kyiv').parse('2019-01-01')])
      expect(got.dig('b', 1)).to eq(IPAddr.new('127.0.0.1'))
    end
  end

  describe 'serialize' do
    let(:row) do
      {
        'a' => {'foo' => [Time.find_zone('Europe/Kyiv').now.round]},
        'b' => { 1 => IPAddr.new('127.0.0.1')},
      }
    end

    it 'works' do
      subject.insert('rspec', subject.table_schema('rspec').serialize_one(row))
      got = subject.select_one('SELECT * FROM rspec')

      expect(got.fetch('a')).to eq(row.fetch('a'))
      expect(got.fetch('b')).to eq(row.fetch('b'))
    end
  end
end
